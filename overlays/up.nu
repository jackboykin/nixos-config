#!/usr/bin/env nu

const here = path self .

def sri [algo: string]: string -> string {
  $"($algo)-($in | decode hex | encode base64)"
}

def fetch [url: string] {
  curl -sSfL --connect-timeout 10 --speed-time 15 --speed-limit 1 --retry 2 --retry-all-errors $url
}

def --wrapped hush [cmd: string, ...args]: any -> string {
  let r = $in | ^$cmd ...$args | complete
  if $r.exit_code != 0 { error make -u {msg: $"($cmd): ($r.stderr | str trim)"} }
  $r.stdout
}

def key [name: string]: nothing -> string {
  $here | path join keys $name
}

def pgp [signer: string, sig: string]: any -> nothing {
  $in | hush sqop verify $sig (key $"($signer).asc") | ignore
}

def inline [signer: string]: any -> string {
  $in | hush sqop inline-verify (key $"($signer).asc")
}

def detached [signer: string, file: string, sig: string] {
  let s = mktemp -t
  fetch $sig | save -f $s
  open --raw $file | pgp $signer $s
  rm $s
}

def minisigned [signer: string, url: string, file: string] {
  let s = mktemp -t
  fetch $"($url).minisig" | save -f $s
  let comment = hush minisign -V -Q -p (key $"($signer).pub") -m $file -x $s
  rm $s
  let name = $comment | parse -r 'file:(?<name>[^\t\n]+)' | get 0?.name
  if $name != ($url | path basename) { error make -u {msg: $"signature is for ($name)"} }
}

def signed [url: string, algo: string, old, check: closure]: nothing -> string {
  if $url == $old.url? { return $old.hash }
  let f = hush nix store prefetch-file --json --hash-type $algo $url | from json
  do $check $f.storePath
  $f.hash
}

def pkt [line: string]: nothing -> string {
  let n = ($line | str length) + 4 | format number | get lowerhex | str substring 2..
  $"($n | fill -a right -c '0' -w 4)($line)"
}

def unband []: binary -> binary {
  mut rest = $in
  mut pack = 0x[]
  while ($rest | bytes length) >= 4 {
    let n = $rest | bytes at 0..<4 | decode | into int --radix 16
    let line = if $n > 4 { $rest | bytes at 4..<$n } else { 0x[] }
    $rest = $rest | bytes at ([$n 4] | math max)..
    if ($line | bytes starts-with 0x[01]) { $pack = $pack | bytes add --end ($line | bytes at 1..) }
    if ($line | bytes starts-with 0x[03]) { error make -u {msg: ($line | bytes at 1.. | decode)} }
  }
  $pack
}

def korg [repo: string, signer: string, --prefix: string = ""]: nothing -> record {
  let url = $"https://git.kernel.org/pub/scm/linux/kernel/git/($repo).git"
  let refs = ^git -c versionsort.suffix=-rc ls-remote --tags --sort=-v:refname $url $"($prefix)*" | lines | parse "{sha}\trefs/tags/{name}"
  let tag = $refs | where name !~ '\^\{\}$' | first
  let commit = $refs | where name == $"($tag.name)^{}" | first | get sha
  let hint = fetch $"($url)/commit/?id=($commit)" | parse -r "<th>tree</th><td[^>]*><a[^>]*>(?<sha>[0-9a-f]{40})" | first | get sha
  let request = [
    (pkt "command=fetch") "0001" (pkt "deepen 1\n") (pkt "no-progress\n")
    (pkt $"want ($tag.sha)\n") (pkt $"have ($hint)\n") (pkt "done\n") "0000"
  ]
  let pack = $request | str join | ^curl -sSf --max-filesize 1M -H "Content-Type: application/x-git-upload-pack-request" -H "Git-Protocol: version=2" --data-binary @- $"($url)/git-upload-pack" | into binary | unband
  let git = mktemp -d
  hush git init -q $git
  $pack | hush git -C $git index-pack --stdin
  let marker = "-----BEGIN PGP SIGNATURE-----"
  let parts = hush git -C $git cat-file tag $tag.sha | split row $marker
  if ($parts | length) != 2 { error make -u {msg: $"($tag.name) is not signed"} }
  $"($marker)($parts.1)" | save -f $"($git)/sig"
  $parts.0 | pgp $signer $"($git)/sig"
  let head = $parts.0 | lines | take until { is-empty } | parse "{k} {v}" | transpose -rd
  if $head.tag != $tag.name or $head.type != commit { error make -u {msg: $"($tag.name): signed tag names ($head.type) ($head.tag)"} }
  let tree = hush git -C $git cat-file commit $head.object | lines | first | parse "tree {sha}" | get 0.sha
  rm -r $git
  {version: ($tag.name | str replace -r $"^($prefix)" ""), hash: ($tree | sri sha1)}
}

def gh-release [repo: string, --pre]: nothing -> record {
  fetch $"https://api.github.com/repos/($repo)/releases" | from json | where prerelease == $pre | first
}

