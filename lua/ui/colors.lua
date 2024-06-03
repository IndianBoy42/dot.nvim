-- TODO: set lualine theme
return {
  {
    "nvchad/nvim-colorizer.lua",
    event = { "BufWinEnter" },
    config = function()
      require("colorizer").setup {
        RGB = true, -- #RGB hex codes
        names = false,
        RRGGBB = true, -- #RRGGBB hex codes
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = true, -- 0xAARRGGBB hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
      }
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
        "<leader>ost",
        "<cmd>TodoTrouble<cr>",
        desc = "TODOs",
      },
      { "[c" },
      { "]c" },
    },
    opts = {},
    event = "LazyFile",
    config = function(_, opts)
      require("todo-comments").setup(opts)
      mappings.repeatable("c", "Todo Comments", {
        require("todo-comments").jump_next,
        require("todo-comments").jump_prev,
      })
    end,
  },
  { --tzachar/local-highlight.nvim
    "tzachar/local-highlight.nvim",
    opts = {
      disable_file_types = { "tex", "lua" },
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
    event = "LazyFile",
  },
  {
    "rrethy/vim-illuminate",
    cond = false,
    config = function() require("illuminate").configure {} end,
  },
  {
    "nullchilly/fsread.nvim",
    cmd = { "FSRead", "FSClear", "FSToggle" },
    keys = { { "<leader>Tsf", "<cmd>FSToggle<cr>", desc = "Flow State Read" } },
  },
  -- TODO: https://github.com/Pocco81/high-str.nvim
}
