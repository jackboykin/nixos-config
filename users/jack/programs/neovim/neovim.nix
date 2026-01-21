{
  config,
  pkgs,
  lib,
  theme,
  hostname,
  username,
  ...
}: let
  colors = theme.colors;

  colorsLua = let
    formatColor = name: value: "  ${name} = \"${value}\",";
    colorsList = lib.mapAttrsToList formatColor colors;
  in ''
    local M = {}
    M.colors = {
    ${lib.concatStringsSep "\n" colorsList}
    }
    return M
  '';

  pathsLua = ''
    local M = {}
    M.nixos_config = "${config.home.homeDirectory}/nixos-config"
    M.hostname = "${hostname}"
    M.username = "${username}"
    return M
  '';
in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (
        p:
          with p; [
            bash
            c
            css
            html
            javascript
            json
            lua
            markdown
            nix
            python
            rust
            toml
            typescript
            vim
            yaml
          ]
      ))
      lazy-nvim
    ];
  };

  xdg.configFile = {
    "nvim/lua/colors.lua".text = colorsLua;
    "nvim/lua/paths.lua".text = pathsLua;
    "nvim/init.lua".source = ./lua/init.lua;
    "nvim/lua/core/options.lua".source = ./lua/core/options.lua;
    "nvim/lua/core/keymaps.lua".source = ./lua/core/keymaps.lua;
    "nvim/lua/core/autocmds.lua".source = ./lua/core/autocmds.lua;
    "nvim/lua/core/theme.lua".source = ./lua/core/theme.lua;
    "nvim/lua/lazy-bootstrap.lua".source = ./lua/lazy-bootstrap.lua;
    "nvim/lua/plugins/lsp.lua".source = ./lua/plugins/lsp.lua;
    "nvim/lua/plugins/completions.lua".source = ./lua/plugins/completions.lua;
    "nvim/lua/plugins/treesitter.lua".source = ./lua/plugins/treesitter.lua;
    "nvim/lua/plugins/ui.lua".source = ./lua/plugins/ui.lua;
    "nvim/lua/plugins/editor.lua".source = ./lua/plugins/editor.lua;
    "nvim/lua/plugins/formatting.lua".source = ./lua/plugins/formatting.lua;
    "nvim/colors/bellatrix.lua".source = ./lua/colors/bellatrix.lua;
  };
}
