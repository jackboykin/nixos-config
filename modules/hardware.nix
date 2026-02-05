_: {
  services.fstrim.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
    "kernel.kptr_restrict" = 2;
    "net.core.bpf_jit_harden" = 2;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
  };

  hardware = {
    graphics.enable = true;
    amdgpu.initrd.enable = true;
    enableRedistributableFirmware = true;
  };
}
