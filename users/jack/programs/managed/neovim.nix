# Neovim configuration with LSP, Treesitter, and lazy.nvim plugin management.
#
# Structure:
#   - programs.neovim: Core neovim settings, LSP servers, and Nix-managed treesitter grammars
#   - xdg.configFile: Lua configuration files organized as:
#       nvim/init.lua           - Entry point that loads core modules
#       nvim/lua/core/          - Options, keymaps, autocmds, theme loading
#       nvim/colors/bellatrix.lua - Custom colorscheme using theme.colors
#       nvim/lua/lazy-bootstrap.lua - lazy.nvim plugin manager setup
#       nvim/lua/plugins/       - Plugin specs (lsp, completions, ui, editor, etc.)
#
# Plugins are managed by lazy.nvim (not Nix) for flexibility and lazy-loading.
# Treesitter grammars ARE managed by Nix to avoid compile issues.
{
  pkgs,
  theme,
  ...
}: let
  colors = theme.colors;
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
      nil # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      gcc # Required for treesitter compilation

      # Formatters (used by conform.nvim)
      stylua
      nodePackages.prettier
      alejandra # Matches system formatter (nix fmt)
    ];

    # Use the newer Treesitter management
    plugins = with pkgs.vimPlugins; [
      # Treesitter with grammars
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
      # UI/Editor utilities are handled by lazy.nvim to avoid bootstrap issues
    ];
  };

  xdg.configFile = {
    "nvim/init.lua".text = ''
      require("core.options") -- Set leader first
      require("lazy-bootstrap")
      require("core.keymaps")
      require("core.autocmds")
      require("core.theme")
    '';

    "nvim/lua/core/theme.lua".text = ''
      vim.opt.background = "dark"
      vim.cmd.colorscheme("bellatrix")
    '';

    "nvim/colors/bellatrix.lua".text = ''
      vim.g.colors_name = "bellatrix"

      -- Clear existing highlights
      vim.cmd.highlight("clear")
      if vim.fn.exists("syntax_on") then
        vim.cmd.syntax("reset")
      end

      local highlights = {
        -- Base UI
        Normal = { bg = "${colors.base}", fg = "${colors.text}" },
        NormalFloat = { bg = "${colors.mantle}", fg = "${colors.text}" },
        FloatBorder = { fg = "${colors.blue}", bg = "${colors.mantle}" },
        CursorLine = { bg = "${colors.surface0}" },
        LineNr = { fg = "${colors.subtext0}" },
        CursorLineNr = { fg = "${colors.orange}", bold = true },
        Visual = { bg = "${colors.surface1}" },
        Search = { bg = "${colors.overlay2}", fg = "${colors.text}" },
        IncSearch = { bg = "${colors.purple}", fg = "${colors.base}" },
        WinSeparator = { fg = "${colors.surface2}", bold = true },

        -- Syntax Highlighting
        Comment = { fg = "${colors.subtext0}", italic = true },
        Keyword = { fg = "${colors.purple}" },
        Function = { fg = "${colors.blue}" },
        String = { fg = "${colors.green}" },
        Constant = { fg = "${colors.orange}" },
        Number = { fg = "${colors.orange}" },
        Type = { fg = "${colors.yellow}" },
        PreProc = { fg = "${colors.cyan}" },
        Operator = { fg = "${colors.cyan}" },
        Identifier = { fg = "${colors.text}" },
        Statement = { fg = "${colors.purple}" },
        Special = { fg = "${colors.pink}" },

        -- Treesitter
        ["@variable"] = { fg = "${colors.text}" },
        ["@function"] = { fg = "${colors.blue}" },
        ["@keyword"] = { fg = "${colors.purple}" },
        ["@string"] = { fg = "${colors.green}" },
        ["@type"] = { fg = "${colors.yellow}" },
        ["@constant"] = { fg = "${colors.orange}" },
        ["@property"] = { fg = "${colors.blue}" },
        ["@field"] = { fg = "${colors.blue}" },
        ["@parameter"] = { fg = "${colors.text}" },

        -- Diagnostics
        DiagnosticError = { fg = "${colors.red}" },
        DiagnosticWarn = { fg = "${colors.orange}" },
        DiagnosticInfo = { fg = "${colors.blue}" },
        DiagnosticHint = { fg = "${colors.cyan}" },
      }

      for name, val in pairs(highlights) do
        vim.api.nvim_set_hl(0, name, val)
      end
    '';

    "nvim/lua/core/options.lua".text = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      local opt = vim.opt

      opt.number = true
      opt.relativenumber = true
      opt.signcolumn = "yes"
      opt.fillchars = { eob = " " }

      opt.tabstop = 2
      opt.softtabstop = 2
      opt.shiftwidth = 2
      opt.expandtab = true
      opt.wrap = false

      opt.ignorecase = true
      opt.smartcase = true
      opt.hlsearch = false
      opt.incsearch = true

      opt.cursorline = true
      opt.scrolloff = 8
      opt.sidescrolloff = 8
      opt.pumheight = 10
      opt.showmode = false

      opt.swapfile = false
      opt.backup = false
      opt.undofile = true
      opt.undodir = vim.fn.stdpath("data") .. "/undo"
      opt.clipboard = "unnamedplus"
      opt.splitright = true
      opt.splitbelow = true
      opt.updatetime = 250
      opt.timeoutlen = 300
      opt.completeopt = "menuone,noselect"
    '';

    "nvim/lua/core/keymaps.lua".text = ''
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- Window management (matches vim-tmux-navigator)
      map("n", "<C-h>", "<C-w>h", opts)
      map("n", "<C-j>", "<C-w>j", opts)
      map("n", "<C-k>", "<C-w>k", opts)
      map("n", "<C-l>", "<C-w>l", opts)

      map("n", "<C-Up>", ":resize +2<CR>", opts)
      map("n", "<C-Down>", ":resize -2<CR>", opts)
      map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
      map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

      map("n", "<S-h>", ":bprevious<CR>", opts)
      map("n", "<S-l>", ":bnext<CR>", opts)

      map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
      map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

      map("n", "<C-d>", "<C-d>zz", opts)
      map("n", "<C-u>", "<C-u>zz", opts)
      map("n", "n", "nzzzv", opts)
      map("n", "N", "Nzzzv", opts)

      map("x", "<leader>p", '"_dP', opts)

      map("n", "<leader>w", ":w<CR>", { desc = "Save" })
      map("n", "<leader>q", ":q<CR>", { desc = "Quit" })

      -- Trouble & Todo
      map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
      map("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
      map("n", "<leader>xt", "<cmd>TodoTrouble<cr>", { desc = "Todo (Trouble)" })
    '';

    "nvim/lua/core/autocmds.lua".text = ''
      local autocmd = vim.api.nvim_create_autocmd
      local augroup = vim.api.nvim_create_augroup

      autocmd("TextYankPost", {
        group = augroup("highlight_yank", { clear = true }),
        callback = function()
          vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
        end,
      })

      autocmd("BufReadPost", {
        group = augroup("last_position", { clear = true }),
        callback = function()
          local mark = vim.api.nvim_buf_get_mark(0, '"')
          local lcount = vim.api.nvim_buf_line_count(0)
          if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
          end
        end,
      })

      autocmd("VimResized", {
        group = augroup("resize_splits", { clear = true }),
        callback = function()
          local current_tab = vim.api.nvim_get_current_tabpage()
          vim.cmd("tabdo wincmd =")
          vim.api.nvim_set_current_tabpage(current_tab)
        end,
      })
    '';

    "nvim/lua/lazy-bootstrap.lua".text = ''
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not vim.uv.fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable",
          lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)

      require("lazy").setup({
        { import = "plugins" },
      }, {
        checker = { enabled = true, notify = false },
        change_detection = { notify = false },
        performance = {
          rtp = {
            disabled_plugins = {
              "gzip",
              "matchit",
              "matchparen",
              "netrwPlugin",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
      })
    '';

    "nvim/lua/plugins/formatting.lua".text = ''
      return {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        cmd = { "ConformInfo" },
        keys = {
          {
            "<leader>f",
            function()
              require("conform").format({ async = true, lsp_format = "fallback" })
            end,
            mode = "",
            desc = "Format buffer",
          },
        },
        opts = {
          formatters_by_ft = {
            lua = { "stylua" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            javascriptreact = { "prettier" },
            typescriptreact = { "prettier" },
            css = { "prettier" },
            html = { "prettier" },
            json = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            nix = { "alejandra" },
            ["*"] = { "trim_whitespace", "trim_newlines" },
          },
          format_on_save = {
            timeout_ms = 500,
            lsp_format = "fallback",
          },
        },
      }
    '';

    "nvim/lua/plugins/colorscheme.lua".text = ''
      return {}
    '';

    "nvim/lua/plugins/lsp.lua".text = ''
      return {
        {
          "neovim/nvim-lspconfig",
          event = { "BufReadPre", "BufNewFile" },
          dependencies = {
            "saghen/blink.cmp",
            { "folke/lazydev.nvim", opts = {} },
          },
          config = function()
            vim.diagnostic.config({
              signs = {
                text = {
                  [vim.diagnostic.severity.ERROR] = " ",
                  [vim.diagnostic.severity.WARN] = " ",
                  [vim.diagnostic.severity.HINT] = "󰌵 ",
                  [vim.diagnostic.severity.INFO] = " ",
                },
              },
              float = { border = "rounded" },
            })

            vim.api.nvim_create_autocmd("LspAttach", {
              group = vim.api.nvim_create_augroup("UserLspConfig", {}),
              callback = function(ev)
                local map = function(mode, lhs, rhs, desc)
                  vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = "LSP: " .. desc })
                end

                map("n", "gd", vim.lsp.buf.definition, "Go to definition")
                map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
                map("n", "gr", vim.lsp.buf.references, "Show references")
                map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
                map("n", "K", vim.lsp.buf.hover, "Hover documentation")
                map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
                map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
                map("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")
                map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
                map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
              end,
            })

            local capabilities = require('blink.cmp').get_lsp_capabilities()

            local servers = {
              nil_ls = {},
              lua_ls = {
                settings = {
                  Lua = {
                    workspace = { checkThirdParty = false },
                    telemetry = { enable = false },
                    completion = { callSnippet = "Replace" },
                  },
                },
              },
              ts_ls = {},
              cssls = {},
              html = {},
            }

            for name, config in pairs(servers) do
              config.capabilities = capabilities
              vim.lsp.config(name, config)
              vim.lsp.enable(name)
            end
          end,
        },
      }
    '';

    "nvim/lua/plugins/completions.lua".text = ''
      return {
        {
          "saghen/blink.cmp",
          dependencies = "rafamadriz/friendly-snippets",
          version = "*",
          opts = {
            keymap = { preset = "default" },
            appearance = {
              use_nvim_cmp_as_default = true,
              nerd_font_variant = "mono",
            },
            sources = {
              default = { "lsp", "path", "snippets", "buffer" },
            },
            signature = { enabled = true },
          },
          opts_extend = { "sources.default" },
        },
      }
    '';

    "nvim/lua/plugins/treesitter.lua".text = ''
      -- Grammars are pre-installed via Nix; just enable built-in features
      return {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        main = "nvim-treesitter",
        opts = {
          highlight = { enable = true },
          indent = { enable = true },
        },
      }
    '';

    "nvim/lua/plugins/ui.lua".text = ''
      return {
        {
          "nvim-lualine/lualine.nvim",
          dependencies = { "nvim-tree/nvim-web-devicons" },
          event = "VeryLazy",
          config = function()
            local theme = {
              normal = {
                a = { bg = "${colors.blue}", fg = "${colors.base}", bold = true },
                b = { bg = "${colors.surface1}", fg = "${colors.text}" },
                c = { bg = "${colors.mantle}", fg = "${colors.subtext1}" },
              },
              insert = {
                a = { bg = "${colors.green}", fg = "${colors.base}", bold = true },
              },
              visual = {
                a = { bg = "${colors.purple}", fg = "${colors.base}", bold = true },
              },
              replace = {
                a = { bg = "${colors.red}", fg = "${colors.base}", bold = true },
              },
              inactive = {
                a = { bg = "${colors.mantle}", fg = "${colors.subtext0}" },
                b = { bg = "${colors.mantle}", fg = "${colors.subtext0}" },
                c = { bg = "${colors.mantle}", fg = "${colors.subtext0}" },
              },
            }
            require("lualine").setup({
              options = {
                theme = theme,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                globalstatus = true,
              },
              sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
              },
            })
          end,
        },

        {
          "folke/snacks.nvim",
          priority = 1000,
          lazy = false,
          opts = {
            bigfile = { enabled = true },
            dashboard = { enabled = true },
            indent = { enabled = true },
            input = { enabled = true },
            notifier = { enabled = true },
            picker = { enabled = true },
            quickfile = { enabled = true },
            scroll = { enabled = false },
            statuscolumn = { enabled = true },
            words = { enabled = true },
          },
          keys = {
            { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Pad" },
            { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Pad" },
            { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
            { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
            { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
            { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
            { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
            { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
            { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
            { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (CWD)" },
            { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
            -- Picker keymaps
            { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
            { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
            { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
            { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Tags" },
            { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
            { "<leader><leader>", function() Snacks.picker.buffers() end, desc = "Buffers" },
          },
        },

        {
          "akinsho/bufferline.nvim",
          dependencies = "nvim-tree/nvim-web-devicons",
          event = "VeryLazy",
          opts = {
            options = {
              mode = "buffers",
              separator_style = "thin",
              show_buffer_close_icons = false,
              show_close_icon = false,
              diagnostics = "nvim_lsp",
            },
          },
        },

        {
          "folke/which-key.nvim",
          event = "VeryLazy",
          opts = { delay = 300 },
        },

        {
          "folke/noice.nvim",
          event = "VeryLazy",
          dependencies = { "MunifTanjim/nui.nvim" },
          opts = {
            -- Disable notifications (snacks.notifier handles these)
            messages = { enabled = false },
            notify = { enabled = false },
            lsp = {
              override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
              },
              progress = { enabled = false }, -- snacks handles this
            },
            presets = {
              bottom_search = true,
              command_palette = true,
              long_message_to_split = true,
            },
          },
        },

      }
    '';

    "nvim/lua/plugins/editor.lua".text = ''
      return {
        {
          "stevearc/oil.nvim",
          dependencies = { "nvim-tree/nvim-web-devicons" },
          lazy = false,
          config = function()
            require("oil").setup({
              delete_to_trash = true,
              view_options = { show_hidden = true },
              keymaps = {
                ["<C-h>"] = false,
                ["<C-c>"] = false,
                ["q"] = "actions.close",
              },
            })
            vim.keymap.set("n", "-", require("oil").toggle_float, { desc = "Open file explorer" })
          end,
        },

        {
          "lewis6991/gitsigns.nvim",
          event = { "BufReadPre", "BufNewFile" },
          opts = {
            signs = {
              add = { text = "│" },
              change = { text = "│" },
              delete = { text = "󰍵" },
              topdelete = { text = "‾" },
              changedelete = { text = "~" },
            },
            on_attach = function(bufnr)
              local gs = package.loaded.gitsigns
              local map = function(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
              end
              map("n", "]h", gs.next_hunk, "Next hunk")
              map("n", "[h", gs.prev_hunk, "Previous hunk")
              map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
              map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
              map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
              map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
            end,
          },
        },

        { "folke/trouble.nvim", opts = {} },
        { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
        { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
        { "kylechui/nvim-surround", event = "VeryLazy", config = true },
        -- Comment.nvim removed: Neovim 0.11 has built-in gc/gcc commenting
        { "christoomey/vim-tmux-navigator", lazy = false },
      }
    '';
  };
}
