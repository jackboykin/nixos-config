#!/usr/bin/env nu

def sri [algo: string]: string -> string {
  $"($algo)-($in | decode hex | encode base64)"
}

def bun [] {
  let r = http get https://api.github.com/repos/oven-sh/bun/releases/latest
  let a = ($r.assets | where name == "bun-linux-x64.zip" | first)
  {
    version: ($r.tag_name | str replace "bun-v" "")
    url: $a.browser_download_url
    hash: ($a.digest | str replace "sha256:" "" | sri sha256)
  }
}

def claude-code [] {
  let m = http get https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/next
  {version: $m.version, url: $m.dist.tarball, hash: $m.dist.integrity}
}

def firefox [] {
  let root = "https://archive.mozilla.org/pub/firefox/nightly"
  let version = (http get https://product-details.mozilla.org/1.0/firefox_versions.json).FIREFOX_NIGHTLY
  let stem = $"firefox-($version).en-US.linux-x86_64"
  let id = ((http get $"($root)/latest-mozilla-central/($stem).json").buildid | parse --regex '(?<y>\d{4})(?<mo>\d{2})(?<d>\d{2})(?<h>\d{2})(?<mi>\d{2})(?<s>\d{2})' | first)
  let base = $"($root)/($id.y)/($id.mo)/($id.y)-($id.mo)-($id.d)-($id.h)-($id.mi)-($id.s)-mozilla-central"
  let file = $"($stem).tar.xz"
  let sums = http get $"($base)/($stem).checksums"
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
  zigpin (http get https://ziglang.org/download/index.json).master
}

def zls [zig_version: string, old: record] {
  let v = ($zig_version | url encode)
  let m = http get $"https://releases.zigtools.org/v1/zls/select-version?zig_version=($v)&compatibility=full"
  if "message" in $m {
    print -e $"zls: ($m.message) - keeping ($old.version)"
    return $old
  }
  zigpin $m
}

def main [] {
  let path = ($env.FILE_PWD | path join pins.json)
  let old = open $path
  let z = zig
  {bun: (bun), claude-code: (claude-code), firefox: (firefox), zig: $z, zls: (zls $z.version $old.zls)}
  | to json | $"($in)\n"
  | save -f $path
}
