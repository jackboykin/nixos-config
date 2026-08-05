{
  pkgs,
  username,
  ...
}: {
  imports = [
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
    ./zellij.nix
    ./zoxide.nix
  ];

  users.users.${username}.packages = with pkgs; [
    kdePackages.kate
    obsidian
    spotify
    vesktop
    zed-editor

    claude-code
    fastfetch
    fd
    ffmpeg-master
    gh
    hyperfine
    jq
    ripgrep
    pkgsStatic.uutils-coreutils-noprefix
    yazi

    bun
    clang
    python3
    rust-bin.stable.latest.default
    typescript
    zigpkgs.master

    clang-tools
    nixd
    pyright
    zig-zlint

    bandwhich
    nmap
    tcpdump

    alejandra
    statix
  ];
}
