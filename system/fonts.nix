{pkgs, ...}: let
  julia-mono = pkgs.runCommand "juliamono-terminal-fallback" {} ''
    install -Dm444 ${pkgs.julia-mono}/share/fonts/truetype/JuliaMono-{Regular,Bold}.ttf -t $out/share/fonts/truetype
  '';
  jetbrains-mono = pkgs.runCommand "jetbrains-mono-nl-nerd-font" {} ''
    install -Dm444 ${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNLNerdFont{,Mono}-*.ttf -t $out/share/fonts/truetype
  '';
in {
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      jetbrains-mono
      julia-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      inter
      source-serif
    ];

    fontconfig = {
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
          "JetBrainsMonoNL Nerd Font"
          "JuliaMono"
          "Noto Sans Mono"
        ];
        emoji = [
          "Noto Color Emoji"
          "Noto Sans Symbols 2"
        ];
      };
      subpixel.rgba = "rgb";
    };
  };
}
