vim.b.minisurround_config = {
  custom_surroundings = {
    s = {
      input = { "%[%[().-()%]%]" },
      output = { left = "[[", right = "]]" },
    },
  },
}
-- TODO: text objects for lua raw strings

local sa = require "sniprun.api"
local map = vim.keymap.setl

vim.o.shiftwidth = 2
vim.o.tabstop = 2
