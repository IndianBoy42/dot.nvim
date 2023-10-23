-- TODO: set lualine theme
return {
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufWinEnter",
    config = function()
      require("colorizer").setup({ "*" }, {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
      })
      -- names    = true;         -- "Name" codes like Blue

      vim.cmd "ColorizerReloadAllBuffers"
    end,
  },
  -- Highlighting based extensions:
  { --folke/todo-comments.nvim
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    keys = {
      {
        "<leader>oT",
        "<cmd>TodoTrouble<cr>",
        desc = "TODOs sidebar",
      },
      {
        "<leader>sT",
        "<cmd>TodoTrouble<cr>",
        desc = "TODOs sidebar",
      },
      {
        "[T",
        utils.partial_require("todo-comments", "jump_prev"),
        desc = "Todo",
      },
      {
        "]T",
        utils.partial_require("todo-comments", "jump_next"),
        desc = "Todo",
      },
    },
    opts = {},
    event = { "BufReadPost", "BufNewFile" },
  },
  { --tzachar/local-highlight.nvim
    "tzachar/local-highlight.nvim",
    opts = {
      disable_file_types = { "tex" },
      -- hlgroup = "Underlined",
      -- hlgroup = "Search",
    },
    config = function(_, opts)
      require("local-highlight").setup(opts)
      vim.api.nvim_set_hl(0, "LocalHighlight", {
        underline = true,
        -- bold = true,
      })
    end,
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "nullchilly/fsread.nvim",
    cmd = { "FSRead", "FSClear", "FSToggle" },
    keys = { { "<leader>Tsf", "<cmd>FSToggle<cr>", desc = "Flow State Read" } },
  },
  -- TODO: https://github.com/Pocco81/high-str.nvim
}
