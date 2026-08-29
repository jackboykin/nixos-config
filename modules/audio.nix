_: {
  security.rtkit.enable = true;

  services.pipewire = {
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
}
