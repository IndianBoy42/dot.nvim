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
  {
    "rrethy/vim-illuminate",
    cond = false,
    config = function() require("illuminate").configure {} end,
  },
  {
    "nullchilly/fsread.nvim",
    cmd = { "FSRead", "FSClear", "FSToggle" },
    keys = { { "<leader>TF", desc = "Flow State Read" } },
    config = function()
      Snacks.toggle {
        name = "Flow State Reading",
        get = function() return require("fsread").enabled() end,
        set = function(en)
          if en then
            vim.cmd.FSRead()
          else
            vim.cmd.FSClear()
          end
        end,
      }
    end,
  },
  -- TODO: https://github.com/Pocco81/high-str.nvim
}
