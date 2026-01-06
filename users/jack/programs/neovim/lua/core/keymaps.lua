local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Window navigation handled by vim-tmux-navigator plugin

map("n", "<C-Up>", ":resize +2<CR>", opts)
map("n", "<C-Down>", ":resize -2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

map("n", "<S-h>", ":bprevious<CR>", opts)
map("n", "<S-l>", ":bnext<CR>", opts)

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

map("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true, desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true, desc = "Scroll up (centered)" })
map("n", "n", "nzzzv", { noremap = true, silent = true, desc = "Next search (centered)" })
map("n", "N", "Nzzzv", { noremap = true, silent = true, desc = "Prev search (centered)" })

map("x", "<leader>p", '"_dP', opts)

map("n", "<leader>w", ":w<CR>", { desc = "Save" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- Trouble & Todo
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
map("n", "<leader>xt", "<cmd>TodoTrouble<cr>", { desc = "Todo (Trouble)" })
