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