def bun [] {
  let r = gh-release oven-sh/bun
  let base = $"https://github.com/oven-sh/bun/releases/download/($r.tag_name)"
  let file = "bun-linux-x64.zip"
  let sums = fetch $"($base)/SHASUMS256.txt.asc" | inline bun
  {
    version: ($r.tag_name | str replace -r '^\D+' "")
    url: $"($base)/($file)"
    hash: ($sums | lines | parse "{sha}  {name}" | where name == $file | first | get sha | sri sha256)
  }
}

def zed [] {
  let r = gh-release --pre zed-industries/zed
  let a = $r.assets | where name == zed-linux-x86_64.tar.gz | first
  {
    version: ($r.tag_name | str replace -r '^\D+' "")
    url: $a.browser_download_url
    hash: ($a.digest | str replace "sha256:" "" | sri sha256)
  }
}

def claude-code [] {
  let base = "https://downloads.claude.ai/claude-code-releases"
  let next = fetch https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/next | from json | get version
  let version = [$next (fetch $"($base)/latest" | str trim)] | sort --natural | last
  let m = mktemp -t
  fetch $"($base)/($version)/manifest.json" | save -f $m
  detached anthropic $m $"($base)/($version)/manifest.json.sig"
  let manifest = open --raw $m | from json
  rm $m
  if $manifest.version != $version { error make -u {msg: $"manifest is for ($manifest.version)"} }
  {
    version: $version
    url: $"($base)/($version)/linux-x64/claude"
    hash: ($manifest.platforms.linux-x64.checksum | sri sha256)
  }
}

def firefox [old] {
  let root = "https://archive.mozilla.org/pub/firefox/nightly"
  let version = fetch https://product-details.mozilla.org/1.0/firefox_versions.json | from json | get FIREFOX_NIGHTLY
  let stem = $"firefox-($version).en-US.linux-x86_64"
  let stamp = fetch $"($root)/latest-mozilla-central/($stem).json" | from json | get buildid | into datetime -f "%Y%m%d%H%M%S" | format date "%Y/%m/%Y-%m-%d-%H-%M-%S"
  let url = $"($root)/($stamp)-mozilla-central/($stem).tar.xz"
  {
    version: $version
    url: $url
    hash: (signed $url sha512 $old {|f| detached mozilla $f $"($url).asc" })
  }
}

def linux [] {
  let t = korg torvalds/linux torvalds --prefix v
  {
    version: $t.version
    url: $"https://git.kernel.org/torvalds/t/linux-($t.version).tar.gz"
    hash: $t.hash
  }
}

def linux-firmware [] {
  let t = korg firmware/linux-firmware jwboyer
  {
    version: $t.version
    url: $"https://gitlab.com/kernel-firmware/linux-firmware/-/archive/($t.version)/linux-firmware-($t.version).tar.gz"
    hash: $t.hash
  }
}

def zigpin [m: record, signer: string, old]: nothing -> record {
  let url = $m | get x86_64-linux.tarball
  {
    version: $m.version
    url: $url
    hash: (signed $url sha256 $old {|f| minisigned $signer $url $f })
  }
}

def zig-index [] {
  let index = fetch https://ziglang.org/download/index.json | from json
  let stable = $index | reject master | columns | sort -n | last
  {stable: ($index | get $stable), nightly: $index.master}
}

def zls [zig_version: string, old: record] {
  let v = $zig_version | url encode
  let m = fetch $"https://releases.zigtools.org/v1/zls/select-version?zig_version=($v)&compatibility=full" | from json
  if "message" in $m {
    print -e $"(ansi yellow)  zls: ($m.message)(ansi reset)"
    return $old
  }
  zigpin $m zls $old
}

def line [name: string, width: int, was, now: record]: nothing -> string {
  let n = $name | fill -w $width
  if $now.url == $was.url? {
    $"(ansi dark_gray)  ($n)  ($now.version)(ansi reset)"
  } else {
    $"  (ansi cyan)($n)(ansi reset)  ($was.version? | default new) (ansi green)→ ($now.version)(ansi reset)"
  }
}

def parallel [old: record, pins: record]: nothing -> record {
  let width = $pins | columns | each { str length } | math max
  $pins | transpose name fetch | par-each --keep-order {|p|
    let v = try { do $p.fetch } catch {|e| error make -u {msg: $"($p.name): ($e.msg)"} }
    print (line $p.name $width ($old | get -o $p.name) $v)
    {$p.name: $v}
  } | into record
}

def main [] {
  let path = $here | path join pins.json
  let old = open $path
  let z = zig-index
  let new = parallel $old {
    bun: {|| bun}
    claude-code: {|| claude-code}
    firefox: {|| firefox ($old | get -o firefox)}
    linux: {|| linux}
    linux-firmware: {|| linux-firmware}
    zed: {|| zed}
    zig: {|| zigpin $z.stable zig ($old | get -o zig)}
    zig-nightly: {|| zigpin $z.nightly zig ($old | get -o zig-nightly)}
    zls: {|| zls $z.stable.version $old.zls}
  }
  $new | to json | $"($in)\n" | save -f $path
}
