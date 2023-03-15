return {
  -- { "liangxianzhe/nap.nvim" },
  { "zdcthomas/yop.nvim" },

  {
    "max397574/better-escape.nvim",
    opts = {
      mapping = { "jk", "kj" },
      keys = "<Esc>",
    },
    event = "InsertEnter",
  },
  "anuvyklack/hydra.nvim",
}
