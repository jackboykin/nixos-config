{
  pkgs,
  username,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
  };

  # system-level shells
  programs.zsh.enable = true;
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
}
