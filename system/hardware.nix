{
  lib,
  pkgs,
  ...
}: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.amd.updateMicrocode = true;
    graphics.package = pkgs.mesa-main;
    firmware = [
      (pkgs.runCommand "linux-firmware-orion" {} ''
        mkdir -p $out/lib/firmware
        cp -r ${pkgs.linux-firmware}/lib/firmware/{amdgpu,rtl_nic} $out/lib/firmware
      '')
    ];
  };

  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "usbhid" "hid_generic" "usb_storage" "sd_mod"];
    kernelModules = ["kvm-amd"];
    kernelParams = [
      "processor.bm_check_disable=1"
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/d7dab88b-0bcc-4878-8e42-5c62114864e1";
      fsType = "ext4";
      options = ["noatime"];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/F5E5-BFBC";
      fsType = "vfat";
      options = ["fmask=0177" "dmask=0077"];
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];
  services.fstrim.enable = true;
}
