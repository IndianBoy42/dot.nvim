return {
  -- TODO: https://github.com/gbprod/yanky.nvim
  {
    "gbprod/yanky.nvim",
    opts = {},
    keys = {
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" } },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" } },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" } },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" } },
      { "<C-p>", "<Plug>(YankyCycleForward)", mode = { "n", "x" } },
      { "<C-S-p>", "<Plug>(YankyCycleBackward)", mode = { "n", "x" } },
    },
  },
}
