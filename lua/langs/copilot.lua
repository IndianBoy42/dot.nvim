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
      opts.sources = vim.list_extend({
        {
          name = source,
          group_index = 2,
          max_item_count = 5,
        },
      }, opts.sources)
      if source == "copilot" then
        local cmp = require "cmp"
        opts.sorting = {
          priority_weight = 2,
          comparators = {
            require("copilot_cmp.comparators").prioritize,

            -- Below is the default comparitor list and order for nvim-cmp
            cmp.config.compare.offset,
            -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        }
      end
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
          panel = {
            enabled = true,
            jump_prev = "<C-n>",
            jump_next = "<C-p>",
            accept = "<CR>",
            refresh = "<C-r>",
            open = "<M-CR>",
          },
          filetypes = { TelescopePrompt = false },
        },
        config = function(_, opts)
          require("copilot").setup(opts)
          -- TODO: telescope or virtual_lines display
          -- https://github.com/zbirenbaum/copilot.lua/blob/master/lua/copilot/api.lua
        end,
        keys = { { "<leader>np", "i<cmd>Copilot panel<cr>" } },
      },
    },
  },
}
