{pkgs, ...}: {
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
    nil
  ];
}
