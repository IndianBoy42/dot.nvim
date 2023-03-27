local source = "codeium"
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "zbirenbaum/copilot-cmp",
        cond = source == "copilot",
        opts = {},
      },
      {
        "jcdickinson/codeium.nvim",
        dependencies = {
          { "jcdickinson/http.nvim", build = "cargo build --workspace --release" },
          "nvim-lua/plenary.nvim",
          "hrsh7th/nvim-cmp",
        },
        cond = source == "codeium",
        cmd = { "Codeium" },
        opts = {},
      },
    },
    opts = function(_, opts)
      local cmp = require "cmp"
      opts.sources = cmp.config.sources(vim.list_extend({
        { name = source },
      }, opts.sources))
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "zbirenbaum/copilot.lua",
        cond = source == "copilot",
        opts = {
          -- panel = {
          --   auto_refresh = false,
          --   layout = {
          --     position = "right", -- | top | left | right
          --     ratio = 0.4,
          --   },
          -- },
          suggestion = { enabled = false },
          panel = { enabled = false },
        },
        config = function(_, opts)
          require("copilot").setup(opts)
          -- TODO: telescope or virtual_lines display
          -- https://github.com/zbirenbaum/copilot.lua/blob/master/lua/copilot/api.lua
        end,
      },
    },
  },
}
