return {
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = {
				char = { enabled = false }, -- Disable f/F/t/T enhancement (keep native)
				search = { enabled = false }, -- Disable / integration
			},
			label = {
				rainbow = { enabled = true }, -- Color-coded jump labels
			},
		},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash jump",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
		},
	},

	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"-",
				function()
					require("oil").toggle_float()
				end,
				desc = "Open file explorer",
			},
		},
		opts = {
			delete_to_trash = true,
			view_options = { show_hidden = true },
			keymaps = { ["<C-h>"] = false, ["<C-c>"] = false, ["q"] = "actions.close" },
		},
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
				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, "Blame line")
			end,
		},
	},

	{ "windwp/nvim-autopairs", event = "InsertEnter", config = true },
	{ "kylechui/nvim-surround", event = "VeryLazy", config = true },
	-- Comment.nvim removed: Neovim 0.11 has built-in gc/gcc commenting
	{ "christoomey/vim-tmux-navigator", lazy = false },
}
