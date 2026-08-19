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
}
