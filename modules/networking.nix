_: {
  networking = {
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      ensureProfiles.profiles.wired = {
        connection = {
          id = "Wired connection 1";
          type = "ethernet";
          interface-name = "enp16s0";
        };
        ipv4 = {
          method = "auto";
          ignore-auto-dns = true;
        };
        ipv6 = {
          method = "auto";
          ignore-auto-dns = true;
          ip6-privacy = "2";
        };
      };
    };

    nftables.enable = true;
  };

  systemd.services.NetworkManager-wait-online.enable = false;

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
