local function expand_macro()
  vim.cmd(":RustLsp expandMacro")
end

local function rebuild()
  vim.cmd.RustLsp("rebuildProcMacros")
end

vim.api.nvim_create_user_command("Expand", expand_macro, {})
vim.api.nvim_create_user_command("Rebuild", rebuild, {})
