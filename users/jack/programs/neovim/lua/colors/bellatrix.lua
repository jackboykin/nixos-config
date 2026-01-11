vim.g.colors_name = "bellatrix"

-- Load colors from Nix-generated module
local ok, theme = pcall(require, "colors")
if not ok then
	vim.notify("colors.lua not found - run nixos-rebuild", vim.log.levels.ERROR)
	return
end

local c = theme.colors

-- Clear existing highlights
vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") then
	vim.cmd.syntax("reset")
end

local highlights = {
	-- Base UI
	Normal = { bg = c.base, fg = c.text },
	NormalFloat = { bg = c.mantle, fg = c.text },
	FloatBorder = { fg = c.blue, bg = c.mantle },
	CursorLine = { bg = c.surface0 },
	LineNr = { fg = c.subtext0 },
	CursorLineNr = { fg = c.orange, bold = true },
	Visual = { bg = c.surface1 },
	Search = { bg = c.overlay2, fg = c.text },
	IncSearch = { bg = c.purple, fg = c.base },
	WinSeparator = { fg = c.surface2, bold = true },

	-- Syntax Highlighting
	Comment = { fg = c.subtext0, italic = true },
	Keyword = { fg = c.purple },
	Function = { fg = c.blue },
	String = { fg = c.green },
	Constant = { fg = c.orange },
	Number = { fg = c.orange },
	Type = { fg = c.yellow },
	PreProc = { fg = c.cyan },
	Operator = { fg = c.cyan },
	Identifier = { fg = c.text },
	Statement = { fg = c.purple },
	Special = { fg = c.pink },

	-- Treesitter
	["@variable"] = { fg = c.text },
	["@function"] = { fg = c.blue },
	["@keyword"] = { fg = c.purple },
	["@string"] = { fg = c.green },
	["@type"] = { fg = c.yellow },
	["@constant"] = { fg = c.orange },
	["@property"] = { fg = c.blue },
	["@field"] = { fg = c.blue },
	["@parameter"] = { fg = c.text },

	-- Diagnostics
	DiagnosticError = { fg = c.red },
	DiagnosticWarn = { fg = c.orange },
	DiagnosticInfo = { fg = c.blue },
	DiagnosticHint = { fg = c.cyan },
}

for name, val in pairs(highlights) do
	vim.api.nvim_set_hl(0, name, val)
end
