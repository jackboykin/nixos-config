{pkgs, ...}: {
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  environment = {
    systemPackages = with pkgs; [
      nix-output-monitor
      sbctl
      sops
      age

      pkgsStatic.uutils-coreutils-noprefix
    ];
    defaultPackages = [];
  };

  programs.nano.enable = false;
  system.tools.nixos-option.enable = false;
  documentation = {
    info.enable = false;
    man.man-db.enable = false;
    man.mandoc.enable = true;
    nixos.enable = false;
  };

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
  };

  services.journald.extraConfig = "SystemMaxUse=256M";

  systemd = {
    oomd = {
      enableSystemSlice = true;
      enableUserSlices = true;
    };
    slices."user".sliceConfig.ManagedOOMMemoryPressureLimit = "60%";
  };
}
