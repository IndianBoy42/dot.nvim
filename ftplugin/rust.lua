-- TODO:
local pair = require("mini.ai").gen_spec.pair
vim.b.miniai_config = {
  custom_textobjects = {
    ["|"] = pair("|", "|", { type = "non-balanced" }),
    ["#"] = pair("/*", "*/", { type = "non-balanced" }),
    d = pair("dbg!(", ")", { type = "non-balanced" }),
  },
}
vim.b.minisurround_config = {
  custom_surroundings = {
    ["|"] = { output = { left = "|", right = "|" }, input = { "|().-()|" } },
    d = { output = { left = "dbg!(", right = ")" }, input = { "dbg!%(().-()%)" } },
    ["#"] = { output = { left = "/*", right = "*/" }, input = { [[/%*().-()%*/]] } },
  },
}
