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
      { "<F5>", "<Plug>(YankyCycleForward)", mode = { "n", "x" } },
      { "<M-F5>", "<Plug>(YankyCycleBackward)", mode = { "n", "x" } },
    },
  },
}
