local sethl = vim.api.nvim_set_hl
local highlights = {
  RainbowRed = "#E06C75",
  RainbowYellow = "#E5C07B",
  RainbowBlue = "#61AFEF",
  RainbowOrange = "#D19A66",
  RainbowGreen = "#98C379",
  RainbowViolet = "#C678DD",
  RainbowCyan = "#56B6C2",
}

local ibl3 = {
  "lukas-reineke/indent-blankline.nvim",
  --https://github.com/lukas-reineke/indent-blankline.nvim/pull/612
  event = { "BufReadPost", "BufNewFile" },
  -- branch = "v3",
  main = "ibl",
  opts = {
    indent = {
      highlight = vim.tbl_keys(highlights),
    },
    exclude = {
      filetypes = { "help", "dashboard", "terminal" },
      buftypes = { "terminal", "nofile" },
    },
  },
  config = function(_, opts)
    local hooks = require "ibl.hooks"
    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      for k, v in pairs(highlights) do
        sethl(0, k, { fg = v })
      end
    end)

    require("ibl").setup(opts)
  end,
}
local ibl2 = { --lukas-reineke/indent-blankline.nvim
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
}
return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = { highlight = highlights },
    config = function(_, opts) require "rainbow-delimiters.setup"(opts) end,
  },
  -- ibl3,
  {
    "HampusHauffman/block.nvim",
    cmd = { "Block", "BlockOn", "BlockOff" },
    opts = { percent = 1.20, depth = 10, automatic = true },
    -- event = { "BufReadPost", "BufNewFile" },
  },
}
