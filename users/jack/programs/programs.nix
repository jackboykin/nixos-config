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
    nodejs
    typescript
    typescript-language-server

    # Nix Tooling
    alejandra
    nixd
  ];
}
