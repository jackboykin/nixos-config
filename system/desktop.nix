{pkgs, ...}: {
  services = {
    displayManager.plasma-login-manager.enable = true;
    desktopManager.plasma6.enable = true;
    power-profiles-daemon.enable = false;
    fwupd.enable = false;
    orca.enable = false;
    speechd.package = pkgs.speechd.override {espeak = pkgs.espeak.override {mbrolaSupport = false;};};
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
      kdePackages = prev.kdePackages.overrideScope (_: _: {phonon-vlc = final.emptyDirectory;});
    })
  ];

  programs.kde-pim.enable = false;
  systemd.user.services.drkonqi-coredump-pickup.enable = false;

  gtk.iconCache.enable = true;

  # Until KDE bug 501406 is fixed upstream. ABI unchanged, so swap it in rather than rebuild Plasma.
  system.replaceDependencies.replacements = let
    inherit (pkgs.kdePackages) ksvg;
  in [
    {
      oldDependency = ksvg;
      newDependency = ksvg.overrideAttrs (o: {patches = (o.patches or []) ++ [./ksvg-cache-lookup-misses.patch];});
    }
  ];
}
