local M = {
  horz_spd = 2,
  vert_spd = 2,
}
local meta_M = {}
M.setup = function()
  local hydra = require "hydra" {
    name = "Scroll",
    hint = "",
    config = {
      invoke_on_body = false,
      hint = {
        border = "rounded",
        offset = -1,
      },
    },
    mode = "n",
    body = "z",
    heads = {
      { "h", M.horz_spd .. "zh" },
      { "l", M.horz_spd .. "zl" },
      { "H", "zH" },
      { "L", "zL" },
      { "^", "ze" },
      { "$", "zs" },
      { "<c-j>", "zb" },
      { "<c-k>", "zt" },
      { "<c-h>", "zz" },
      { "j", M.vert_spd .. "<C-e>" },
      { "k", M.vert_spd .. "<C-y>" },
      { "J", "<C-d>" },
      { "K", "<C-u>" },
      { "z", nil, { exit = true, nowait = true, desc = "exit" } },
    },
  }

  local map = vim.keymap.set
  map("n", "<leader>vh", "zz", { desc = "Center this Line" })
  map("n", "<leader>v_", "zb", { desc = "Bottom this Line" })
  map("n", "<leader>v^", "zt", { desc = "Top this Line" })

  return hydra
end
return setmetatable(M, meta_M)
