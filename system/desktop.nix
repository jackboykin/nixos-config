{pkgs, ...}: {
  environment.plasma6.excludePackages = with pkgs.kdePackages; [kwin-x11 khelpcenter];

  programs.kde-pim.enable = false;

  systemd.user.services.drkonqi-coredump-pickup.enable = false;

  gtk.iconCache.enable = true;

  services = {
    displayManager.plasma-login-manager.enable = true;
    desktopManager.plasma6.enable = true;
    power-profiles-daemon.enable = false;
    fwupd.enable = false;
    orca.enable = false;
    speechd.package = pkgs.speechd.override {espeak = pkgs.espeak.override {mbrolaSupport = false;};};
  };
}
