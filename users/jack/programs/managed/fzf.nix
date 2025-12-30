{ theme, ... }:
let
  c = theme.colors;
in
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    colors = {
      "bg+" = c.surface0;
      spinner = c.magenta;
      hl = c.red;
      fg = c.text;
      header = c.red;
      info = c.magenta;
      pointer = c.magenta;
      marker = c.blue;
      "fg+" = c.text;
      prompt = c.magenta;
      "hl+" = c.red;
      "selected-bg" = c.surface1;
    };
    defaultOptions = [ "--multi" ];
  };
}
