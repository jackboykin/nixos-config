# Wombat Base24 color theme by FredHappyface
# https://github.com/fredHappyface
{ lib }:
with lib;
let
  hexToRgb =
    hex:
    let
      hex' = removePrefix "#" (toLower hex);
      r = substring 0 2 hex';
      g = substring 2 2 hex';
      b = substring 4 2 hex';
      # Trick: use TOML parser to convert hex string to integer
      parseHex = s: (builtins.fromTOML "a = 0x${s}").a;
    in
    {
      r = parseHex r;
      g = parseHex g;
      b = parseHex b;
    };

  rgbToHex =
    rgb:
    "#"
    + concatStrings (
      map
        (
          x:
          let
            s = toLower (toHexString x);
          in
          if stringLength s == 1 then "0" + s else s
        )
        [
          rgb.r
          rgb.g
          rgb.b
        ]
    );

  round =
    x:
    let
      floor = builtins.floor x;
      ceil = builtins.ceil x;
    in
    if (x - floor) < 0.5 then floor else ceil;

  mixColors =
    color1: color2: factor:
    let
      c1 = hexToRgb color1;
      c2 = hexToRgb color2;
      mix = {
        r = round ((c1.r * factor) + (c2.r * (1.0 - factor)));
        g = round ((c1.g * factor) + (c2.g * (1.0 - factor)));
        b = round ((c1.b * factor) + (c2.b * (1.0 - factor)));
      };
    in
    rgbToHex mix;

  # Wombat Base24 palette (dark variant)
  colors = {
    # Base24 core palette
    base00 = "#0f0c0c"; # Default Background
    base01 = "#000000"; # Lighter Background
    base02 = "#313131"; # Selection Background
    base03 = "#5c5b58"; # Comments, Invisibles
    base04 = "#87857f"; # Dark Foreground
    base05 = "#b2afa6"; # Default Foreground
    base06 = "#ded9ce"; # Light Foreground
    base07 = "#fefffe"; # Light Background
    base08 = "#ff605a"; # Red (Variables)
    base09 = "#ead89c"; # Orange (Integers, Constants)
    base0A = "#a5c7ff"; # Yellow (Classes)
    base0B = "#b1e869"; # Green (Strings)
    base0C = "#82fff6"; # Cyan (Support, Regex)
    base0D = "#5da9f6"; # Blue (Functions, Methods)
    base0E = "#e86aff"; # Magenta (Keywords)
    base0F = "#7f302d"; # Brown (Deprecated)

    # Semantic accent mappings
    red = "#ff605a";
    orange = "#ead89c";
    yellow = "#a5c7ff";
    green = "#b1e869";
    teal = "#82fff6";
    cyan = "#82fff6";
    blue = "#5da9f6";
    magenta = "#e86aff";
    pink = "#e86aff";
    purple = "#7f302d";

    # Semantic colors
    error = "#ff605a";
    warning = "#ead89c";
    info = "#5da9f6";
    hint = "#82fff6";

    # Foreground colors
    text = "#b2afa6";
    subtext1 = "#87857f";
    subtext0 = "#5c5b58";
    overlay2 = "#87857f";
    overlay1 = "#5c5b58";
    overlay0 = "#313131";

    # Background colors
    surface2 = "#5c5b58";
    surface1 = "#313131";
    surface0 = "#000000";
    base = "#0f0c0c";
    mantle = "#0d0d0d";
    crust = "#000000";

    # Git colors
    gitAdded = "#b1e869";
    gitModified = "#ead89c";
    gitDeleted = "#ff605a";

    # Additional accent colors (legacy mapping compatibility)
    darkBlue = "#3d7ac4";
    lightBlue = "#5da9f6";
    darkCyan = "#52ccc4";
    darkGreen = "#8fba54";

    # Contrast accents
    mint = "#82fff6";
    sky = "#a5c7ff";
    amber = "#ead89c";
    vibrantPurple = "#e86aff";

    # Highlight color for search/matches
    highlight = "#fefffe";

    # Legacy compatibility aliases
    darkMagenta = "#e86aff";
    deepPink = "#ff605a";
    blushPop = "#ded9ce";
    oldRose = "#87857f";
    blackberryCream = "#313131";
    darkGrown = "#0f0c0c";
  };
in
{
  rawHexValue = color: builtins.substring 1 6 color;

  inherit colors mixColors;

  diff = {
    hunkHeader = mixColors colors.base colors.magenta 0.8;
    minusEmph = mixColors colors.base colors.red 0.6;
    minus = mixColors colors.base colors.red 0.8;
    plusEmph = mixColors colors.base colors.green 0.6;
    plus = mixColors colors.base colors.green 0.8;
    purple = mixColors colors.base colors.purple 0.6;
    blue = mixColors colors.base colors.blue 0.6;
    cyan = mixColors colors.base colors.cyan 0.6;
    yellow = mixColors colors.base colors.yellow 0.6;
  };

  ui = {
    findHighlight = mixColors colors.base colors.highlight 0.4;
    selection = mixColors colors.surface1 colors.magenta 0.3;
    cursor = colors.blushPop;
    activeBorder = colors.vibrantPurple;
  };
}
