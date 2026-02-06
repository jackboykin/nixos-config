{
  config,
  lib,
  ...
}: {
  networking = {
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none";
    };

    firewall = {
      enable = true;
      allowedUDPPorts = [config.services.tailscale.port];
    };

    nftables.enable = true;
  };

  services = {
    tailscale.enable = true;

    dnscrypt-proxy = {
      enable = true;
      settings = {
        listen_addresses = [
          "127.0.0.2:53"
          "[::1]:53"
        ];
        server_names = [
          "cloudflare"
          "cloudflare-ipv6"
        ];
        ipv6_servers = true;
        require_dnssec = true;
        block_unqualified = true;
        block_undelegated = true;
        cache_size = 4096;
        cache_neg_min_ttl = 60;
      };
    };

    resolved = {
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
  };
}
