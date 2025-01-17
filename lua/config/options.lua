-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.number = true -- show absolute number
vim.opt.relativenumber = false -- add numbers to each line on the left side

vim.diagnostic.config({
  float = {
    show_header = true,
    source = true,
    focusable = false,
    border = "rounded",
    -- 插入模式禁用
    severity_sort = true,
  },
  update_in_insert = false, -- 禁用插入模式自动更新诊断
})
