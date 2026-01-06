-- Load colors from Nix-generated module
local ok, theme = pcall(require, "colors")
local c = ok and theme.colors or {}

return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      local lualine_theme = {
        normal = {
          a = { bg = c.blue, fg = c.base, bold = true },
          b = { bg = c.surface1, fg = c.text },
          c = { bg = c.mantle, fg = c.subtext1 },
        },
        insert = {
          a = { bg = c.green, fg = c.base, bold = true },
        },
        visual = {
          a = { bg = c.purple, fg = c.base, bold = true },
        },
        replace = {
          a = { bg = c.red, fg = c.base, bold = true },
        },
        inactive = {
          a = { bg = c.mantle, fg = c.subtext0 },
          b = { bg = c.mantle, fg = c.subtext0 },
          c = { bg = c.mantle, fg = c.subtext0 },
        },
      }
      require("lualine").setup({
        options = {
          theme = lualine_theme,
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
