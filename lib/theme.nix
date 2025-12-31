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

  # Colors theme
  # Author: mrmrs (http://clrs.cc)
  # System: base16, Slug: colors, Variant: dark
  colors = rec {
    # Neutral Base
    base00 = "#111111"; # Background
    base01 = "#333333"; # Mantle
    base02 = "#555555"; # Surface / Selection
    base03 = "#777777"; # Overlay / Comments
    base04 = "#999999"; # Muted Text
    base05 = "#bbbbbb"; # Main Text
    base06 = "#dddddd"; # Bright Text
    base07 = "#ffffff"; # Highlights

    # Accents
    red = "#ff4136"; # base08
    orange = "#ff851b"; # base09
    yellow = "#ffdc00"; # base0A
    green = "#2ecc40"; # base0B
    cyan = "#7fdbff"; # base0C
    blue = "#0074d9"; # base0D
    magenta = "#b10dc9"; # base0E
    maroon = "#85144b"; # base0F

    # Explicit Descriptive Names
    sky = blue;
    teal = cyan;
    pink = red;
    purple = magenta;
    tan = base04;
    cream = base07;

    # Functional UI Roles (Dark Theme)
    base = base00;
    mantle = base01;
    crust = "#080808";
    surface0 = base01;
    surface1 = base02;
    surface2 = base03;
    overlay0 = base01;
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
    brightRed = red;
    brightOrange = orange;
    brightGreen = green;
    brightCyan = cyan;
    brightBlue = blue;
    brightPurple = magenta;

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
