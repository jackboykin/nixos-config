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
    ./tmux.nix
    ./zoxide.nix
  ];

  users.users.${username}.packages = with pkgs; [
    kdePackages.kate
    obsidian
    spotify
    vesktop
    zed-editor

    bubblewrap
    claude-code
    fastfetch
    fd
    ffmpeg-release
    gh
    hyperfine
    jq
    poppler-utils
    ripgrep
    socat
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
