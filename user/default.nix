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
    ./box.nix
    ./btop.nix
    ./carapace.nix
    ./fetch.nix
    ./firefox.nix
    ./git.nix
    ./helix.nix
    ./himalaya.nix
    ./hunk.nix
    ./konsole.nix
    ./mpv.nix
    ./nushell.nix
    ./perf.nix
    ./quarry.nix
    ./rex.nix
    ./run0.nix
    ./spotify.nix
    ./ssh.nix
    ./uv.nix
    ./vesktop.nix
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
        obsidian
        zed-editor

        antigravity-cli
        aspell
        aspellDicts.en
        bc
        bubblewrap
        bun
        claude-code
        eza
        fd
        ffmpeg-release
        file
        gh
        hyperfine
        jq
        minisign
        poppler-utils
        ripgrep
        sequoia-sop
        socat
        strace
        unzip
        yazi
        libfido2

        clang-release
        go
        python-release
        (rust-bin.stable.latest.minimal.override {
          extensions = ["clippy" "rustfmt" "rust-analyzer" "rust-src"];
        })
        typescript
        zigpkgs.stable
        zigpkgs.nightly
        zigpkgs.zls

        alejandra
        ast-grep
        bash-language-server
        clang-tools-release
        nixd
        ruff
        ty
        tombi
        vscode-langservers-extracted
        yaml-language-server
        zig-zlint

        dnsutils
        nmap
        rustnet
        tcpdump
      ];
    };
  };

  services.userborn.enable = true;
  sops.secrets.user-password.neededForUsers = true;
  environment.shells = [pkgs.nushell];

  castle.dirs = builtins.attrValues userDirs;
  castle.links = {
    ".config/user-dirs.conf" = pkgs.writeText "user-dirs.conf" "enabled=False\n";

    ".config/user-dirs.dirs" =
      pkgs.writeText "user-dirs.dirs"
      (lib.concatLines (lib.mapAttrsToList
        (key: dir: ''XDG_${key}_DIR="${home}/${dir}"'')
        userDirs));

    ".npmrc" = pkgs.writeText "npmrc" "ignore-scripts=true\n";

    ".claude/CLAUDE.md" = "${home}/.grimoire/rules.md";
    ".gemini/GEMINI.md" = "${home}/.grimoire/rules.md";
    ".claude/skills" = "${home}/.grimoire/skills";
    ".gemini/config/skills" = "${home}/.grimoire/skills";

    ".config/baloofilerc" = pkgs.writeText "baloofilerc" ''
      [Basic Settings]
      Indexing-Enabled=false
    '';
  };
}
