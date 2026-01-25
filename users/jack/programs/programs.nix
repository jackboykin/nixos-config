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
    ./tmux.nix
    ./zoxide.nix
    ./nushell.nix
  ];

  home.packages = with pkgs; [
    antigravity
    claude-code
    code-cursor
    chromium
    obsidian
    jellyfin-media-player
    kdePackages.kate
    remmina
    spotify
    vesktop

    fastfetch
    fd
    gh
    jq
    opencode
    ripgrep
    yazi

    bun
    clang
    clang-tools
    lua-language-server
    nodejs
    nodePackages.prettier
    pyright
    rust-analyzer
    stylua
    typescript
    typescript-language-server
    vscode-langservers-extracted

    alejandra
    nixd
  ];
}
