{
  pkgs,
  lib,
  username,
  ...
}: let
  userDirs = {
    DESKTOP = "Desktop";
    DOCUMENTS = "Documents";
    DOWNLOAD = "Downloads";
    MUSIC = "Music";
    PICTURES = "Pictures";
    PROJECTS = "Projects";
    PUBLICSHARE = "Public";
    TEMPLATES = "Templates";
    VIDEOS = "Videos";
  };
in {
  imports = [
    ./home.nix
    ./programs/programs.nix
  ];

  home.dirs = builtins.attrValues userDirs;

  home.links = {
    ".config/user-dirs.conf" = pkgs.writeText "user-dirs.conf" "enabled=False\n";

    ".config/user-dirs.dirs" =
      pkgs.writeText "user-dirs.dirs"
      (lib.concatLines (lib.mapAttrsToList
        (key: dir: ''XDG_${key}_DIR="/home/${username}/${dir}"'')
        userDirs));

    ".config/baloofilerc" = pkgs.writeText "baloofilerc" ''
      [Basic Settings]
      Indexing-Enabled=false
    '';
  };
}
