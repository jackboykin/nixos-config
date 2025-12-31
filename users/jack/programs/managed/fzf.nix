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
      "bg+" = c.base;
      spinner = c.purple;
      hl = c.red;
      fg = c.text;
      header = c.red;
      info = c.purple;
      pointer = c.purple;
      marker = c.blue;
      "fg+" = c.text;
      prompt = c.purple;
      "hl+" = c.red;
      "selected-bg" = c.surface1;
    };
    defaultOptions = [ "--multi" ];
  };
}
