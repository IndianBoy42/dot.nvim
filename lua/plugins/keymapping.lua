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
    dev = true,
    config = function()
      local a = require "keymap-amend"
      vim.keymap.amend = a.amend
      vim.keymap.get = a.get
    end,
    lazy = false,
  },
}
-- TODO: legendary.nvim
