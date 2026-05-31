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
    fd
    gh
    jq
    macchina
    ripgrep
    yazi

    bun
    clang
    nodejs
    python3
    typescript
    zigpkgs.master

    clang-tools
    nixd
    prettier
    pyright
    typescript-language-server
    zig-zlint

    alejandra
    statix
  ];
}
