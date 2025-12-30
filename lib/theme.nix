{lib}:
with lib; let
  hexToRgb = hex: let
    hex' = removePrefix "#" (toLower hex);
    r = substring 0 2 hex';
    g = substring 2 2 hex';
    b = substring 4 2 hex';
    # hex-to-int
    parseHex = s: (builtins.fromTOML "a = 0x${s}").a;
  in {
    r = parseHex r;
    g = parseHex g;
    b = parseHex b;
  };

  rgbToHex = rgb:
    "#"
    + concatStrings (
      map
      (
        x: let
          s = toLower (toHexString x);
        in
          if stringLength s == 1
          then "0" + s
          else s
      )
      [
        rgb.r
        rgb.g
        rgb.b
      ]
    );

  round = x: let
    floor = builtins.floor x;
    ceil = builtins.ceil x;
  in
    if (x - floor) < 0.5
    then floor
    else ceil;

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

  colors = {
    base00 = "#0f0c0c";
    base01 = "#000000";
    base02 = "#313131";
    base03 = "#5c5b58";
    base04 = "#87857f";
    base05 = "#b2afa6";
    base06 = "#ded9ce";
    base07 = "#fefffe";
    base08 = "#ff605a";
    base09 = "#ead89c";
    base0A = "#a5c7ff";
    base0B = "#b1e869";
    base0C = "#82fff6";
    base0D = "#5da9f6";
    base0E = "#e86aff";
    base0F = "#7f302d";

    red = "#ff605a";
    cream = "#ead89c";
    periwinkle = "#a5c7ff";
    green = "#b1e869";
    teal = "#82fff6";
    cyan = "#82fff6";
    blue = "#5da9f6";
    magenta = "#e86aff";
    pink = "#e86aff";
    maroon = "#7f302d";

    error = "#ff605a";
    warning = "#ead89c";
    info = "#5da9f6";
    hint = "#82fff6";

    text = "#b2afa6";
    subtext1 = "#87857f";
    subtext0 = "#5c5b58";
    overlay2 = "#87857f";
    overlay1 = "#5c5b58";
    overlay0 = "#313131";

    surface2 = "#5c5b58";
    surface1 = "#313131";
    surface0 = "#000000";
    base = "#0f0c0c";
    mantle = "#0d0d0d";
    crust = "#000000";

    gitAdded = "#b1e869";
    gitModified = "#ead89c";
    gitDeleted = "#ff605a";

    darkBlue = "#3d7ac4";
    lightBlue = "#5da9f6";
    darkCyan = "#52ccc4";
    darkGreen = "#8fba54";

    mint = "#82fff6";
    sky = "#a5c7ff";
    amber = "#ead89c";
    vibrantPurple = "#e86aff";

    highlight = "#fefffe";

    darkMagenta = "#e86aff";
    deepPink = "#ff605a";
    blushPop = "#ded9ce";
    oldRose = "#87857f";
    blackberryCream = "#313131";
    darkGrown = "#0f0c0c";
  };
in {
  rawHexValue = color: builtins.substring 1 6 color;

  inherit colors mixColors;

  diff = {
    hunkHeader = mixColors colors.base colors.magenta 0.8;
    minusEmph = mixColors colors.base colors.red 0.6;
    minus = mixColors colors.base colors.red 0.8;
    plusEmph = mixColors colors.base colors.green 0.6;
    plus = mixColors colors.base colors.green 0.8;
    maroon = mixColors colors.base colors.maroon 0.6;
    blue = mixColors colors.base colors.blue 0.6;
    cyan = mixColors colors.base colors.cyan 0.6;
    periwinkle = mixColors colors.base colors.periwinkle 0.6;
  };

  ui = {
    findHighlight = mixColors colors.base colors.highlight 0.4;
    selection = mixColors colors.surface1 colors.magenta 0.3;
    cursor = colors.blushPop;
    activeBorder = colors.vibrantPurple;
  };
}
