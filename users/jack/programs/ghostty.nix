{
  lib,
  theme,
  ...
}: let
  inherit (theme) colors fonts;
  palette = lib.imap0 (i: c: "${toString i}=${c}") [
    colors.color0
    colors.color1
    colors.color2
    colors.color3
    colors.color4
    colors.color5
    colors.color6
    colors.color7
    colors.color8
    colors.color9
    colors.color10
    colors.color11
    colors.color12
    colors.color13
    colors.color14
    colors.color15
  ];
in {
  programs.ghostty = {
    enable = true;

    settings = {
      theme = "Bellatrix";
      font-family = fonts.mono.name;
      font-size = fonts.size.normal;
      window-decoration = "none";
      window-width = 143;
      window-height = 41;
      gtk-single-instance = true;
      linux-cgroup = "never";
    };

    themes.Bellatrix = {
      inherit palette;
      inherit (colors) background foreground;
    };
  };
}
