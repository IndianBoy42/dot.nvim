return {
  {
    "IndianBoy42/fuzzy.nvim",
  },
  {
    "IndianBoy42/fuzzy_slash.nvim",
    dev = true,
    opts = { register_nN_repeat = mappings.register_nN_repeat },
    cmd = { "Fz", "FzTsLocals", "FzDiags", "FzTsObjects", "FzClear" },
    keys = { { "<leader>si", ":Fz ", desc = "in Buffer" }, { "<leader>s?", ":Fz ", desc = "in Buffer" } },
  },
}
