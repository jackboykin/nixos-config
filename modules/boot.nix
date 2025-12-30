{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "split_lock_detect=off"
    "amd_pstate=active"
  ];

  # Using lanzaboote for secure boot instead of systemd-boot
  boot.loader.systemd-boot.enable = false;
  boot.lanzaboote = {
    enable = true;
    # Directory containing secure boot keys
    pkiBundle = "/etc/secureboot";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  # Use systemd in initrd for faster boot and better Plymouth support
  boot.initrd.systemd.enable = true;
}
