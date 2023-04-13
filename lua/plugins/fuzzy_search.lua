return {
  {
    "tzachar/fuzzy.nvim",
  },
  {
    "IndianBoy42/fuzzy_slash.nvim",
    dev = true,
    dependencies = { "tzachar/fuzzy.nvim" },
    opts = { register_nN_repeat = mappings.register_nN_repeat },
    cmd = { "Fz" },
    keys = { { "<leader>si", ":Fz ", desc = "in Buffer" } },
  },
}
