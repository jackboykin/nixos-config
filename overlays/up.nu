#!/usr/bin/env nu

def firefox [] {
  let root = "https://archive.mozilla.org/pub/firefox/nightly"
  let latest = $"($root)/latest-mozilla-central"
  let version = (http get https://product-details.mozilla.org/1.0/firefox_versions.json).FIREFOX_NIGHTLY
  let stem = $"firefox-($version).en-US.linux-x86_64"
  let id = ((http get $"($latest)/($stem).json").buildid | parse --regex '(?<y>\d{4})(?<mo>\d{2})(?<d>\d{2})(?<h>\d{2})(?<mi>\d{2})(?<s>\d{2})' | first)
  let base = $"($root)/($id.y)/($id.mo)/($id.y)-($id.mo)-($id.d)-($id.h)-($id.mi)-($id.s)-mozilla-central"
  let sums = http get $"($base)/($stem).checksums"
  let file = $"($stem).tar.xz"
  {
    version: $version
    url: $"($base)/($file)"
    sha512: ($sums | lines | parse "{sha512} sha512 {size} {file}" | where file == $file | first | get sha512)
  }
}

def pin [m: record] {
  let bin = ($m | get x86_64-linux)
  {version: $m.version, tarball: $bin.tarball, shasum: $bin.shasum}
}

def zig [] {
  pin (http get https://ziglang.org/download/index.json).master
}

def zls [zig_version: string, old: record] {
  let v = ($zig_version | url encode)
  let m = (http get $"https://releases.zigtools.org/v1/zls/select-version?zig_version=($v)&compatibility=full")
  if "message" in $m {
    print -e $"zls: ($m.message) - keeping ($old.version)"
    return $old
  }
  pin $m
}

def bun [] {
  let r = (http get https://api.github.com/repos/oven-sh/bun/releases/latest)
  let a = ($r.assets | where name == "bun-linux-x64.zip" | first)
  {
    version: ($r.tag_name | str replace "bun-v" "")
    shasum: ($a.digest | str replace "sha256:" "")
  }
}

def claude-code [] {
  let m = http get https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/next
  {version: $m.version, url: $m.dist.tarball, hash: $m.dist.integrity}
}

def main [] {
  let path = ($env.FILE_PWD | path join pins.json)
  let old = (open $path)
  let z = (zig)
  {firefox: (firefox), zig: $z, zls: (zls $z.version $old.zls), bun: (bun), claude-code: (claude-code)}
  | to json | $"($in)\n"
  | save -f $path
}
