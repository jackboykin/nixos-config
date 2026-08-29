{pkgs, ...}: let
  julia-mono = pkgs.runCommand "juliamono-terminal-fallback" {} ''
    install -Dm444 ${pkgs.julia-mono}/share/fonts/truetype/JuliaMono-{Regular,Bold}.ttf -t $out/share/fonts/truetype
  '';
in {
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    julia-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    inter
    source-serif
  ];

  fonts.fontconfig = {
    subpixel.rgba = "rgb";
    localConf = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <selectfont>
          <rejectfont>
            <pattern>
              <patelt name="family"><string>FreeMono</string></patelt>
            </pattern>
          </rejectfont>
        </selectfont>
      </fontconfig>
    '';
    defaultFonts = {
      serif = [
        "Source Serif 4"
        "Noto Serif"
        "Liberation Serif"
      ];
      sansSerif = [
        "Inter"
        "Noto Sans"
      ];
      monospace = [
        "JetBrainsMono Nerd Font"
        "JuliaMono"
        "Noto Sans Mono"
      ];
      emoji = [
        "Noto Color Emoji"
        "Noto Sans Symbols 2"
      ];
    };
  };
}
