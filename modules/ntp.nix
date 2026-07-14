_: {
  services.ntpd-rs = {
    enable = true;
    useNetworkingTimeServers = false;
    settings.source = [
      {
        mode = "nts";
        address = "time.cloudflare.com";
      }
      {
        mode = "nts";
        address = "ohio.time.system76.com";
      }
      {
        mode = "nts";
        address = "ntp2.wiktel.com";
      }
      {
        mode = "nts";
        address = "time1.mbix.ca";
      }
      {
        mode = "nts";
        address = "time.xargs.org";
      }
    ];
  };
}
