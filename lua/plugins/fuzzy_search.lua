return {
  {
    "IndianBoy42/fuzzy.nvim",
  },
  {
    "IndianBoy42/fuzzy_slash.nvim",
    dev = true,
    opts = { register_nN_repeat = mappings.register_nN_repeat },
    cmd = { "Fz", "FzTsLocals", "FzDiags", "FzTsObjects", "FzClear" },
    keys = { { "<leader>si", ":Fz ", desc = "in Buffer" }, { "?", ":Fz ", desc = "in Buffer" } },
  },
  {
    "rlane/pounce.nvim",
    -- TODO: OR https://github.com/atusy/leap-search.nvim
    keys = {
      {
        "<leader>sp",
        function()
          mappings.register_nN_repeat { "<cmd>PounceRepeat<cr>", "<cmd>PounceRepeat<cr>" }
          -- vim.cmd.Pounce()
          require("pounce").pounce()
        end,
        desc = "Fuzzy",
      },
    },
    cmd = { "Pounce" },
    opts = {
      accept_keys = O.hint_labels:upper(),
    },
  },
}
