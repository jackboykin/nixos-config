_: {
  # SSD Trim
  services.fstrim.enable = true;

  # Compressed RAM swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # high swappiness because zram is faster than ssd reads
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  hardware.graphics = {
    enable = true;
    # 32-bit support for Steam and older games
    enable32Bit = true;
  };
  # Load AMD GPU driver early in boot for better display support
  hardware.amdgpu.initrd.enable = true;
  hardware.enableRedistributableFirmware = true;
}
