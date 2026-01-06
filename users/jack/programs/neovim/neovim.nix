# Neovim configuration with LSP, Treesitter, and lazy.nvim plugin management.
#
# Structure:
#   - programs.neovim: Core settings, LSP servers, Nix-managed treesitter grammars
#   - xdg.configFile: External Lua files + generated modules (colors.lua, paths.lua)
#
# Generated files (from Nix):
#   - nvim/lua/colors.lua - Theme colors for runtime loading
#   - nvim/lua/paths.lua  - Portable paths (home dir, hostname, etc.)
#
# External Lua files (./lua/):
#   - nvim/init.lua, nvim/lua/core/*, nvim/lua/plugins/*, nvim/colors/*
#
# Plugins are managed by lazy.nvim (not Nix) for flexibility and lazy-loading.
# Treesitter grammars ARE managed by Nix to avoid compile issues.
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

  # Generate colors.lua content from theme
  colorsLua = let
    formatColor = name: value: "  ${name} = \"${value}\",";
    colorsList = lib.mapAttrsToList formatColor colors;
  in ''
    -- Auto-generated from lib/theme.nix - DO NOT EDIT
    local M = {}
    M.colors = {
    ${lib.concatStringsSep "\n" colorsList}
    }
    return M
  '';

  # Generate paths.lua content for portable configuration
  pathsLua = ''
    -- Auto-generated paths - DO NOT EDIT
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

    # LSP servers and formatters available to neovim
    extraPackages = with pkgs; [
      lua-language-server
      nixd
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      gcc

      # Formatters (used by conform.nvim)
      stylua
      nodePackages.prettier
      alejandra
    ];

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
    # Generated Lua modules (from Nix theme/paths)
    "nvim/lua/colors.lua".text = colorsLua;
    "nvim/lua/paths.lua".text = pathsLua;

    # Entry point
    "nvim/init.lua".source = ./lua/init.lua;

    # Core modules
    "nvim/lua/core/options.lua".source = ./lua/core/options.lua;
    "nvim/lua/core/keymaps.lua".source = ./lua/core/keymaps.lua;
    "nvim/lua/core/autocmds.lua".source = ./lua/core/autocmds.lua;
    "nvim/lua/core/theme.lua".source = ./lua/core/theme.lua;

    # Plugin manager bootstrap
    "nvim/lua/lazy-bootstrap.lua".source = ./lua/lazy-bootstrap.lua;

    # Plugin specs
    "nvim/lua/plugins/lsp.lua".source = ./lua/plugins/lsp.lua;
    "nvim/lua/plugins/completions.lua".source = ./lua/plugins/completions.lua;
    "nvim/lua/plugins/treesitter.lua".source = ./lua/plugins/treesitter.lua;
    "nvim/lua/plugins/ui.lua".source = ./lua/plugins/ui.lua;
    "nvim/lua/plugins/editor.lua".source = ./lua/plugins/editor.lua;
    "nvim/lua/plugins/formatting.lua".source = ./lua/plugins/formatting.lua;

    # Colorscheme
    "nvim/colors/bellatrix.lua".source = ./lua/colors/bellatrix.lua;
  };
}
