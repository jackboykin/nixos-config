{
  theme,
  config,
  ...
}:
let
  colors = theme.colors;
in
{
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

      # Bellatrix Syntax Highlighting Colors
      typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[command]='fg=${colors.green}'
      ZSH_HIGHLIGHT_STYLES[alias]='fg=${colors.cyan}'
      ZSH_HIGHLIGHT_STYLES[builtin]='fg=${colors.purple}'
      ZSH_HIGHLIGHT_STYLES[function]='fg=${colors.blue}'
      ZSH_HIGHLIGHT_STYLES[keyword]='fg=${colors.purple}'
      ZSH_HIGHLIGHT_STYLES[string]='fg=${colors.yellow}'
      ZSH_HIGHLIGHT_STYLES[comment]='fg=${colors.subtext0},italic'
      ZSH_HIGHLIGHT_STYLES[error]='fg=${colors.red}'
      ZSH_HIGHLIGHT_STYLES[path]='fg=${colors.cyan}'
      ZSH_HIGHLIGHT_STYLES[parameter]='fg=${colors.yellow}'

      bindkey '^[h' backward-word
      bindkey '^[l' forward-word
    '';
  };
}
