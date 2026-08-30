{lib, ...}: {
  services.ntpd-rs = {
    enable = true;
    useNetworkingTimeServers = false;
    settings.source =
      map (address: {
        mode = "nts";
        inherit address;
      }) [
        "time.cloudflare.com"
        "ohio.time.system76.com"
        "ntp2.wiktel.com"
        "time1.mbix.ca"
        "time.xargs.org"
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
