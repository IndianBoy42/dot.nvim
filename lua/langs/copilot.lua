return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "zbirenbaum/copilot-cmp",
        opts = function()
          return {
            -- formatters = {
            --   insert_text = require("copilot_cmp.format").remove_existing,
            -- },
          }
        end,
      },
    },
    opts = function(_, opts)
      local cmp = require "cmp"
      opts.sources = cmp.config.sources(vim.list_extend({
        { name = "copilot" },
      }, opts.sources))
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "zbirenbaum/copilot.lua",
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
        -- copilot_node_command = "bun", -- Node.js version must be > 16.x
      },
      config = function(_, opts)
        require("copilot").setup(opts)
        -- TODO: telescope or virtual_lines display
        -- https://github.com/zbirenbaum/copilot.lua/blob/master/lua/copilot/api.lua
      end,
    },
  },
  -- {
  --   "dense-analysis/neural",
  --   dependencies = {
  --     { "ElPiloto/significant.nvim" },
  --     { "MunifTanjim/nui.nvim" },
  --   },
  --   config = function()
  --     require("neural").setup {}
  --   end,
  -- },
}
-- return {
--   "zbirenbaum/copilot-cmp",
--   dependencies = {
--     "zbirenbaum/copilot.lua",
--   },
--   event = "InsertEnter",
--   cmd = "Copilot",
--   config = function()
--     -- vim.defer_fn(function()
--     require("copilot").setup {
--       panel = {
--         auto_refresh = false,
--         layout = {
--           position = "right", -- | top | left | right
--           ratio = 0.4,
--         },
--       },
--     }
--     -- end, 500)
--     require("copilot_cmp").setup {
--       formatters = {
--         insert_text = require("copilot_cmp.format").remove_existing,
--       },
--     }
--   end,
-- }
