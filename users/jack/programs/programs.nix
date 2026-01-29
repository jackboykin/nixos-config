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
    ./konsole.nix
    ./lazygit.nix
    ./mpv.nix
    ./neovim/neovim.nix
    ./rust.nix
    ./tmux.nix
    ./zoxide.nix
    ./nushell.nix
  ];

  home.packages = with pkgs; [
    amp-cli
    claude-code
    chromium
    gpu-screen-recorder
    obsidian
    opencode
    jellyfin-media-player
    kdePackages.kate
    remmina
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
    lua-language-server
    nodejs
    nodePackages.prettier
    pyright
    statix
    stylua
    typescript
    typescript-language-server

    alejandra
    nixd
  ];
}
