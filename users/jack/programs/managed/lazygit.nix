{
  pkgs,
  theme,
  ...
}: let
  c = theme.colors;
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
          inactiveBorderColor = [c.overlay1];
          optionsTextColor = ["yellow"];
          selectedLineBgColor = [c.surface1];
          cherryPickedCommitBgColor = [c.surface1];
          cherryPickedCommitFgColor = [c.pink];
          unstagedChangesColor = [c.red];
          defaultFgColor = [c.text];
          searchingActiveBorderColor = [c.pink];
        };
        authorColors = {
          "Jack Boykin" = c.teal;
        };
        unspecifiedAuthorColors = [
          c.red
          c.cream
          c.pink
          c.periwinkle
          c.green
          c.cyan
          c.blue
          c.maroon
          c.magenta
        ];
      };
    };
  };
}
