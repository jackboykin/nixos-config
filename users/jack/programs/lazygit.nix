{
  pkgs,
  theme,
  ...
}: let
  inherit (theme) colors;
in {
  programs.lazygit = {
    enable = true;
    settings = {
      os = {
        edit = "${pkgs.helix}/bin/hx {{filename}}";
        editAtLine = "${pkgs.helix}/bin/hx {{filename}}:{{line}}";
        editAtLineAndWait = "${pkgs.helix}/bin/hx {{filename}}:{{line}}";
        openDirInEditor = "${pkgs.helix}/bin/hx {{dir}}";
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
        authorColors."Jack Boykin" = colors.cyan;
        unspecifiedAuthorColors = [
          colors.red
          colors.orange
          colors.yellow
          colors.green
          colors.cyan
          colors.blue
          colors.magenta
          colors.brightCyan
          colors.brightMagenta
        ];
      };
    };
  };
}
