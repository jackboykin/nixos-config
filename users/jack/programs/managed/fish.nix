{ theme, ... }:
let
  colors = theme.colors;
  strip = theme.rawHexValue;
in
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''

      set -l foreground ${strip colors.text}
      set -l selection  ${strip colors.surface1}
      set -l comment    ${strip colors.subtext0}
      set -l red        ${strip colors.red}
      set -l orange     ${strip colors.orange}
      set -l yellow     ${strip colors.yellow}
      set -l green      ${strip colors.green}
      set -l maroon     ${strip colors.maroon}
      set -l cyan       ${strip colors.cyan}
      set -l purple     ${strip colors.purple}

      set -g fish_color_normal $foreground
      set -g fish_color_command $green
      set -g fish_color_keyword $purple
      set -g fish_color_quote $yellow
      set -g fish_color_redirection $foreground
      set -g fish_color_end $orange
      set -g fish_color_option $purple
      set -g fish_color_error $red
      set -g fish_color_param $maroon
      set -g fish_color_comment $comment
      set -g fish_color_selection --background=$selection
      set -g fish_color_search_match --background=$selection
      set -g fish_color_operator $green
      set -g fish_color_escape $purple
      set -g fish_color_autosuggestion $comment

      set -g fish_pager_color_progress $comment
      set -g fish_pager_color_prefix $cyan
      set -g fish_pager_color_completion $foreground
      set -g fish_pager_color_description $comment
      set -g fish_pager_color_selected_background --background=$selection

      set -g fish_greeting

      bind \eh backward-word
      bind \el forward-word
    '';
  };
}
