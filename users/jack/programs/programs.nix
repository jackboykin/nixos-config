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
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    # GUI Applications
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

    # CLI Tools
    fastfetch
    fd
    gh
    jq
    opencode
    ripgrep
    yazi

    # Development
    bun
    clang
    clang-tools # Provides clangd LSP
    lua-language-server
    nodejs
    nodePackages.prettier
    pyright # Python LSP
    rust-analyzer # Rust LSP
    stylua
    typescript
    typescript-language-server
    vscode-langservers-extracted # CSS/HTML/JSON LSPs

    # Nix Tooling
    alejandra
    nixd
  ];
}
