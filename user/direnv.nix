{
  lib,
  pkgs,
  ...
}: {
  programs.direnv = {
    enable = true;
    silent = true;
  };

  programs.nushell.autoloads = [
    (pkgs.writeTextDir "share/nushell/vendor/autoload/40-direnv.nu" ''
      $env.config.hooks.pre_prompt = (
          $env.config.hooks.pre_prompt? | default [] | append {||
              let exported = (${lib.getExe pkgs.direnv} export json | from json --strict | default {})

              for key in ($exported | columns) {
                  if ($exported | get $key) == null { hide-env --ignore-errors $key }
              }

              $exported
              | items {|key, value|
                  if $key == "PATH" {
                      [$key ($value | split row (char esep) | path expand --no-symlink)]
                  } else {
                      [$key $value]
                  }
              }
              | where {|pair| $pair.1 != null }
              | into record
              | load-env
          }
      )
    '')
  ];
}
