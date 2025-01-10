-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
map("t", "<C-]>", "<C-\\><C-n>", opts)
map("n", "<C-z>", "", opts)
map("t", "<C-z>", "", opts)

map("n", "<leader>ga", ":DiffviewOpen<CR>", { desc = "Open diff view" })
map("n", "<leader>gF", ":DiffviewFileHistory<CR>", { desc = "Diff view file history" })
map("n", "<leader>gd", ":DiffviewClose<CR>", { desc = "Close diffview panel" })
