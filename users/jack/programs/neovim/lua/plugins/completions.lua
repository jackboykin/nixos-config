return {
	{
		"saghen/blink.cmp",
		version = "*",
		dependencies = {
			"milanglacier/minuet-ai.nvim",
		},
		opts = {
			keymap = {
				preset = "default",
				-- Accept AI completion with Tab (when minuet suggestion visible)
				["<Tab>"] = {
					function(cmp)
						if cmp.is_visible() then
							return cmp.accept()
						end
					end,
					"fallback",
				},
			},
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			sources = {
				default = { "lsp", "path", "buffer", "minuet" },
				providers = {
					minuet = {
						name = "minuet",
						module = "minuet.blink",
						score_offset = 100, -- Prioritize AI suggestions
						async = true,
					},
				},
			},
			signature = { enabled = true },
		},
		opts_extend = { "sources.default" },
	},

	{
		"milanglacier/minuet-ai.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- Provider: gemini, openai, claude, openai_compatible, huggingface
			-- Set GEMINI_API_KEY, OPENAI_API_KEY, or ANTHROPIC_API_KEY env var
			provider = "gemini",
			throttle = 1500, -- Debounce in ms
			debounce = 500,
			context_window = 4096,
			request_timeout = 5,
			notify = "warn", -- Only show warnings, not every request
			provider_options = {
				gemini = {
					model = "gemini-2.0-flash",
					optional = {
						generationConfig = {
							maxOutputTokens = 128,
						},
					},
				},
			},
		},
	},
}
