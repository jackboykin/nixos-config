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
    color0 = "#36302f";
    color1 = "#ee0606";
    color2 = "#35de4f";
    color3 = "#ff9000";
    color4 = "#286ef1";
    color5 = "#e52195";
    color6 = "#22e1ef";
    color7 = "#dae4e4";
    color8 = "#9a8b94";
    color9 = "#ff5500";
    color10 = "#7ed37d";
    color11 = "#ffaf2f";
    color12 = "#6357f9";
    color13 = "#ec8cc5";
    color14 = "#69e8c8";
    color15 = "#e5e9ef";

    foreground = "#dae4e4";
    background = "#0b0a09";
    cursorColor = "#dae4e4";

    base00 = background;
    base01 = "#1a1716";
    base02 = color0;
    base03 = color8;
    base04 = "#7b6562";
    base05 = foreground;
    base06 = color15;
    base07 = "#fce4f0";

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

    orange = color9;
    maroon = color9;
    sky = blue;
    teal = cyan;
    pink = magenta;
    purple = brightBlue;
    tan = base04;
    cream = base07;

    base = base00;
    mantle = base01;
    crust = "#050403";
    surface0 = base01;
    surface1 = base02;
    surface2 = base03;
    overlay0 = base01;
    overlay1 = base02;
    overlay2 = base03;

    text = foreground;
    subtext1 = base04;
    subtext0 = base03;

    error = red;
    warning = yellow;
    info = blue;
    hint = cyan;

    gitAdded = green;
    gitModified = yellow;
    gitDeleted = red;

    brightOrange = brightYellow;
    brightPurple = brightMagenta;
    highlight = base07;
  };
in {
  rawHexValue = color: substring 1 6 color;
  inherit colors mixColors hexToRgb;

  diff = {
    hunkHeader = mixColors colors.base colors.purple 0.8;
    minusEmph = mixColors colors.base colors.red 0.6;
    minus = mixColors colors.base colors.red 0.8;
    plusEmph = mixColors colors.base colors.green 0.6;
    plus = mixColors colors.base colors.green 0.8;
    maroon = mixColors colors.base colors.maroon 0.6;
    blue = mixColors colors.base colors.blue 0.6;
    cyan = mixColors colors.base colors.cyan 0.6;
    yellow = mixColors colors.base colors.yellow 0.6;
  };

  ui = {
    findHighlight = mixColors colors.base colors.highlight 0.4;
    selection = mixColors colors.surface2 colors.purple 0.3;
    cursor = colors.text;
    activeBorder = colors.blue;
  };

  fonts = {
    size = {
      normal = 10;
      big = 14;
    };
    sans.name = "Lexend";
    mono.name = "JetBrainsMono Nerd Font Mono";
  };
}
