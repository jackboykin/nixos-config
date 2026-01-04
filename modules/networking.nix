{config, ...}: {
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    connectionConfig = {
      # ignore dhcp dns
      "ipv4.ignore-auto-dns" = true;
      "ipv6.ignore-auto-dns" = true;
    };
  };

  networking.firewall = {
    enable = true;
    # tailscale
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };

  networking.nftables.enable = true;

  networking.interfaces.enp16s0.wakeOnLan = {
    enable = true;
    policy = ["magic"];
  };

  services.tailscale.enable = true;

  # DNS
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      listen_addresses = [
        "127.0.0.1:53000"
        "[::1]:53000"
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

  # systemd-resolved forwards to dnscrypt-proxy which handles DNSSEC validation.
  # We disable resolved's own DNSSEC/DoT since dnscrypt-proxy already provides
  # encrypted DNS with DNSSEC enforcement (require_dnssec = true above).
  services.resolved = {
    enable = true;
    dnssec = "false";
    dnsovertls = "false";
    fallbackDns = [];
    extraConfig = ''
      DNS=127.0.0.1:53000
      DNSStubListener=yes
    '';
  };
}
