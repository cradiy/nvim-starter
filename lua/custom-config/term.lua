require("toggleterm").setup({
  -- open_mapping = [[<c-\>]],
  hide_numbers = true, -- hide the number column in toggleterm buffers
  shade_filetypes = {},
  shade_terminals = true,
  start_in_insert = true,
  insert_mappings = true, -- whether or not the open mapping applies in insert mode
  persist_size = true,
  -- direction = 'horizontal',
  direction = "float",
  float_opts = {
    border = "curved", -- 浮动窗口的边框样式
  },
})

local Terminal = require("toggleterm.terminal").Terminal
local zellij = Terminal:new({
  cmd = "zellij",
  hidden = true,
  count = 10,
  direction = "float",
  float_opts = {
    border = "curved", -- 浮动窗口的边框样式
  },
})

function ZellijToggle()
  zellij:toggle()
end

vim.api.nvim_set_keymap("n", "<C-\\>", "<cmd>lua ZellijToggle()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-\\>", "<cmd>lua ZellijToggle()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-\\>", "<cmd>lua ZellijToggle()<CR>", { noremap = true, silent = true })
