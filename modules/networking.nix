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
      interfaces."tailscale0" = {
        allowedTCPPorts = [];
        allowedUDPPorts = [];
      };
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
          "nextdns"
          "nextdns-ipv6"
          "cloudflare"
          "cloudflare-ipv6"
        ];
        ipv4_servers = true;
        ipv6_servers = true;
        dnscrypt_servers = true;
        doh_servers = true;
        require_dnssec = true;
        require_nolog = true;
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
