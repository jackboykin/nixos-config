_: {
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
}
