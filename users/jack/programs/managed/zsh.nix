{ config, ... }:
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
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      bindkey '^[h' backward-word
      bindkey '^[l' forward-word
    '';
  };
}
