{pkgs, ...}: {
  imports = [
    ./bash.nix
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
    ./lazygit.nix
    ./llm-agents.nix
    ./mpv.nix
    ./rust.nix
    ./tmux.nix
    ./zoxide.nix
    ./nushell.nix
  ];

  home.packages = with pkgs; [
    chromium
    gpu-screen-recorder
    jellyfin-media-player
    kdePackages.kate
    obsidian
    spotify
    vesktop
    zed-editor

    fastfetch
    fd
    gh
    jq
    ripgrep
    yazi

    bun
    clang
    clang-tools
    nodejs
    nodePackages.prettier
    pyright
    typescript
    typescript-language-server

    alejandra
    nixd
    statix
  ];
}
