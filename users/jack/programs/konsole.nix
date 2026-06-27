{
  pkgs,
  theme,
  ...
}: let
  inherit (theme) colors;
  toRGB = hex: let
    rgb = theme.hexToRgb hex;
  in "${toString rgb.r},${toString rgb.g},${toString rgb.b}";

  colorscheme = ''
    [General]
    Description=Bellatrix
    Opacity=1
    Wallpaper=

    [Background]
    Color=${toRGB colors.background}

    [BackgroundIntense]
    Color=${toRGB colors.background}

    [Foreground]
    Color=${toRGB colors.foreground}

    [ForegroundIntense]
    Color=${toRGB colors.brightWhite}

    [Color0]
    Color=${toRGB colors.color0}

    [Color0Intense]
    Color=${toRGB colors.color8}

    [Color1]
    Color=${toRGB colors.color1}

    [Color1Intense]
    Color=${toRGB colors.color9}

    [Color2]
    Color=${toRGB colors.color2}

    [Color2Intense]
    Color=${toRGB colors.color10}

    [Color3]
    Color=${toRGB colors.color3}

    [Color3Intense]
    Color=${toRGB colors.color11}

    [Color4]
    Color=${toRGB colors.color4}

    [Color4Intense]
    Color=${toRGB colors.color12}

    [Color5]
    Color=${toRGB colors.color5}

    [Color5Intense]
    Color=${toRGB colors.color13}

    [Color6]
    Color=${toRGB colors.color6}

    [Color6Intense]
    Color=${toRGB colors.color14}

    [Color7]
    Color=${toRGB colors.color7}

    [Color7Intense]
    Color=${toRGB colors.color15}
  '';

  profile = ''
    [General]
    Command=${pkgs.fish}/bin/fish
    Name=Bellatrix
    Parent=FALLBACK/
    ShowTerminalSizeHint=false
    TerminalColumns=143
    TerminalRows=41

    [Appearance]
    ColorScheme=Bellatrix
    Font=${theme.fonts.mono.name},${toString theme.fonts.size.normal},-1,5,50,0,0,0,0,0
  '';

  konsolerc = ''
    MenuBar=Disabled

    [Desktop Entry]
    DefaultProfile=Bellatrix.profile

    [KonsoleWindow]
    RememberWindowSize=false
  '';
in {
  xdg = {
    dataFile."konsole/Bellatrix.colorscheme".text = colorscheme;
    dataFile."konsole/Bellatrix.profile".text = profile;
    configFile."konsolerc".text = konsolerc;
  };
}
