#!/usr/bin/env nu

def sri [algo: string]: string -> string {
  $"($algo)-($in | decode hex | encode base64)"
}

def fetch [url: string] {
  curl -sSfL --connect-timeout 10 --speed-time 15 --speed-limit 1 --retry 2 --retry-all-errors $url
}

def gh-release [repo: string, asset: string, --pre] {
  let r = (fetch $"https://api.github.com/repos/($repo)/releases" | from json | where prerelease == $pre | first)
  let a = ($r.assets | where name == $asset | first)
  {
    version: ($r.tag_name | str replace -r '^\D+' "")
    url: $a.browser_download_url
    hash: ($a.digest | str replace "sha256:" "" | sri sha256)
  }
}

def bun [] { gh-release oven-sh/bun bun-linux-x64.zip }

def zed [] { gh-release --pre zed-industries/zed zed-linux-x86_64.tar.gz }

def claude-code [] {
  let m = fetch https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/next | from json
  {version: $m.version, url: $m.dist.tarball, hash: $m.dist.integrity}
}

def firefox [] {
  let root = "https://archive.mozilla.org/pub/firefox/nightly"
  let version = (fetch https://product-details.mozilla.org/1.0/firefox_versions.json | from json).FIREFOX_NIGHTLY
  let stem = $"firefox-($version).en-US.linux-x86_64"
  let stamp = ((fetch $"($root)/latest-mozilla-central/($stem).json" | from json).buildid | into datetime -f "%Y%m%d%H%M%S" | format date "%Y/%m/%Y-%m-%d-%H-%M-%S")
  let base = $"($root)/($stamp)-mozilla-central"
  let file = $"($stem).tar.xz"
  let sums = fetch $"($base)/($stem).checksums"
  {
    version: $version
    url: $"($base)/($file)"
    hash: ($sums | lines | parse "{sha512} sha512 {size} {file}" | where file == $file | first | get sha512 | sri sha512)
  }
}

def zigpin [m: record] {
  let bin = ($m | get x86_64-linux)
  {version: $m.version, url: $bin.tarball, hash: ($bin.shasum | sri sha256)}
}

def zig [] {
  zigpin (fetch https://ziglang.org/download/index.json | from json).master
}

def zls [zig_version: string, old: record] {
  let v = ($zig_version | url encode)
  let m = fetch $"https://releases.zigtools.org/v1/zls/select-version?zig_version=($v)&compatibility=full" | from json
  if "message" in $m {
    print -e $"zls: ($m.message) - keeping ($old.version)"
    return $old
  }
  zigpin $m
}

def parallel [pins: record]: nothing -> record {
  $pins | transpose name fetch | par-each --keep-order {|p| {$p.name: (do $p.fetch)}} | into record
}

def report [old: record, new: record] {
  $new | items {|k, v| if $v.url != ($old | get $k).url { print $"($k): (($old | get $k).version) -> ($v.version)" }}
}

def main [] {
  let path = ($env.FILE_PWD | path join pins.json)
  let old = open $path
  let z = zig
  let new = parallel {
    bun: {|| bun}
    claude-code: {|| claude-code}
    firefox: {|| firefox}
    zed: {|| zed}
    zig: {|| $z}
    zls: {|| zls $z.version $old.zls}
  }
  report $old $new
  $new | to json | $"($in)\n" | save -f $path
}
