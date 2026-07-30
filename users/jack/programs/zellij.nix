{theme, ...}: let
  inherit (theme) colors;
in {
  programs.zellij = {
    enable = true;

    settings = {
      theme = "custom";
      pane_frames = false;
      show_startup_tips = false;
      show_release_notes = false;

      themes.custom = {
        fg = colors.text;
        bg = colors.base;
        black = colors.color0;
        inherit (colors) red green yellow blue magenta cyan white orange;
      };
    };
  };
}
