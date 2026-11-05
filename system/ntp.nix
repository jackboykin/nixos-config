{lib, ...}: {
  services.ntpd-rs = {
    enable = true;
    useNetworkingTimeServers = false;
    settings.source =
      map (address: {
        mode = "nts";
        inherit address;
      }) [
        "nts.meta.com"
        "time.cloudflare.com"
        "time.web-clock.ca"
        "ntp.quantum5.ca"
        "ntp2.wiktel.com"
        "ptbtime1.ptb.de"
        "time.metrologie.at"
        "nts.netnod.se"
      ];
  };

  systemd.services.ntpd-rs.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = lib.mkForce "ntpd-rs";
    Group = lib.mkForce "ntpd-rs";
  };
  users.users.ntpd-rs = {
    isSystemUser = true;
    group = "ntpd-rs";
  };
  users.groups.ntpd-rs = {};
}
