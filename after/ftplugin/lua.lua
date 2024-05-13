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
vim.schedule(function()
  local pair = require("mini.ai").gen_spec.pair
  -- TODO: text objects for lua raw strings
  vim.b.miniai_config = {
    custom_textobjects = {
      Q = pair("[[", "]]", { type = "non-balanced" }),
      ["#"] = pair([[--[[]], "]]", { type = "non-balanced" }),
    },
  }
end)

local map = vim.keymap.setl

vim.o.shiftwidth = 2
vim.o.tabstop = 2
