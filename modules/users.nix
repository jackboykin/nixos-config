{
  pkgs,
  username,
  ...
}:
{
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
  };

  # System-level shell enablement adds these to /etc/shells
  # User-level config in home-manager handles personal settings
  programs.zsh.enable = true;
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.bash;
}
