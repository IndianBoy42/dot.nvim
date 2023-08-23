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
  map("n", "--", "zz", { desc = "Center this Line" })
  map("n", "-_", "zb", { desc = "Bottom this Line" })
  map("n", "-+", "zt", { desc = "Top this Line" })
  map("n", "-/", "zs", { desc = "Right this Line" })
  map("n", "-<", "ze", { desc = "Left this Line" })

  return hydra
end
return setmetatable(M, meta_M)
