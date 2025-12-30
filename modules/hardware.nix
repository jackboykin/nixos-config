_: {
  # SSD Trim
  services.fstrim.enable = true;
  # Compressed RAM swap
  zramSwap.enable = true;

  hardware.graphics = {
    enable = true;
    # 32-bit support for Steam and older games
    enable32Bit = true;
  };
  # Load AMD GPU driver early in boot for better display support
  hardware.amdgpu.initrd.enable = true;
  hardware.enableRedistributableFirmware = true;
}
