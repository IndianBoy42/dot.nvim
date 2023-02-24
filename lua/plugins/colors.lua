return {
  {
    "Yagua/nebulous.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nebulous").setup {
        variant = "night",
        italic = {
          comments = true,
          keywords = false,
          functions = false,
          variables = false,
        },
        custom_colors = { -- FIXME: custom colors not bound
          -- Conceal = { ctermfg = "223", ctermbg = "235 ", guifg = "#ebdbb2", guibg = "#282828" },
          LspReferenceRead = { style = "bold", bg = "#464646" },
          LspReferenceText = { style = "bold", bg = "#464646" },
          LspReferenceWrite = { style = "bold", bg = "#464646" },
        },
      }
    end,
  },
  { "rebelot/kanagawa.nvim",       lazy = true,                            priority = 1000 },
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
  "folke/lsp-colors.nvim",
  { "mrjones2014/nvim-ts-rainbow", event = { "BufReadPost", "BufNewFile" } },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      vim.cmd [[highlight IndentBlanklineIndent6 guifg=#000000 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent5 guifg=#000000 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent4 guifg=#000000 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent3 guifg=#000000 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent2 guifg=#000000 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent1 guifg=#000000 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent5 guifg=#E06C75 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent4 guifg=#E5C07B gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent3 guifg=#98C379 gui=nocombine]]
      -- vim.cmd [[highlight IndentBlanklineIndent2 guifg=#56B6C2 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent2 guifg=#61AFEF gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent1 guifg=#C678DD gui=nocombine]]
      -- vim.cmd [[highlight IndentBlanklineIndent1 guibg=#1f1f1f gui=nocombine]]
      -- vim.cmd [[highlight IndentBlanklineIndent2 guibg=#1a1a1a gui=nocombine]]

      -- vim.opt.list = true
      -- vim.opt.listchars:append "space:⋅"
      -- vim.opt.listchars:append "eol:↴"

      require("indent_blankline").setup {
        char = "▏",
        filetype_exclude = { "help", "terminal", "dashboard" },
        buftype_exclude = { "terminal", "nofile" },
        char_highlight = "LineNr",
        show_trailing_blankline_indent = false,
        -- show_first_indent_level = false,
        space_char_blankline = " ",
        show_current_context = false,
        show_current_context_start = true,
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
      }
    end,
  },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "giusgad/pets.nvim",
    opts = {
      random = true,
    },
    dependencies = { "MunifTanjim/nui.nvim", "edluffy/hologram.nvim" },
    cmd = {
      "PetsNew",
      "PetsNewCustom",
      "PetsList",
      "PetsKill",
      "PetsKillAll",
      "PetsPauseToggle",
      "PetsHideToggle",
      "PetsSleepToggle",
    },
  },
}
