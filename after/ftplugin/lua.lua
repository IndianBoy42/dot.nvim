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

require("editor.nav.ai").lazy(function(spec) return { Q = spec.pair("[[", "]]", { type = "non-balanced" }) } end)

vim.o.shiftwidth = 2
vim.o.tabstop = 2
