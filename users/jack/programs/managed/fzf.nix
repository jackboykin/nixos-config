{theme, ...}: let
  c = theme.colors;
in {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    colors = {
      "bg+" = c.surface0;
      spinner = c.rosewater;
      hl = c.red;
      fg = c.text;
      header = c.red;
      info = c.mauve;
      pointer = c.rosewater;
      marker = c.lavender;
      "fg+" = c.text;
      prompt = c.mauve;
      "hl+" = c.red;
      "selected-bg" = c.surface1;
    };
    defaultOptions = ["--multi"];
  };
}
