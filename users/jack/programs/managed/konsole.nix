{ theme, ... }:
let
  c = theme.colors;
  # Konsole colorscheme expects "R,G,B"
  toRGB =
    hex:
    let
      # Remove # if present
      h = if builtins.substring 0 1 hex == "#" then builtins.substring 1 6 hex else hex;
      r = builtins.substring 0 2 h;
      g = builtins.substring 2 2 h;
      b = builtins.substring 4 2 h;
      # Convert hex to decimal using the same TOML trick as theme.nix
      dec = s: (builtins.fromTOML "a = 0x${s}").a;
    in
    "${toString (dec r)},${toString (dec g)},${toString (dec b)}";
in
{
  # Custom Color Scheme
  xdg.dataFile."konsole/BlackberryAquamarine.colorscheme".text = ''
    [General]
    Description=Blackberry Aquamarine
    Opacity=1
    Wallpaper=

    [Background]
    Color=${toRGB c.base}

    [BackgroundIntense]
    Color=${toRGB c.surface1}

    [Foreground]
    Color=${toRGB c.text}

    [ForegroundIntense]
    Color=${toRGB c.text}

    [Color0]
    Color=${toRGB c.base}

    [Color0Intense]
    Color=${toRGB c.overlay0}

    [Color1]
    Color=${toRGB c.red}

    [Color1Intense]
    Color=${toRGB c.purple}

    [Color2]
    Color=${toRGB c.green}

    [Color2Intense]
    Color=${toRGB c.teal}

    [Color3]
    Color=${toRGB c.yellow}

    [Color3Intense]
    Color=${toRGB c.orange}

    [Color4]
    Color=${toRGB c.blue}

    [Color4Intense]
    Color=${toRGB c.sky}

    [Color5]
    Color=${toRGB c.maroon}

    [Color5Intense]
    Color=${toRGB c.purple}

    [Color6]
    Color=${toRGB c.cyan}

    [Color6Intense]
    Color=${toRGB c.cyan}

    [Color7]
    Color=${toRGB c.text}

    [Color7Intense]
    Color=${toRGB c.text}
  '';

  # Custom Profile
  xdg.dataFile."konsole/BlackberryAquamarine.profile".text = ''
    [General]
    Name=BlackberryAquamarine
    Parent=FALLBACK/

    [Appearance]
    ColorScheme=BlackberryAquamarine
    Font=JetBrainsMono Nerd Font Mono,10,-1,5,50,0,0,0,0,0
  '';
}
