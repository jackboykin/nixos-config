{
  config,
  lib,
  theme,
  ...
}: let
  inherit (theme) colors;
  inherit (lib.hm.nushell) mkNushellInline;
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
  sessionPath =
    map (lib.replaceStrings ["$HOME"] [config.home.homeDirectory])
    config.home.sessionPath;
in {
  programs.nushell = {
    enable = true;

    settings = {
      show_banner = false;
      history.file_format = "sqlite";
      completions.algorithm = "fuzzy";
      highlight_resolved_externals = true;

      color_config =
        unbold
        // {
          row_index = colors.subtext0;
          separator = colors.surface2;
          search_result = mkNushellInline ''{fg: "${colors.base}", bg: "${colors.yellow}"}'';
          shape_external = colors.red;
          shape_external_resolved = colors.cyan;
          shape_garbage = colors.red;
        };
    };

    environmentVariables = config.home.sessionVariables;

    extraEnv = ''
      $env.PATH = ($env.PATH | append ${lib.hm.nushell.toNushell {} sessionPath} | uniq)
    '';

    extraConfig = ''
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
    '';
  };
}
