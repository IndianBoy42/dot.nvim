return {
  "ckolkey/ts-node-action",
  dependencies = { "nvim-treesitter" },
  cmd = "NodeAction",
  keys = {
    { "<leader>ea", "<cmd>NodeAction<cr>", desc = "TS Node Action" },
  },
  config = function()
    local helpers = require "ts-node-action.helpers"
    local builtins = require "ts-node-action.actions"
    local actions = {
      -- TODO:
      ["*"] = {},
    }
    require("ts-node-action").setup(actions)
    require("null-ls").register {
      name = "more_actions",
      method = { require("null-ls").methods.CODE_ACTION },
      filetypes = { "_all" },
      generator = {
        fn = require("ts-node-action").available_actions,
      },
    }
  end,
}
