-- TODO:
vim.b.miniai_config = {
  custom_textobjects = { ["|"] = require("mini.ai").gen_spec.pair("|", "|", { type = "non-balanced" }) },
}
vim.b.minisurround_config = {
  custom_surroundings = {
    ["|"] = { output = { left = "|", right = "|" }, input = { "|().-()|" } },
    ["d"] = { output = { left = "dbg!(", right = ")" }, input = { "dbg!%(().-()%)" } },
  },
}
