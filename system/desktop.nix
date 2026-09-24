{pkgs, ...}: {
  services = {
    displayManager.plasma-login-manager.enable = true;
    desktopManager.plasma6.enable = true;
    power-profiles-daemon.enable = false;
    fwupd.enable = false;
    orca.enable = false;
    speechd.package = pkgs.speechd.override {espeak = pkgs.espeak.override {mbrolaSupport = false;};};
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [kwin-x11 khelpcenter];
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

  environment.laminix = {
    enable = true;
    pruneProfiles = true;
  };
}
