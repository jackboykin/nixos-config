{pkgs, ...}: {
  services = {
    xserver.enable = false;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    printing.enable = true;

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

  programs.chromium = {
    enable = true;
    extraOpts = {
      BlockThirdPartyCookies = true;
      DnsOverHttpsMode = "off";
      HttpsOnlyMode = "force_enabled";
      PasswordManagerEnabled = false;
      MetricsReportingEnabled = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      HardwareAccelerationModeEnabled = true;
      AudioCaptureAllowed = false;
      VideoCaptureAllowed = false;
      DefaultGeolocationSetting = 2;
      DefaultNotificationsSetting = 2;
      DefaultImagesSetting = 1;
      DefaultPopupsSetting = 2;
      BackgroundModeEnabled = false;
      DefaultBrowserSettingEnabled = false;
      SyncDisabled = true;
      BrowserSignin = 0;
    };
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
    inter
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
