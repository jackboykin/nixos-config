{ hostname, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = hostname;
  system.stateVersion = "25.11";

  virtualisation.vmVariant = {
    # ── Boot Fixes ──────────────────────────────────────────────────────
    # Prevent 90-second hang waiting for non-existent network interfaces
    systemd.network.wait-online.enable = false;

    # ── Login ───────────────────────────────────────────────────────────
    # Auto-login to TTY1 so you can immediately run 'sudo passwd jack'
    # After setting your password, switch to the GUI with Ctrl+Alt+F1
    services.getty.autologinUser = "jack";

    # Allow sudo without password (needed to set initial password)
    security.sudo.wheelNeedsPassword = false;

    # ── Resources ───────────────────────────────────────────────────────
    virtualisation.memorySize = 4096; # 4GB RAM
    virtualisation.cores = 4;
    virtualisation.diskSize = 8192; # 8GB virtual disk

    # ── Display ─────────────────────────────────────────────────────────
    virtualisation.resolution = {
      x = 1920;
      y = 1080;
    };

    # Enable GPU acceleration (VirGL)
    virtualisation.qemu.options = [
      "-device virtio-vga-gl"
      "-display gtk,gl=on"
    ];

    # ── Shared Folder ───────────────────────────────────────────────────
    # Create ~/vm-shared on your host, access it at /mnt/hostfiles in the VM
    virtualisation.sharedDirectories.hostfiles = {
      source = "/home/jack/vm-shared";
      target = "/mnt/hostfiles";
    };

    # ── Clipboard Sharing ───────────────────────────────────────────────
    services.spice-vdagentd.enable = true;
  };
}
