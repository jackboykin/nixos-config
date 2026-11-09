let
  inherit (builtins) concatStringsSep elemAt floor genList substring;

  hexToRgb = hex: map (i: (fromTOML "a = 0x${substring i 2 hex}").a) [1 3 5];

  digit = n: substring n 1 "0123456789abcdef";
  byte = n: digit (n / 16) + digit (n - n / 16 * 16);

  mixColors = color1: color2: factor: let
    c1 = hexToRgb color1;
    c2 = hexToRgb color2;
    mix = i: floor (elemAt c1 i * factor + elemAt c2 i * (1.0 - factor) + 0.5);
  in
    "#" + concatStringsSep "" (genList (i: byte (mix i)) 3);

  colors = rec {
    background = "#0d0c0b";
    surface0 = "#1a1817";
    surface1 = "#262320";
    surface2 = "#6f6a60";
    subtext = "#8f897c";
    foreground = "#d7d2c8";

    red = "#e0707f";
    orange = "#ffae6a";
    yellow = "#ffc799";
    green = "#a9b58a";
    cyan = "#93c2bd";
    blue = "#8aa0b8";
    magenta = "#ff2d96";

    gitAdded = orange;
    gitModified = yellow;
    gitDeleted = magenta;
  };
in {
  inherit colors;
  rgb = hex: map toString (hexToRgb hex);

  ansi = with colors; [
    surface1
    red
    green
    yellow
    blue
    magenta
    cyan
    foreground
    surface2
    "#ff8a99"
    "#c2cda3"
    "#ffd6b0"
    "#a6bcd4"
    "#ff5cae"
    "#b0dad5"
    "#ece8df"
  ];

  diff = let
    tint = mixColors colors.background;
    line = 0.9;
    word = 0.7;
  in {
    added = tint colors.gitAdded line;
    addedEmph = tint colors.gitAdded word;
    removed = tint colors.gitDeleted line;
    removedEmph = tint colors.gitDeleted word;
    moved = tint colors.cyan 0.85;
  };

  ui.selection = mixColors colors.surface2 colors.background 0.6;

  fonts = {
    size = 10;
    sans = "Inter";
    mono = "JetBrainsMonoNL Nerd Font Mono";
  };
}
