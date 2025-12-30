# Tokyo Night color theme - https://github.com/enkia/tokyo-night-vscode-theme
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

  # Official Tokyo Night color palette
  colors = {
    # Accent colors
    red = "#f7768e";
    orange = "#ff9e64";
    yellow = "#e0af68";
    green = "#9ece6a";
    teal = "#73daca";
    cyan = "#7dcfff";
    blue = "#7aa2f7";
    magenta = "#bb9af7";
    pink = "#ff007c";

    # Semantic colors
    error = "#f7768e";
    warning = "#e0af68";
    info = "#7dcfff";
    hint = "#73daca";

    # Foreground colors
    text = "#c0caf5";
    subtext1 = "#a9b1d6";
    subtext0 = "#9aa5ce";
    overlay2 = "#787c99";
    overlay1 = "#6b7089";
    overlay0 = "#545c7e";

    # Background colors
    surface2 = "#3b4261";
    surface1 = "#292e42";
    surface0 = "#24283b";
    base = "#1a1b26";
    mantle = "#16161e";
    crust = "#13131a";

    # Git colors
    gitAdded = "#449dab";
    gitModified = "#6183bb";
    gitDeleted = "#914c54";

    # Additional Tokyo Night accent colors
    purple = "#9d7cd8";
    darkBlue = "#3d59a1";
    lightBlue = "#89ddff";
    darkCyan = "#2ac3de";
    darkGreen = "#41a6b5";
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
    findHighlight = mixColors colors.base colors.cyan 0.5;
    selection = colors.surface1;
    cursor = colors.text;
    activeBorder = colors.darkBlue;
  };
}
