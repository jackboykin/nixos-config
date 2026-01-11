-- lazy.nvim is installed via Nix and already in the runtimepath

require("lazy").setup({
	{ import = "plugins" },
}, {
	checker = { enabled = true, notify = false },
	change_detection = { notify = false },
	performance = {
		rtp = {
			disabled_plugins = {
				"2html_plugin",
				"getscript",
				"getscriptPlugin",
				"gzip",
				"logipat",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"rplugin",
				"rrhelper",
				"spellfile_plugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"vimball",
				"vimballPlugin",
				"zipPlugin",
			},
		},
	},
})
