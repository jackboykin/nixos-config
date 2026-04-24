{username, ...}: {
  imports = [
    ./programs/programs.nix
    ./shell.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
  };

  xdg.enable = true;
  programs.home-manager.enable = true;
}
