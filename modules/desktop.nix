{pkgs, ...}: let
  julia-mono = pkgs.runCommand "juliamono-terminal-fallback" {} ''
    install -Dm444 ${pkgs.julia-mono}/share/fonts/truetype/JuliaMono-{Regular,Bold}.ttf -t $out/share/fonts/truetype
  '';
in {
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.plasma6.excludePackages = with pkgs.kdePackages; [kwin-x11 khelpcenter];

  programs.kde-pim.enable = false;

  gtk.iconCache.enable = true;

  services = {
    displayManager.plasma-login-manager.enable = true;
    desktopManager.plasma6.enable = true;
    power-profiles-daemon.enable = false;
    fwupd.enable = false;
    orca.enable = false;
    speechd.package = pkgs.speechd.override {espeak = pkgs.espeak.override {mbrolaSupport = false;};};

    pipewire = {
      enable = true;
      alsa.enable = true;
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
