{
  lib,
  pkgs,
  ...
}: {
  services = {
    displayManager.plasma-login-manager.enable = true;
    desktopManager.plasma6.enable = true;
    power-profiles-daemon.enable = false;
    fwupd.enable = false;
    geoclue2.enable = false;
    orca.enable = false;
    speechd.package = pkgs.speechd.override {
      espeak = pkgs.espeak.override {mbrolaSupport = false;};
    };
  };

  environment = {
    plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      khelpcenter
      plasma-browser-integration
    ];
    laminix = {
      enable = true;
      pruneProfiles = true;
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (_: _: {
        drkonqi = final.emptyDirectory;
        phonon-vlc = final.emptyDirectory;
      });
    })
  ];

  programs.kde-pim.enable = false;
  systemd.services."drkonqi-coredump-processor@".wantedBy = lib.mkForce [];

  gtk.iconCache.enable = true;

  # bugs.kde.org/501406; drop once fixed upstream. ABI unchanged, so swap it in rather than rebuild Plasma.
  system.replaceDependencies.replacements = let
    inherit (pkgs.kdePackages) ksvg;
  in [
    {
      oldDependency = ksvg;
      newDependency = ksvg.overrideAttrs (
        o: {patches = (o.patches or []) ++ [./ksvg-cache-lookup-misses.patch];}
      );
    }
  ];
}
