{
  lib,
  theme,
  ...
}: let
  inherit (theme) colors fonts ui;
in {
  programs.ghostty = {
    enable = true;

    settings = {
      theme = "bellatrix";
      font-family = [fonts.mono.name fonts.mono.fallback];
      font-size = fonts.size.normal;
      freetype-load-flags = "no-light,no-autohint";
      window-decoration = "none";
      window-width = 143;
      window-height = 41;
    };

    themes.bellatrix = {
      palette = map (i: "${toString i}=${colors."color${toString i}"}") (lib.range 0 15);
      inherit (colors) background foreground;
      cursor-color = ui.cursor;
      selection-background = ui.selection;
    };
  };
}
