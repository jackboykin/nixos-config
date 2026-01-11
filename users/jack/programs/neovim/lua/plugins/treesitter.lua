-- Grammars are pre-installed via Nix; just enable built-in features
return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		main = "nvim-treesitter",
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
		},
		config = function(_, opts)
			require("nvim-treesitter").setup(opts)

			-- Incremental selection keymaps
			vim.keymap.set("n", "<C-space>", function()
				require("nvim-treesitter.incremental_selection").init_selection()
			end, { desc = "Start incremental selection" })
			vim.keymap.set("x", "<C-space>", function()
				require("nvim-treesitter.incremental_selection").node_incremental()
			end, { desc = "Expand selection" })
			vim.keymap.set("x", "<bs>", function()
				require("nvim-treesitter.incremental_selection").node_decremental()
			end, { desc = "Shrink selection" })
		end,
	},

	-- mini.ai for enhanced text objects (works with Nix-managed treesitter)
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				custom_textobjects = {
					-- Function textobject
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
					-- Class textobject
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
					-- Block (conditional/loop)
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
				},
			}
		end,
	},
}
