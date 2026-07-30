{lib}:
with lib; let
  hexToRgb = hex: let
    hex' = removePrefix "#" (toLower hex);
    r = substring 0 2 hex';
    g = substring 2 2 hex';
    b = substring 4 2 hex';
    parseHex = s: (fromTOML "a = 0x${s}").a;
  in {
    r = parseHex r;
    g = parseHex g;
    b = parseHex b;
  };

  rgbToHex = rgb:
    "#"
    + concatStrings (
      map (
        x: let
          s = toLower (toHexString x);
        in
          if stringLength s == 1
          then "0" + s
          else s
      ) [rgb.r rgb.g rgb.b]
    );

  round = x: let
    floorVal = floor x;
    ceilVal = ceil x;
  in
    if (x - floorVal) < 0.5
    then floorVal
    else ceilVal;

  mixColors = color1: color2: factor: let
    c1 = hexToRgb color1;
    c2 = hexToRgb color2;
    mix = {
      r = round ((c1.r * factor) + (c2.r * (1.0 - factor)));
      g = round ((c1.g * factor) + (c2.g * (1.0 - factor)));
      b = round ((c1.b * factor) + (c2.b * (1.0 - factor)));
    };
  in
    rgbToHex mix;

  colors = rec {
    color0 = "#262320";
    color1 = "#e0707f";
    color2 = "#a9b58a";
    color3 = "#ffc799";
    color4 = "#8aa0b8";
    color5 = "#ff2d96";
    color6 = "#93c2bd";
    color7 = "#d7d2c8";
    color8 = "#6f6a60";
    color9 = "#ff8a99";
    color10 = "#c2cda3";
    color11 = "#ffd6b0";
    color12 = "#a6bcd4";
    color13 = "#ff5cae";
    color14 = "#b0dad5";
    color15 = "#ece8df";

    foreground = "#d7d2c8";
    background = "#0d0c0b";

    base00 = background;
    base01 = "#1a1817";
    base02 = color0;
    base03 = color8;
    base04 = "#8f897c";
    base05 = foreground;
    base07 = "#f4e4d2";

    black = color0;
    red = color1;
    green = color2;
    yellow = color3;
    blue = color4;
    magenta = color5;
    cyan = color6;
    white = color7;
    brightBlack = color8;
    brightRed = color9;
    brightGreen = color10;
    brightYellow = color11;
    brightBlue = color12;
    brightMagenta = color13;
    brightCyan = color14;
    brightWhite = color15;

    orange = "#ffae6a";
    maroon = orange;
    sky = blue;
    teal = cyan;
    purple = magenta;
    base = base00;
    mantle = base01;
    crust = "#060605";
    surface0 = base01;
    surface1 = base02;
    surface2 = base03;
    overlay0 = base01;
    overlay1 = base02;

    text = foreground;
    subtext1 = base04;
    subtext0 = base03;

    error = red;
    warning = yellow;
    info = blue;
    hint = cyan;

    gitAdded = magenta;
    gitModified = yellow;
    gitDeleted = red;

    highlight = base07;
  };
in {
  inherit colors mixColors hexToRgb;

  diff = {
    hunkHeader = mixColors colors.base colors.cyan 0.8;
    minusEmph = mixColors colors.base colors.red 0.6;
    minus = mixColors colors.base colors.red 0.8;
    plusEmph = mixColors colors.base colors.magenta 0.6;
    plus = mixColors colors.base colors.magenta 0.8;
    maroon = mixColors colors.base colors.maroon 0.6;
    blue = mixColors colors.base colors.blue 0.6;
    cyan = mixColors colors.base colors.cyan 0.6;
    yellow = mixColors colors.base colors.yellow 0.6;
  };

  ui = {
    findHighlight = mixColors colors.base colors.highlight 0.4;
    selection = mixColors colors.surface2 colors.base00 0.6;
    cursor = colors.magenta;
    activeBorder = colors.blue;
  };

  fonts = {
    size = {
      normal = 10;
      big = 14;
    };
    sans.name = "Inter";
    mono = {
      name = "JetBrainsMono Nerd Font Mono";
      fallback = "JuliaMono";
    };
  };
}
