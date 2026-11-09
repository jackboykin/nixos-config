{
  lib,
  pkgs,
  ...
}: let
  theme = import ../theme.nix;
  inherit (theme) colors;
  ansi = builtins.elemAt theme.ansi;
  toRGB = hex: lib.concatStringsSep "," (theme.rgb hex);

  colorscheme =
    ''
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
      Color=${toRGB (ansi 15)}
    ''
    + lib.concatMapStrings (i: ''
      [Color${toString i}]
      Color=${toRGB (ansi i)}

      [Color${toString i}Intense]
      Color=${toRGB (ansi (i + 8))}

    '') (lib.range 0 7);

  profile = ''
    [General]
    Name=Bellatrix
    Parent=FALLBACK/
    ShowTerminalSizeHint=false
    TerminalColumns=143
    TerminalRows=41

    [Appearance]
    ColorScheme=Bellatrix
    Font=${theme.fonts.mono},${toString theme.fonts.size},-1,5,50,0,0,0,0,0
  '';

  konsolerc = ''
    MenuBar=Disabled

    [Desktop Entry]
    DefaultProfile=Bellatrix.profile

    [KonsoleWindow]
    RememberWindowSize=false
  '';
in {
  castle.links = {
    ".local/share/konsole/Bellatrix.colorscheme" =
      pkgs.writeText "Bellatrix.colorscheme" colorscheme;
    ".local/share/konsole/Bellatrix.profile" =
      pkgs.writeText "Bellatrix.profile" profile;
    ".config/konsolerc" = pkgs.writeText "konsolerc" konsolerc;
  };
}
