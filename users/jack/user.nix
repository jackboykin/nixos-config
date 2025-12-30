{ username, ... }:
{
  imports = [
    ./programs/programs.nix
    ./shell.nix
  ];

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.11";
  };

  # Create ~/.config, ~/.cache, ~/.local/share directories
  xdg.enable = true;
  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
