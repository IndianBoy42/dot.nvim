local map = vim.keymap.set
-- TODO: in specific window
local function qfe(row)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  return vim.fn.getqflist({ idx = row, items = true }).items[1]
end
local function pick() local e = qfe() end
map("n", "a", "<cr>", { buffer = true })
map("n", "A", pick, { buffer = true })
