{username, ...}: {
  imports = [
    ./programs/programs.nix
    ./shell.nix
  ];

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.11";
  };

  xdg.enable = true;
  programs.home-manager.enable = true;
}
