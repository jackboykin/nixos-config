{
  config,
  pkgs,
  username,
  ...
}: {
  users = {
    mutableUsers = false;

    users.${username} = {
      isNormalUser = true;
      description = username;
      shell = pkgs.nushell;
      hashedPasswordFile = config.sops.secrets.user-password.path;
      extraGroups = [
        "wheel"
        "video"
      ];
    };
  };

  environment.shells = [pkgs.nushell];

  security.sudo = {
    execWheelOnly = true;
  };
}
