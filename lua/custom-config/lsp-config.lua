-- 禁用插入模式下的文档弹窗
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
