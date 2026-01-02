{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb.layout = "us";

  services.printing.enable = true;

  # pipewire low-latency
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    noto-fonts-lgc-plus
    lexend
    liberation_ttf
    roboto
    inter
    corefonts
    vista-fonts
    googlesans-code
  ];

  fonts.fontconfig = {
    enable = true;
    antialias = true;
    hinting = {
      enable = true;
      style = "slight";
    };
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
    defaultFonts = {
      serif = [
        "Noto Serif"
        "Liberation Serif"
      ];
      sansSerif = [
        "Lexend"
        "Inter"
        "Noto Sans"
      ];
      monospace = [
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono"
      ];
      emoji = [
        "Noto Color Emoji"
        "Noto Sans Symbols 2"
      ];
    };
  };

}
