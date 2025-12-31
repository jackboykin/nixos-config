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
      # hex-to-int
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

  # Blackberry Aquamarine theme (Custom)
  # Based on: Black (#070707), Blackberry Cream (#553555), Mauve Shadow (#755b69), Muted Teal (#96c5b0), Aquamarine (#adf1d2)
  # System: base16, Slug: blackberry-aquamarine, Variant: dark
  colors = rec {
    # Neutral Base
    base00 = "#070707"; # Background
    base01 = "#151515"; # Mantle
    base02 = "#2b1b2b"; # Surface / Selection (Derived from Blackberry Cream)
    base03 = "#553555"; # Overlay / Comments (Blackberry Cream)
    base04 = "#755b69"; # Muted Text (Mauve Shadow)
    base05 = "#96c5b0"; # Main Text (Muted Teal)
    base06 = "#adf1d2"; # Bright Text (Aquamarine)
    base07 = "#e0fdf0"; # Highlights

    # Accents
    red = "#ff6b8b"; # base08 (Vibrant Pink/Red)
    orange = "#d9a650"; # base09 (Gold)
    yellow = "#dae37a"; # base0A (Limey Yellow)
    green = "#adf1d2"; # base0B (Aquamarine)
    cyan = "#7fdbca"; # base0C
    blue = "#78a9ff"; # base0D
    magenta = "#c678dd"; # base0E
    maroon = "#755b69"; # base0F (Mauve Shadow)

    # Explicit Descriptive Names
    sky = blue;
    teal = cyan;
    pink = red;
    purple = magenta;
    tan = base04;
    cream = base06;

    # Functional UI Roles
    base = base00;
    mantle = base01;
    crust = "#000000"; # Pure black for this theme
    surface0 = base01;
    surface1 = "#3a253a"; # Mid-selection
    surface2 = base02;
    overlay0 = "#3a253a";
    overlay1 = base02;
    overlay2 = base03;

    text = base05;
    subtext1 = base04;
    subtext0 = base03;

    # Status & Diagnostics
    error = red;
    warning = orange;
    info = blue;
    hint = cyan;

    # Git Styles
    gitAdded = green;
    gitModified = orange;
    gitDeleted = red;

    # Extended Brights
    brightRed = "#ff8fa3";
    brightOrange = "#e8bd7d";
    brightGreen = base06;
    brightCyan = "#9eeade";
    brightBlue = "#a3c7ff";
    brightPurple = "#d9a1e9";

    highlight = base07;
  };
in
{
  rawHexValue = color: builtins.substring 1 6 color;

  inherit colors mixColors;

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
}
