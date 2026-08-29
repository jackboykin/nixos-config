_: {
  services.journald.extraConfig = "SystemMaxUse=256M";

  systemd = {
    oomd = {
      enableSystemSlice = true;
      enableUserSlices = true;
    };

    slices."user".sliceConfig.ManagedOOMMemoryPressureLimit = "60%";

    slices."nix-daemon".sliceConfig = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "50%";
    };
    services.nix-daemon.serviceConfig = {
      Slice = "nix-daemon.slice";
      OOMScoreAdjust = 1000;
    };
  };
}
