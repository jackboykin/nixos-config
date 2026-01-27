{
  config,
  pkgs,
  username,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    shell = pkgs.nushell;
    hashedPasswordFile = config.sops.secrets.user-password.path;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
  };

  users.defaultUserShell = pkgs.nushell;
  environment.shells = [pkgs.nushell];
}
