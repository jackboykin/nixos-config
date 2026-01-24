{
  config,
  pkgs,
  username,
  ...
}: {
  users.users.${username} = {
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

  programs.zsh.enable = true;
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
}
