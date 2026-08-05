{
  pkgs,
  lib,
  theme,
  ...
}: let
  inherit (theme) colors;

  unbold =
    lib.genAttrs [
      "binary_printable"
      "glob"
      "semver"
      "semver-range"
      "shape_datetime"
      "shape_glob_interpolation"
      "shape_globpattern"
      "shape_internalcall"
      "shape_keyword"
      "shape_list"
      "shape_record"
      "shape_string_interpolation"
    ] (_: "cyan")
    // lib.genAttrs [
      "binary_whitespace"
      "closure"
      "header"
      "shape_closure"
      "shape_externalarg"
      "shape_signature"
    ] (_: "green")
    // lib.genAttrs [
      "binary_ascii_other"
      "shape_binary"
      "shape_float"
      "shape_int"
      "shape_pipe"
      "shape_redirection"
    ] (_: "purple")
    // lib.genAttrs ["shape_block" "shape_flag" "shape_table"] (_: "blue")
    // lib.genAttrs ["binary_non_ascii" "shape_range"] (_: "yellow");

  colorConfig =
    unbold
    // {
      row_index = colors.subtext0;
      separator = colors.surface2;
      search_result = ''{fg: "${colors.base}", bg: "${colors.yellow}"}'';
      shape_external = colors.red;
      shape_external_resolved = colors.cyan;
      shape_garbage = colors.red;
    };

  toNu = v:
    if lib.hasPrefix "{" v
    then v
    else ''"${v}"'';

  aliases = {
    q = "exit";
    nr = "nh os switch";
    nru = "nh os switch -u";
    nb = "nh os boot";
    nbu = "nh os boot -u";
    cf = ''claude --dangerously-skip-permissions --system-prompt=""'';
    cfw = ''claude --dangerously-skip-permissions --system-prompt="" --settings '{"disableWorkflows": false}' '';
    eza = "eza --icons auto --git";
    l = "eza --icons -la --no-user --no-time --no-permissions --git --group-directories-first";
    lr = "eza --icons -laR --git-ignore --git --no-user --no-time --no-permissions --group-directories-first";
    t = "eza --icons --tree --git-ignore";
  };
in {
  programs.nushell.enable = true;

  home.links = {
    ".config/nushell/env.nu" = pkgs.writeText "env.nu" ''
      $env.PATH = ($env.PATH | append [
          $"($env.HOME)/.cargo/bin"
          $"($env.HOME)/.local/bin"
      ] | uniq)
    '';

    ".config/nushell/config.nu" = pkgs.writeText "config.nu" ''
      $env.config.show_banner = false
      $env.config.history.file_format = "sqlite"
      $env.config.completions.algorithm = "fuzzy"
      $env.config.highlight_resolved_externals = true

      $env.config.color_config = ($env.config.color_config | merge {
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "    ${k}: ${toNu v}") colorConfig)}
      })

      $env.PROMPT_COMMAND = {||
          let dir = if ($env.PWD | str starts-with $nu.home-dir) {
              $env.PWD | str replace $nu.home-dir "~"
          } else { $env.PWD }
          let branch = (try { git --no-optional-locks symbolic-ref --quiet --short HEAD err> /dev/null } | default "" | str trim)
          let git = if $branch == "" { "" } else { $" (ansi --escape {fg: "${colors.subtext0}"})($branch)" }
          $"(ansi --escape {fg: "${colors.blue}"})($dir)($git)(ansi reset)"
      }
      $env.PROMPT_COMMAND_RIGHT = ""
      $env.PROMPT_INDICATOR = {||
          let color = if $env.LAST_EXIT_CODE == 0 { "${colors.magenta}" } else { "${colors.red}" }
          $" (ansi --escape {fg: ($color)})❯(ansi reset) "
      }

      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: ''alias "${k}" = ${lib.removeSuffix " " v}'') aliases)}
    '';
  };
}
