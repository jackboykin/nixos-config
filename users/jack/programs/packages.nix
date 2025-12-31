{ pkgs, ... }:
{
  home.packages = with pkgs; [
    spotify
    kdePackages.kate
    remmina
    jellyfin-media-player
    code-cursor
    opencode
    antigravity
    gemini-cli
    ripgrep
    fd
    jq
    fastfetch
    nodejs
    nil
    alejandra
    nixfmt-rfc-style
    yazi
    typescript
    typescript-language-server
  ];
}
