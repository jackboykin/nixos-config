{pkgs, ...}: {
  imports = [
    ./bat.nix
    ./btop.nix
    ./direnv.nix
    ./eza.nix
    ./firefox.nix
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./helix.nix
    ./konsole.nix
    ./mpv.nix
    ./nushell.nix
    ./tmux.nix
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    kdePackages.kate
    obsidian
    spotify
    vesktop
    vscode

    claude-code
    fastfetch
    fd
    gh
    hyperfine
    jq
    ripgrep
    uutils-coreutils-noprefix
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

    alejandra
    statix
  ];
}
