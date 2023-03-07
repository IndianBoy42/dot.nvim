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
