{
  pkgs,
  theme,
  ...
}:
let
  colors = theme.colors;
  # Konsole colorscheme expects "R,G,B"
  toRGB =
    hex:
    let
      rgb = theme.hexToRgb hex;
    in
    "${toString rgb.r},${toString rgb.g},${toString rgb.b}";
in
{
  # Custom Color Scheme
  xdg.dataFile."konsole/Bellatrix.colorscheme".text = ''
    [General]
    Description=Bellatrix
    Opacity=1
    Wallpaper=

    [Background]
    Color=${toRGB colors.base}

    [BackgroundIntense]
    Color=${toRGB colors.surface1}

    [Foreground]
    Color=${toRGB colors.text}

    [ForegroundIntense]
    Color=${toRGB colors.text}

    [Color0]
    Color=${toRGB colors.base}

    [Color0Intense]
    Color=${toRGB colors.overlay0}

    [Color1]
    Color=${toRGB colors.red}

    [Color1Intense]
    Color=${toRGB colors.purple}

    [Color2]
    Color=${toRGB colors.green}

    [Color2Intense]
    Color=${toRGB colors.teal}

    [Color3]
    Color=${toRGB colors.yellow}

    [Color3Intense]
    Color=${toRGB colors.orange}

    [Color4]
    Color=${toRGB colors.blue}

    [Color4Intense]
    Color=${toRGB colors.sky}

    [Color5]
    Color=${toRGB colors.maroon}

    [Color5Intense]
    Color=${toRGB colors.purple}

    [Color6]
    Color=${toRGB colors.cyan}

    [Color6Intense]
    Color=${toRGB colors.cyan}

    [Color7]
    Color=${toRGB colors.text}

    [Color7Intense]
    Color=${toRGB colors.text}
  '';

  # Custom Profile
  xdg.dataFile."konsole/Bellatrix.profile".text = ''
    [General]
    Command=${pkgs.fish}/bin/fish
    Name=Bellatrix
    Parent=FALLBACK/

    [Appearance]
    ColorScheme=Bellatrix
    Font=JetBrainsMono Nerd Font Mono,10,-1,5,50,0,0,0,0,0
  '';
}
