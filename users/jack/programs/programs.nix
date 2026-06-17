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
    ./ndu.nix
    ./nushell.nix
    ./rust.nix
    ./tmux.nix
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    chromium
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

    bun-canary
    clang
    python3
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
