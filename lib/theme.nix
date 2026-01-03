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

  # Bellatrix theme (v4 - Updated)
  # System: base16, Slug: bellatrix, Variant: dark
  colors = rec {
    # Neutral Base
    base00 = "#0b0a09"; # Background
    base01 = "#1a1716"; # Mantle
    base02 = "#2d2624"; # Surface / Selection
    base03 = "#9a8b94"; # Overlay / Comments
    base04 = "#7b6562"; # Muted Text
    base05 = "#dae4e4"; # Main Text
    base06 = "#e5e9ef"; # Bright Text
    base07 = "#fce4f0"; # Highlights

    # Accents
    red = "#ee0606"; # base08
    orange = "#ff5500"; # base09
    yellow = "#ff9000"; # base0A
    green = "#35de4f"; # base0B
    cyan = "#00ffff"; # base0C
    blue = "#0000ff"; # base0D
    magenta = "#e52195"; # base0E
    maroon = "#be5046"; # base0F

    # Explicit Descriptive Names
    sky = blue;
    teal = cyan;
    pink = magenta;
    purple = magenta;
    tan = base04;
    cream = base07;

    # Functional UI Roles (Dark Theme)
    base = base00;
    mantle = base01;
    crust = "#050403";
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
    brightRed = "#ff5500";
    brightOrange = orange;
    brightYellow = "#ffaf2f";
    brightGreen = "#7ed37d";
    brightCyan = "#2bb7c8";
    brightBlue = "#3c2dec";
    brightPurple = "#ec8cc5";

    highlight = base07;
  };
in
{
  rawHexValue = color: builtins.substring 1 6 color;

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
    sans = {
      name = "Lexend";
    };
    mono = {
      name = "JetBrainsMono Nerd Font Mono";
    };
  };
}
