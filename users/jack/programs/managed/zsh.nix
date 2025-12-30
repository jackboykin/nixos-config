{
  theme,
  config,
  ...
}: let
  c = theme.colors;
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # Store zsh config in XDG config directory
    dotDir = "${config.xdg.configHome}/zsh";
    autosuggestion.enable = true;
    historySubstringSearch.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
    };

    initContent = ''
      # Basic completion styling
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*:descriptions' format '[%d]'

      # Wombat Syntax Highlighting Colors
      typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[command]='fg=${c.green}'
      ZSH_HIGHLIGHT_STYLES[alias]='fg=${c.cyan}'
      ZSH_HIGHLIGHT_STYLES[builtin]='fg=${c.magenta}'
      ZSH_HIGHLIGHT_STYLES[function]='fg=${c.blue}'
      ZSH_HIGHLIGHT_STYLES[keyword]='fg=${c.magenta}'
      ZSH_HIGHLIGHT_STYLES[string]='fg=${c.green}'
      ZSH_HIGHLIGHT_STYLES[comment]='fg=${c.overlay0},italic'
      ZSH_HIGHLIGHT_STYLES[error]='fg=${c.red}'
      ZSH_HIGHLIGHT_STYLES[path]='fg=${c.cyan}'
      ZSH_HIGHLIGHT_STYLES[parameter]='fg=${c.periwinkle}'

      bindkey '^[h' backward-word
      bindkey '^[l' forward-word
    '';
  };
}
