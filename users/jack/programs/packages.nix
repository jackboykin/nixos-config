{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # GUI Applications
    antigravity
    code-cursor
    jellyfin-media-player
    kdePackages.kate
    remmina
    spotify
    vesktop

    # CLI Tools
    fastfetch
    fd
    #gemini-cli
    jq
    opencode
    ripgrep
    yazi

    # Development
    nodejs
    typescript
    typescript-language-server

    # Nix Tooling
    alejandra
    nil
    nixfmt-rfc-style
  ];
}
