{theme, ...}: let
  colors = theme.colors;
in {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    colors = {
      "bg+" = colors.base;
      spinner = colors.purple;
      hl = colors.red;
      fg = colors.text;
      header = colors.red;
      info = colors.purple;
      pointer = colors.purple;
      marker = colors.blue;
      "fg+" = colors.text;
      prompt = colors.purple;
      "hl+" = colors.red;
      "selected-bg" = colors.surface1;
    };
    defaultOptions = ["--multi"];
  };
}
