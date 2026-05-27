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
      shell = pkgs.fish;
      hashedPasswordFile = config.sops.secrets.user-password.path;
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
      ];
    };
  };

  environment.shells = [pkgs.fish];
  programs.fish = {
    enable = true;
    generateCompletions = false;
  };

  security.sudo = {
    execWheelOnly = true;
  };
}
