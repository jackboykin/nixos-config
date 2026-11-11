#!/usr/bin/env nu

const here = path self .

cd $here
let lint = nix eval --json --file ast-grep.nix | from json
let dir = $env.XDG_RUNTIME_DIR | path join ast-grep
let write = {|file, docs|
  $docs | each { to json --raw } | str join "\n---\n" | save --force ($dir | path join $file)
}

mkdir ($dir | path join rules) ($dir | path join tests)
do $write sgconfig.yml [{ruleDirs: [rules], testConfigs: [{testDir: tests}]}]
do $write rules/all.yml $lint.rules
do $write tests/all.yml $lint.tests
do $write fixes.yml ($lint.rules | where fix? != null)

let tests = ast-grep test --config ($dir | path join sgconfig.yml) --skip-snapshot-tests | complete
if $tests.exit_code != 0 { error make --unspanned {msg: $tests.stdout} }

alejandra --quiet .
ast-grep scan --rule ($dir | path join fixes.yml) --update-all .
alejandra --quiet .
ast-grep scan --rule ($dir | path join rules/all.yml) .
