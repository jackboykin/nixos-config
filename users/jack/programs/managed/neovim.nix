{
  pkgs,
  theme,
  ...
}: let
  c = theme.colors;
in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      lua-language-server
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      gcc
    ];
  };

  xdg.configFile = {
    "nvim/init.lua".text = ''
      require("core")
      require("lazy-bootstrap")
    '';

    "nvim/lua/core/init.lua".text = ''
      require("core.options")
      require("core.keymaps")
      require("core.autocmds")
    '';

    "nvim/lua/core/options.lua".text = ''
      local opt = vim.opt

      opt.number = true
      opt.relativenumber = true
      opt.signcolumn = "yes"
      opt.fillchars = { eob = " " }

      opt.tabstop = 2
      opt.softtabstop = 2
      opt.shiftwidth = 2
      opt.expandtab = true
      opt.smartindent = true
      opt.wrap = false

      opt.ignorecase = true
      opt.smartcase = true
      opt.hlsearch = false
      opt.incsearch = true

      opt.termguicolors = true
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

      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    '';

    "nvim/lua/core/keymaps.lua".text = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

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
      map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

      map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
      map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

      map("n", "<C-d>", "<C-d>zz", opts)
      map("n", "<C-u>", "<C-u>zz", opts)
      map("n", "n", "nzzzv", opts)
      map("n", "N", "Nzzzv", opts)

      map("x", "<leader>p", '"_dP', opts)

      map("n", "<leader>w", ":w<CR>", { desc = "Save" })
      map("n", "<leader>q", ":q<CR>", { desc = "Quit" })

      map("n", "<Esc>", ":noh<CR>", opts)
    '';

    "nvim/lua/core/autocmds.lua".text = ''
      local autocmd = vim.api.nvim_create_autocmd
      local augroup = vim.api.nvim_create_augroup

      autocmd("TextYankPost", {
        group = augroup("highlight_yank", { clear = true }),
        callback = function()
          vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
        end,
      })

      autocmd("BufWritePre", {
        group = augroup("trim_whitespace", { clear = true }),
        pattern = "*",
        command = [[%s/\s\+$//e]],
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
          vim.cmd("tabdo wincmd =")
        end,
      })
    '';

    "nvim/lua/lazy-bootstrap.lua".text = ''
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not vim.loop.fs_stat(lazypath) then
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

    "nvim/lua/plugins/colorscheme.lua".text = ''
      return {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
          require("tokyonight").setup({
            style = "storm",
            transparent = true,
            styles = {
              comments = { italic = true },
              keywords = { italic = false },
              sidebars = "transparent",
              floats = "transparent",
            },
            on_highlights = function(hl, colors)
              hl.CursorLine = { bg = colors.bg_highlight }
              hl.LineNr = { fg = colors.dark3 }
              hl.CursorLineNr = { fg = colors.orange, bold = true }
            end,
          })
          vim.cmd.colorscheme("tokyonight-storm")
        end,
      }
    '';

    "nvim/lua/plugins/lsp.lua".text = ''
      return {
        {
          "neovim/nvim-lspconfig",
          event = { "BufReadPre", "BufNewFile" },
          dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "folke/neodev.nvim",
          },
          config = function()
            require("neodev").setup()

            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local signs = { Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }
            for type, icon in pairs(signs) do
              local hl = "DiagnosticSign" .. type
              vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
            end

            vim.api.nvim_create_autocmd("LspAttach", {
              callback = function(args)
                local map = function(mode, lhs, rhs, desc)
                  vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
                end

                map("n", "gd", vim.lsp.buf.definition, "Go to definition")
                map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
                map("n", "gr", vim.lsp.buf.references, "Show references")
                map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
                map("n", "K", vim.lsp.buf.hover, "Hover documentation")
                map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
                map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
                map("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")
                map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
                map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
              end,
            })

            lspconfig.nil_ls.setup({ capabilities = capabilities })
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  workspace = { checkThirdParty = false },
                  telemetry = { enable = false },
                },
              },
            })
            lspconfig.ts_ls.setup({ capabilities = capabilities })
            lspconfig.cssls.setup({ capabilities = capabilities })
            lspconfig.html.setup({ capabilities = capabilities })
          end,
        },
      }
    '';

    "nvim/lua/plugins/completions.lua".text = ''
      return {
        {
          "hrsh7th/nvim-cmp",
          event = "InsertEnter",
          dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
          },
          config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
              snippet = {
                expand = function(args)
                  luasnip.lsp_expand(args.body)
                end,
              },
              window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
              },
              mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                  else
                    fallback()
                  end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_prev_item()
                  elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                  else
                    fallback()
                  end
                end, { "i", "s" }),
              }),
              sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "path" },
              }, {
                { name = "buffer" },
              }),
            })
          end,
        },
      }
    '';

    "nvim/lua/plugins/treesitter.lua".text = ''
      return {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
          require("nvim-treesitter.configs").setup({
            ensure_installed = {
              "bash",
              "c",
              "css",
              "html",
              "javascript",
              "json",
              "lua",
              "markdown",
              "markdown_inline",
              "nix",
              "python",
              "rust",
              "toml",
              "typescript",
              "vim",
              "vimdoc",
              "yaml",
            },
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
            incremental_selection = {
              enable = true,
              keymaps = {
                init_selection = "<C-space>",
                node_incremental = "<C-space>",
                scope_incremental = false,
                node_decremental = "<bs>",
              },
            },
          })
        end,
      }
    '';

    "nvim/lua/plugins/ui.lua".text = ''
      return {
        {
          "nvim-lualine/lualine.nvim",
          dependencies = { "nvim-tree/nvim-web-devicons" },
          event = "VeryLazy",
          config = function()
            require("lualine").setup({
              options = {
                theme = "tokyonight",
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
          "lukas-reineke/indent-blankline.nvim",
          event = { "BufReadPre", "BufNewFile" },
          main = "ibl",
          opts = {
            indent = { char = "│" },
            scope = { enabled = false },
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
          dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
          },
          opts = {
            lsp = {
              override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
              },
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
          "nvim-telescope/telescope.nvim",
          dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
          },
          cmd = "Telescope",
          keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
            { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
            { "<leader><leader>", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
          },
          config = function()
            local telescope = require("telescope")
            telescope.setup({
              defaults = {
                file_ignore_patterns = { "node_modules", ".git/" },
                layout_config = { prompt_position = "top" },
                sorting_strategy = "ascending",
              },
            })
            telescope.load_extension("fzf")
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

        { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
        { "kylechui/nvim-surround", event = "VeryLazy", config = true },
        { "numToStr/Comment.nvim", event = { "BufReadPre", "BufNewFile" }, config = true },
        { "christoomey/vim-tmux-navigator", lazy = false },
        {
          "kdheepak/lazygit.nvim",
          cmd = "LazyGit",
          keys = { { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" } },
        },
      }
    '';
  };
}
