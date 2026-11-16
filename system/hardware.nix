{pkgs, ...}: {
  nixpkgs.hostPlatform = "x86_64-linux";

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
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "usbhid"
      "hid_generic"
      "usb_storage"
      "sd_mod"
    ];
    kernelParams = [
      "processor.bm_check_disable=1"
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partuuid/bf6c8570-7819-41f5-aa1f-c67e1b9c3bdc";
      fsType = "bcachefs";
      options = ["noatime"];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/F5E5-BFBC";
      fsType = "vfat";
      options = ["fmask=0177" "dmask=0077"];
    };
  };

  zramSwap.enable = true;
}
