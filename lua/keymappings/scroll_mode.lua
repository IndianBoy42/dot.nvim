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
      { "h", M.horz_spd .. "zh" },
      { "l", M.horz_spd .. "zl" },
      { "H", "zH" },
      { "L", "zL" },
      { "^", "ze" },
      { "$", "zs" },
      { "j", M.vert_spd .. "<C-e>" },
      { "k", M.vert_spd .. "<C-y>" },
      { "J", "<C-d>" },
      { "K", "<C-u>" },
      { "<esc>", nil, { exit = true, nowait = true, desc = "exit" } },
    },
  }

  local map = vim.keymap.set
  map("n", "<leader>vc", "zz", { desc = "Center this Line" })
  map("n", "<leader>vb", "zb", { desc = "Bottom this Line" })
  map("n", "<leader>vv", "zt", { desc = "Top this Line" })

  return hydra
end
return setmetatable(M, meta_M)
