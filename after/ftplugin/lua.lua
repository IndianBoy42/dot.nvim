vim.b.minisurround_config = {
  custom_surroundings = {
    Q = {
      input = { "%[%[().-()%]%]" },
      output = { left = "[[", right = "]]" },
    },
    ["#"] = {
      input = { "--%[%[().-()%]%]" },
      output = { left = [[--[[]], right = "]]" },
    },
    f = {
      output = { left = "function()\n", right = "\nend" },
    },
  },
}
local pair = require("mini.ai").gen_spec.pair
vim.b.miniai_config = {
  custom_textobjects = {
    Q = pair("[[", "]]", { type = "non-balanced" }),
    ["#"] = pair([[--[[]], "]]", { type = "non-balanced" }),
  },
}
-- TODO: text objects for lua raw strings

local map = vim.keymap.setl

vim.o.shiftwidth = 2
vim.o.tabstop = 2
