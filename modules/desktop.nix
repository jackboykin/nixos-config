{
  pkgs,
  berkeley-mono-src,
  ...
}: let
  berkeley-mono = pkgs.stdenvNoCC.mkDerivation {
    pname = "berkeley-mono";
    version = "tx02";
    src = berkeley-mono-src;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      install -Dm644 $src/*.ttf -t $out/share/fonts/truetype/berkeley-mono
      runHook postInstall
    '';
  };
in {
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.plasma6.excludePackages = [pkgs.kdePackages.kwin-x11];

  services = {
    displayManager.plasma-login-manager.enable = true;
    desktopManager.plasma6.enable = true;
    power-profiles-daemon.enable = false;
    fwupd.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      extraConfig.pipewire."99-sample-rates"."context.properties"."default.clock.allowed-rates" = [
        44100
        48000
      ];
      wireplumber.extraConfig."99-sample-rates"."monitor.alsa.rules" = [
        {
          matches = [{"node.name" = "~alsa_output.*";}];
          actions.update-props."audio.allowed-rates" = "44100,48000";
        }
      ];
    };
  };

  security.rtkit.enable = true;

  programs.gpu-screen-recorder.enable = true;

  fonts.packages =
    [berkeley-mono]
    ++ (with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      lexend
      liberation_ttf
      inter
      source-serif
    ]);

  fonts.fontconfig = {
    subpixel.rgba = "rgb";
    defaultFonts = {
      serif = [
        "Source Serif 4"
        "Noto Serif"
        "Liberation Serif"
      ];
      sansSerif = [
        "Lexend"
        "Inter"
        "Noto Sans"
      ];
      monospace = [
        "Berkeley Mono"
        "Noto Sans Mono"
      ];
      emoji = [
        "Noto Color Emoji"
        "Noto Sans Symbols 2"
      ];
    };
  };
}
