#!/usr/bin/env nu

def firefox [] {
  let hub = http get https://firefox-ci-tc.services.mozilla.com/api/index/v1/task/gecko.v2.mozilla-central.shippable.latest.firefox.linux64-opt/artifacts/public/build/buildhub.json
  let t = ($hub.build.id | parse --regex '(?<y>\d{4})(?<mo>\d{2})(?<d>\d{2})(?<h>\d{2})(?<mi>\d{2})(?<s>\d{2})' | first)
  let base = $"https://archive.mozilla.org/pub/firefox/nightly/($t.y)/($t.mo)/($t.y)-($t.mo)-($t.d)-($t.h)-($t.mi)-($t.s)-mozilla-central"
  let file = $"firefox-($hub.target.version).en-US.linux-x86_64.tar.xz"
  let sums = http get $"($base)/firefox-($hub.target.version).en-US.linux-x86_64.checksums"
  {
    version: $hub.target.version
    url: $"($base)/($file)"
    sha512: ($sums | lines | parse "{sha512} sha512 {size} {file}" | where file == $file | first | get sha512)
  }
}

def zig [] {
  let m = (http get https://ziglang.org/download/index.json).master
  let bin = ($m | get x86_64-linux)
  {version: $m.version, tarball: $bin.tarball, shasum: $bin.shasum}
}

def bun [] {
  let img = ((http get https://hub.docker.com/v2/repositories/oven/bun/tags/canary-distroless).images | where architecture == amd64 | first)
  let token = (http get "https://auth.docker.io/token?service=registry.docker.io&scope=repository:oven/bun:pull").token
  let hdr = [Authorization $"Bearer ($token)" Accept "application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.v2+json"]
  let man = (http get -H $hdr $"https://registry-1.docker.io/v2/oven/bun/manifests/($img.digest)" | decode | from json)
  let cfg = (http get -H $hdr $"https://registry-1.docker.io/v2/oven/bun/blobs/($man.config.digest)" | decode | from json)
  {
    version: ($cfg.created | into datetime | format date canary-%Y%m%d)
    layer: ($man.layers | sort-by size | last | get digest)
  }
}

def claude-code [] {
  let m = http get https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/latest
  {version: $m.version, url: $m.dist.tarball, hash: $m.dist.integrity}
}

def main [] {
  {firefox: (firefox), zig: (zig), bun: (bun), claude-code: (claude-code)}
  | to json | $"($in)\n"
  | save -f ($env.FILE_PWD | path join pins.json)
}
