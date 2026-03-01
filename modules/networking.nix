{config, ...}: {
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

    firewall.allowedUDPPorts = [config.services.tailscale.port];

    nftables.enable = true;

    nftables.tables.dns-restrict = {
      family = "inet";
      content = ''
        chain output {
          type filter hook output priority 0; policy accept;
          meta l4proto { tcp, udp } th dport 53 ip daddr { 127.0.0.0/8 } accept
          meta l4proto { tcp, udp } th dport 53 ip6 daddr ::1 accept
          oifname "tailscale0" meta l4proto { tcp, udp } th dport 53 accept
          meta l4proto { tcp, udp } th dport 53 drop
        }
      '';
    };
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
          "mullvad-base-doh"
        ];
        ipv6_servers = true;
        require_dnssec = true;
        block_unqualified = true;
        block_undelegated = true;
        cache_size = 4096;
        dnscrypt_ephemeral_keys = true;
        tls_disable_session_tickets = true;
        cache_neg_min_ttl = 60;
      };
    };

    resolved = {
      enable = true;
      settings.Resolve = {
        DNS = "127.0.0.2 ::1";
        Domains = "~.";
        LLMNR = "no";
        MulticastDNS = "no";
        FallbackDNS = "";
      };
    };
  };
}
