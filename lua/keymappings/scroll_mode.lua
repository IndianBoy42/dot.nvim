local M = {
  horz_spd = 4,
  vert_spd = 4,
}
local meta_M = {}
M.setup = function()
  local hydra = require "hydra" {
    name = "Scroll",
    hint = "",
    config = {
      invoke_on_body = false,
      hint = {
        float_opts = { border = "rounded" },
        offset = -1,
      },
    },
    mode = "n",
    body = "<leader>v",
    heads = {
      { "h", M.horz_spd .. "zh", { desc = "Scroll left" } },
      { "l", M.horz_spd .. "zl", { desc = "Scroll right" } },
      { "H", "ze", { desc == "Scroll leftmost" } },
      { "L", "zs", { desc == "Scroll rightmost" } },
      { "j", M.vert_spd .. "<C-e>", { desc = "Scroll down" } },
      { "k", M.vert_spd .. "<C-y>", { desc = "Scroll up" } },
      { "J", "<C-d>", { desc = "Scroll big down" } },
      { "K", "<C-u>", { desc = "Scroll big up" } },
      { "g", "gg", { desc = "Scroll to top" } },
      { "G", "G", { desc = "Scroll to bot" } },
      { "<esc>", nil, { exit = true, nowait = true, desc = "exit" } },
    },
  }

  local map = vim.keymap.set
  -- TODO: center the current function/class/block/<motion>?
  map("n", "<leader>vc", "zz", { desc = "Center this Line" })
  map("n", "<leader>vb", "zb", { desc = "Bottom this Line" })
  map("n", "<leader>vv", "zt", { desc = "Top this Line" })

  return hydra
end
return setmetatable(M, meta_M)
