_: {
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

  services = {
    tailscale = {
      enable = true;
      openFirewall = true;
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
