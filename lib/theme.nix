{lib}:
with lib; let
  hexToRgb = hex: let
    hex' = removePrefix "#" (toLower hex);
    r = substring 0 2 hex';
    g = substring 2 2 hex';
    b = substring 4 2 hex';
    # Trick: use TOML parser to convert hex string to integer
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
    rosewater = "#de9d9d";
    flamingo = "#dea89d";
    pink = "#b294bb";
    mauve = "#9d8bb8";
    red = "#cc6666";
    maroon = "#c67d7d";
    peach = "#de935f";
    yellow = "#f0c674";
    green = "#b5bd68";
    teal = "#8abeb7";
    sky = "#95b3c9";
    sapphire = "#7ea9b8";
    blue = "#81a2be";
    lavender = "#9db5c9";
    text = "#c5c8c6";
    subtext1 = "#a8aba9";
    subtext0 = "#8b8d8b";
    overlay2 = "#6f7271";
    overlay1 = "#5a5c5b";
    overlay0 = "#4d5057";
    surface2 = "#3a3c3f";
    surface1 = "#373b41";
    surface0 = "#282a2e";
    base = "#1d1f21";
    mantle = "#161719";
    crust = "#0f1011";
  };
in {
  rawHexValue = color: builtins.substring 1 6 color;

  inherit colors mixColors;

  diff = {
    hunkHeader = mixColors colors.base colors.mauve 0.8;
    minusEmph = mixColors colors.base colors.red 0.6;
    minus = mixColors colors.base colors.red 0.8;
    plusEmph = mixColors colors.base colors.green 0.6;
    plus = mixColors colors.base colors.green 0.8;
    purple = mixColors colors.base colors.mauve 0.6;
    blue = mixColors colors.base colors.blue 0.6;
    cyan = mixColors colors.base colors.teal 0.6;
    yellow = mixColors colors.base colors.yellow 0.6;
  };

  ui = {
    findHighlight = mixColors colors.base colors.sky 0.5;
  };
}
