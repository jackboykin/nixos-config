_: {
  boot.kernelModules = ["tun"];

  networking = {
    useDHCP = false;
    nftables.enable = true;
  };

  systemd.network = {
    enable = true;
    wait-online.enable = false;
    networks."10-wired" = {
      matchConfig.Name = "enp16s0";
      networkConfig = {
        DHCP = "yes";
        IPv6PrivacyExtensions = "yes";
      };
      dhcpV4Config.UseDNS = false;
      dhcpV6Config.UseDNS = false;
      ipv6AcceptRAConfig.UseDNS = false;
    };
  };

  systemd.services.tailscaled.serviceConfig = {
    CapabilityBoundingSet = ["CAP_NET_ADMIN" "CAP_NET_RAW"];
    NoNewPrivileges = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    DeviceAllow = ["/dev/net/tun rw"];
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectKernelTunables = true;
    ProtectSystem = "strict";
    RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_NETLINK" "AF_UNIX"];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
  };

  services = {
    tailscale = {
      enable = true;
      openFirewall = true;
      extraSetFlags = ["--accept-dns=false"];
    };

    resolved = {
      enable = true;
      settings.Resolve = {
        DNS = "192.168.1.161";
        Domains = "~.";
        LLMNR = "no";
        MulticastDNS = "no";
        FallbackDNS = "";
      };
    };
  };
}
