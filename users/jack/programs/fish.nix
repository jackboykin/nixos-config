{
  theme,
  lib,
  ...
}: let
  inherit (theme) colors;
  strip = lib.removePrefix "#";
in {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting

      set -g fish_color_normal         ${strip colors.text}
      set -g fish_color_command        ${strip colors.green}
      set -g fish_color_keyword        ${strip colors.purple}
      set -g fish_color_quote          ${strip colors.yellow}
      set -g fish_color_end            ${strip colors.orange}
      set -g fish_color_option         ${strip colors.purple}
      set -g fish_color_error          ${strip colors.red}
      set -g fish_color_param          ${strip colors.brightMagenta}
      set -g fish_color_comment        ${strip colors.subtext0}
      set -g fish_color_operator       ${strip colors.green}
      set -g fish_color_escape         ${strip colors.purple}
      set -g fish_color_autosuggestion ${strip colors.subtext0}
      set -g fish_color_selection      --background=${strip colors.surface1}
      set -g fish_color_search_match   --background=${strip colors.surface1}

      set -g fish_pager_color_prefix              ${strip colors.cyan}
      set -g fish_pager_color_completion          ${strip colors.text}
      set -g fish_pager_color_description         ${strip colors.subtext0}
      set -g fish_pager_color_progress            ${strip colors.subtext0}
      set -g fish_pager_color_selected_background --background=${strip colors.surface1}
    '';
  };
}
