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
  { "HiPhish/nvim-ts-rainbow2", event = { "BufReadPost", "BufNewFile" } },
  { --lukas-reineke/indent-blankline.nvim
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    -- opts = {
    --   setup = function()
    --     vim.cmd [[highlight IndentBlanklineIndent1 guibg=#000000 gui=nocombine]]
    --     vim.cmd [[highlight IndentBlanklineIndent2 guibg=#1a1a1a gui=nocombine]]
    --   end,
    --   char = "",
    --   char_highlight_list = {
    --     "IndentBlanklineIndent1",
    --     "IndentBlanklineIndent2",
    --   },
    --   space_char_highlight_list = {
    --     "IndentBlanklineIndent1",
    --     "IndentBlanklineIndent2",
    --   },
    --   show_trailing_blankline_indent = false,
    --   show_current_context = true,
    --   show_current_context_start = false,
    -- },
    opts = {
      setup = function()
        -- vim.cmd [[highlight IndentBlanklineIndent6 guifg=#000000 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent5 guifg=#000000 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent4 guifg=#000000 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent3 guifg=#000000 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent2 guifg=#000000 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent1 guifg=#000000 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent5 guifg=#E06C75 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent4 guifg=#E5C07B gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent3 guifg=#98C379 gui=nocombine]]
        -- -- vim.cmd [[highlight IndentBlanklineIndent2 guifg=#56B6C2 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent2 guifg=#61AFEF gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent1 guifg=#C678DD gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent1 guibg=#1f1f1f gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent2 guibg=#1a1a1a gui=nocombine]]
      end,
      char = "▏",
      filetype_exclude = { "help", "terminal", "dashboard" },
      buftype_exclude = { "terminal", "nofile" },
      char_highlight = "LineNr",
      show_trailing_blankline_indent = false,
      -- show_first_indent_level = false,
      space_char_blankline = " ",
      show_current_context = true,
      show_current_context_start = false,
      char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
        "IndentBlanklineIndent3",
        "IndentBlanklineIndent4",
        "IndentBlanklineIndent5",
        "IndentBlanklineIndent6",
      },
      -- space_char_highlight_list = {
      --   "IndentBlanklineIndent1",
      --   "IndentBlanklineIndent2",
      -- },
    },
    config = function(_, opts)
      opts.setup()
      opts.setup = nil

      -- vim.opt.list = true
      -- vim.opt.listchars:append "space:⋅"
      -- vim.opt.listchars:append "eol:↴"

      require("indent_blankline").setup(opts)
    end,
  },
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
    keys = { { "<leader>Tf", "<cmd>FSToggle<cr>", desc = "Flow State Read" } },
  },
  -- TODO: https://github.com/Pocco81/high-str.nvim
}
