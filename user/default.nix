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
    ./perf.nix
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
        bun
        claude-code
        fastfetch
        fd
        ffmpeg-release
        file
        gh
        herdr
        hyperfine
        jq
        poppler-utils
        quarry
        ripgrep
        socat
        strace
        unzip
        yazi

        clang
        go
        python3
        (rust-bin.stable.latest.default.override {extensions = ["rust-analyzer" "rust-src"];})
        typescript
        zigpkgs.master
        zigpkgs.zls

        alejandra
        clang-tools
        nixd
        pyright
        statix
        zig-zlint

        cloudflared
        dnsutils
        nmap
        rustnet
        tcpdump
      ];
    };
  };

  services.userborn.enable = true;
  sops.secrets = {
    user-password.neededForUsers = true;
    exa-api-key = {
      owner = "jack";
      path = "/home/jack/.config/quarry/exa-api-key";
    };
    typesafe-api-key = {
      owner = "jack";
      path = "/home/jack/.config/quarry/typesafe-api-key";
    };
  };
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
