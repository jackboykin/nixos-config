{config, ...}: {
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    connectionConfig = {
      "ipv4.ignore-auto-dns" = true;
      "ipv6.ignore-auto-dns" = true;
    };
    ensureProfiles.profiles."Wired connection 1" = {
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
      };
      ethernet = {};
    };
  };

  networking.firewall = {
    enable = true;
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };

  networking.nftables.enable = true;

  networking.interfaces.enp16s0.wakeOnLan = {
    enable = true;
    policy = ["magic"];
  };

  services.tailscale.enable = true;

  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      listen_addresses = [
        "127.0.0.2:53"
        "[::1]:53"
      ];
      server_names = [
        "cloudflare"
        "quad9-dnscrypt-ip4-filter-pri"
      ];
      ipv4_servers = true;
      ipv6_servers = true;
      dnscrypt_servers = true;
      doh_servers = true;
      require_dnssec = true;
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = "127.0.0.2 ::1";
      DNSStubListener = "yes";
      Domains = "~.";
      DNSSEC = "false";
      DNSOverTLS = "false";
      FallbackDNS = "";
    };
  };
}
