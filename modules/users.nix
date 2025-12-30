{
  pkgs,
  username,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
  };

  programs.zsh.enable = true;
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
