{theme, ...}: let
  c = theme.colors;
  strip = theme.rawHexValue;
in {
  programs.fish = {
    enable = true;

    interactiveShellInit = ''

      set -l foreground ${strip c.text}
      set -l selection  ${strip c.surface1}
      set -l comment    ${strip c.overlay0}
      set -l red        ${strip c.red}
      set -l cream      ${strip c.cream}
      set -l periwinkle ${strip c.periwinkle}
      set -l green      ${strip c.green}
      set -l maroon     ${strip c.maroon}
      set -l cyan       ${strip c.cyan}
      set -l pink       ${strip c.magenta}

      set -g fish_color_normal $foreground
      set -g fish_color_command $green
      set -g fish_color_keyword $pink
      set -g fish_color_quote $periwinkle
      set -g fish_color_redirection $foreground
      set -g fish_color_end $cream
      set -g fish_color_option $pink
      set -g fish_color_error $red
      set -g fish_color_param $maroon
      set -g fish_color_comment $comment
      set -g fish_color_selection --background=$selection
      set -g fish_color_search_match --background=$selection
      set -g fish_color_operator $green
      set -g fish_color_escape $pink
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
