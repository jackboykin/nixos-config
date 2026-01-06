{
  pkgs,
  theme,
  ...
}: let
  colors = theme.colors;
in {
  programs.lazygit = {
    enable = true;
    settings = {
      os = {
        edit = "${pkgs.neovim}/bin/nvim {{filename}}";
        editAtLine = "${pkgs.neovim}/bin/nvim +{{line}} {{filename}}";
        editAtLineAndWait = "${pkgs.neovim}/bin/nvim +{{line}} {{filename}}";
        openDirInEditor = "${pkgs.neovim}/bin/nvim {{dir}}";
      };
      git.pagers = [
        {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        }
      ];
      git.overrideGpg = true;
      gui = {
        border = "single";
        nerdFontsVersion = "3";
        theme = {
          activeBorderColor = [
            "cyan"
            "bold"
          ];
          inactiveBorderColor = [colors.overlay1];
          optionsTextColor = ["yellow"];
          selectedLineBgColor = [colors.surface1];
          cherryPickedCommitBgColor = [colors.surface1];
          cherryPickedCommitFgColor = [colors.purple];
          unstagedChangesColor = [colors.red];
          defaultFgColor = [colors.text];
          searchingActiveBorderColor = [colors.purple];
        };
        authorColors = {
          "Jack Boykin" = colors.cyan;
        };
        unspecifiedAuthorColors = [
          colors.red
          colors.orange
          colors.purple
          colors.yellow
          colors.green
          colors.cyan
          colors.blue
          colors.maroon
          colors.purple
        ];
      };
    };
  };
}
