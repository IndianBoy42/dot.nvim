local map = vim.keymap.setl
-- TODO: in specific window
local function qfe(row)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  return vim.fn.getqflist({ idx = row, items = true }).items[1]
end
local function pick() local e = qfe() end
map("n", "<tab>", "<cr>", {})
map("n", "<localleader><tab>", pick, {})
