-- TODO:
vim.b.miniai_config = {
  custom_textobjects = { ["|"] = require("mini.ai").gen_spec.pair("|", "|", { type = "non-balanced" }) },
}
