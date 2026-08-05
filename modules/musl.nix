{
  config,
  lib,
  ...
}: let
  dynamicUsers =
    lib.attrNames
    (lib.filterAttrs
      (_: s: builtins.elem (s.serviceConfig.DynamicUser or false) [true "true" "yes" 1])
      config.systemd.services);
in {
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];
  system.nssDatabases = {
    passwd = lib.mkForce ["files"];
    group = lib.mkForce ["files"];
    shadow = lib.mkForce ["files"];
    hosts = lib.mkForce ["files" "dns"];
  };

  assertions = [
    {
      assertion = dynamicUsers == [];
      message = "musl contract: DynamicUser services present: ${toString dynamicUsers}";
    }
  ];

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
