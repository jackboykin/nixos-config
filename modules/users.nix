{
  config,
  pkgs,
  username,
  ...
}: {
  services.userborn.enable = true;

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

  security.sudo.enable = false;
  security.doas = {
    enable = true;
    extraRules = [
      {
        groups = ["wheel"];
        persist = true;
      }
    ];
  };
}
