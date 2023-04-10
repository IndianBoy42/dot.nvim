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
  {
    "anuvyklack/keymap-amend.nvim",
    config = function() vim.keymap.amend = require "keymap-amend" end,
    lazy = false,
  },
}
-- TODO: legendary.nvim
