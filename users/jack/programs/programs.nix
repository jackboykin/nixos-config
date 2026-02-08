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
    ./llm-agents.nix
    ./mpv.nix
    ./nushell.nix
    ./rust.nix
    ./tmux.nix
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    chromium
    gpu-screen-recorder
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
