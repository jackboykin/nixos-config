{pkgs, ...}: {
  imports = [
    ./bat.nix
    ./btop.nix
    ./direnv.nix
    ./eza.nix
    ./firefox.nix
    ./fzf.nix
    ./git.nix
    ./helix.nix
    ./konsole.nix
    ./lazygit.nix
    ./mpv.nix
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
    jq
    ripgrep
    yazi

    bun
    clang
    nodejs
    typescript
    zigpkgs.default

    clang-tools
    nixd
    prettier
    pyright
    typescript-language-server
    zig-zlint
    zls

    alejandra
    statix
  ];
}
