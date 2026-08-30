{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.users.users.jack) home;
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
    ./castle.nix
    ./btop.nix
    ./carapace.nix
    ./direnv.nix
    ./eza.nix
    ./firefox.nix
    ./fzf.nix
    ./ghostty.nix
    ./git.nix
    ./helix.nix
    ./konsole.nix
    ./mpv.nix
    ./nushell.nix
    ./tmux.nix
    ./zoxide.nix
  ];

  users = {
    mutableUsers = false;
    users.jack = {
      isNormalUser = true;
      description = "jack";
      shell = pkgs.nushell;
      hashedPasswordFile = config.sops.secrets.user-password.path;
      extraGroups = [
        "wheel"
        "video"
      ];
      packages = with pkgs; [
        kdePackages.kate
        obsidian
        spotify
        vesktop
        zed-editor

        aspell
        aspellDicts.en
        bc
        bubblewrap
        claude-code
        fastfetch
        fd
        ffmpeg-release
        file
        gh
        herdr
        htmlq
        hyperfine
        jq
        poppler-utils
        ripgrep
        socat
        unzip
        yazi

        bun
        clang
        (python3.withPackages (ps: [ps.markdownify]))
        rust-bin.stable.latest.default
        typescript
        zigpkgs.master
        zigpkgs.zls

        clang-tools
        nixd
        pyright
        zig-zlint

        bandwhich
        dnsutils
        nmap
        tcpdump

        alejandra
        statix
      ];
    };
  };

  services.userborn.enable = true;
  sops.secrets.user-password.neededForUsers = true;
  environment.shells = [pkgs.nushell];

  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [
        {
          groups = ["wheel"];
          persist = true;
        }
      ];
    };
  };

  castle.dirs = builtins.attrValues userDirs;
  castle.links = {
    ".config/user-dirs.conf" = pkgs.writeText "user-dirs.conf" "enabled=False\n";

    ".config/user-dirs.dirs" =
      pkgs.writeText "user-dirs.dirs"
      (lib.concatLines (lib.mapAttrsToList
        (key: dir: ''XDG_${key}_DIR="${home}/${dir}"'')
        userDirs));

    ".config/baloofilerc" = pkgs.writeText "baloofilerc" ''
      [Basic Settings]
      Indexing-Enabled=false
    '';
  };
}
