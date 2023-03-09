-- local theme_choice = "github_dark_default"
local theme_choice = vim.env.NVIM_THEME or "nebulous_night"
-- local theme_choice = "nightfox_dawnfox"
-- local theme_choice = "enfocado_neon"
-- local theme_choice = "catppuccin_mocha"
local is_active_theme = function(s)
  return string.sub(theme_choice, 1, #s) == s
end
local sub_theme = function(s, o)
  if is_active_theme(s) then
    return string.sub(theme_choice, #s + 2)
  else
    return o
  end
end

local config_colorscheme = function(name, cscheme)
  cscheme = cscheme or name
  return function(_, opts)
    require(name).setup(opts)
    vim.cmd.colorscheme(cscheme)
  end
end

vim.cmd [[
com! CheckHighlightUnderCursor echo {l,c,n ->
        \   'hi<'    . synIDattr(synID(l, c, 1), n)             . '> '
        \  .'trans<' . synIDattr(synID(l, c, 0), n)             . '> '
        \  .'lo<'    . synIDattr(synIDtrans(synID(l, c, 1)), n) . '> '
        \ }(line("."), col("."), "name")
]]
-- TODO: set lualine theme
return {
  -- Colorschemes
  { --Yagua/nebulous.nvim --
    "Yagua/nebulous.nvim",
    lazy = not is_active_theme "nebulous",
    -- cond = is_active_theme "nebulous",
    priority = 1000,
    opts = {
      variant = sub_theme("nebulous", "night"),
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
    },
    config = function(_, opts)
      require("nebulous").setup(opts)
      vim.api.nvim_create_user_command("Nebulous", function()
        require("nebulous").setup(opts)
        vim.cmd.VMTheme(vim.g.VM_Theme) -- weird, why have to reload?
      end, {})
    end,
    cmd = { "Nebulous" },
  },
  { --sam4llis/nvim-tundra
    "sam4llis/nvim-tundra",
    lazy = not is_active_theme "tundra",
    -- cond = is_active_theme "github",
    priority = 1000,
    opts = {
      transparent_background = false,
      dim_inactive_windows = {
        enabled = false,
        color = nil,
      },
      sidebars = {
        enabled = true,
        color = nil,
      },
      editor = {
        search = {},
        substitute = {},
      },
      syntax = {
        booleans = { bold = true, italic = true },
        comments = { bold = true, italic = true },
        conditionals = {},
        constants = { bold = true },
        fields = {},
        functions = {},
        keywords = {},
        loops = {},
        numbers = { bold = true },
        operators = { bold = true },
        punctuation = {},
        strings = {},
        types = { italic = true },
      },
      diagnostics = {
        errors = {},
        warnings = {},
        information = {},
        hints = {},
      },
      plugins = {
        lsp = true,
        treesitter = true,
        telescope = true,
        nvimtree = true,
        cmp = true,
        context = true,
        dbui = true,
        gitsigns = true,
        neogit = true,
      },
      overwrite = {
        colors = {},
        highlights = {},
      },
    },
    config = config_colorscheme("nvim-tundra", "tundra"),
  },
  { --projekt0n/github-nvim-theme
    "projekt0n/github-nvim-theme",
    lazy = not is_active_theme "github",
    -- cond = is_active_theme "github",
    priority = 1000,
    opts = { theme_style = sub_theme("github", "dark_default") },
    config = function(_, opts)
      require("github-theme").setup(opts)
    end,
  },
  { --rebelot/kanagawa.nvim
    "rebelot/kanagawa.nvim",
    lazy = not is_active_theme "kanagawa",
    -- cond = is_active_theme "kanagawa",
    opts = {
      compile = true,
      theme = sub_theme("kanagawa", "wave"),
      background = { -- map the value of 'background' option to a theme
        dark = sub_theme("kanagawa", "wave"), -- try "dragon" !
        light = "lotus",
      },
    },
    config = config_colorscheme("kanagawa", "kanagawa"),
    priority = 1000,
  },
  { --folke/tokyonight.nvim
    "folke/tokyonight.nvim",
    lazy = not is_active_theme "tokyonight",
    priority = 1000,
    opts = {
      style = sub_theme("tokyonight", "night"),
    },
    config = config_colorscheme "tokyonight",
  },
  { --EdenEast/nightfox.nvim
    "EdenEast/nightfox.nvim",
    lazy = not is_active_theme "nightfox",
    priority = 1000,
    opts = {},
    config = config_colorscheme("nightfox", "carbonfox"),
  },
  { --nyoom-engineering/oxocarbon.nvim
    "nyoom-engineering/oxocarbon.nvim",
    lazy = not is_active_theme "oxocarbon",
    priority = 1000,
    config = false,
  },
  { --wuelnerdotexe/vim-enfocado
    "wuelnerdotexe/vim-enfocado",
    lazy = not is_active_theme "enfocado",
    init = function()
      vim.g.enfocado_style = sub_theme("enfocado", "neon")
      vim.cmd.colorscheme "enfocado"
    end,
    priority = 1000,
    config = false,
  },
  { --NTBBloodbath/sweetie.nvim
    "NTBBloodbath/sweetie.nvim",
    lazy = not is_active_theme "sweetie",
    opts = {},
    config = config_colorscheme("sweetie", "sweetie"),
    priority = 1000,
  },
  { --catppuccin/nvim
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = not is_active_theme "catppuccin",
    -- cond = is_active_theme "catppuccin",
    priority = 1000,
    opts = {
      flavour = sub_theme("catppuccin", "mocha"),
      color_overrides = {
        mocha = {
          -- base = "#000000",
          -- mantle = "#000000",
          -- crust = "#000000",
          rosewater = "#F5E0DC",
          flamingo = "#F2CDCD",
          mauve = "#DDB6F2",
          pink = "#F5C2E7",
          red = "#F28FAD",
          maroon = "#E8A2AF",
          peach = "#F8BD96",
          yellow = "#FAE3B0",
          green = "#ABE9B3",
          blue = "#96CDFB",
          sky = "#89DCEB",
          teal = "#B5E8E0",
          lavender = "#C9CBFF",

          text = "#D9E0EE",
          subtext1 = "#BAC2DE",
          subtext0 = "#A6ADC8",
          overlay2 = "#C3BAC6",
          overlay1 = "#988BA2",
          overlay0 = "#6E6C7E",
          surface2 = "#6E6C7E",
          surface1 = "#575268",
          surface0 = "#302D41",

          base = "#1E1E2E",
          mantle = "#1A1826",
          crust = "#161320",
        },
      },
      highlight_overrides = {
        mocha = function(cp)
          return {
            -- For base configs.
            NormalFloat = { fg = cp.text, bg = transparent_background and cp.none or cp.base },
            CursorLineNr = { fg = cp.green },
            Search = { bg = cp.surface1, fg = cp.pink, style = { "bold" } },
            IncSearch = { bg = cp.pink, fg = cp.surface1 },
            Keyword = { fg = cp.pink },
            Type = { fg = cp.blue },
            Typedef = { fg = cp.yellow },
            StorageClass = { fg = cp.red, style = { "italic" } },
            -- For native lsp configs.
            DiagnosticVirtualTextError = { bg = cp.none },
            DiagnosticVirtualTextWarn = { bg = cp.none },
            DiagnosticVirtualTextInfo = { bg = cp.none },
            DiagnosticVirtualTextHint = { fg = cp.rosewater, bg = cp.none },
            DiagnosticHint = { fg = cp.rosewater },
            LspDiagnosticsDefaultHint = { fg = cp.rosewater },
            LspDiagnosticsHint = { fg = cp.rosewater },
            LspDiagnosticsVirtualTextHint = { fg = cp.rosewater },
            LspDiagnosticsUnderlineHint = { sp = cp.rosewater },
            -- For fidget.
            FidgetTask = { bg = cp.none, fg = cp.surface2 },
            FidgetTitle = { fg = cp.blue, style = { "bold" } },
            -- For trouble.nvim
            TroubleNormal = { bg = cp.base },
            -- For treesitter.
            ["@field"] = { fg = cp.rosewater },
            ["@property"] = { fg = cp.yellow },
            ["@include"] = { fg = cp.teal },
            -- ["@operator"] = { fg = cp.sky },
            ["@keyword.operator"] = { fg = cp.sky },
            ["@punctuation.special"] = { fg = cp.maroon },
            -- ["@float"] = { fg = cp.peach },
            -- ["@number"] = { fg = cp.peach },
            -- ["@boolean"] = { fg = cp.peach },

            ["@constructor"] = { fg = cp.lavender },
            -- ["@constant"] = { fg = cp.peach },
            -- ["@conditional"] = { fg = cp.mauve },
            -- ["@repeat"] = { fg = cp.mauve },
            ["@exception"] = { fg = cp.peach },
            ["@constant.builtin"] = { fg = cp.lavender },
            -- ["@function.builtin"] = { fg = cp.peach, style = { "italic" } },
            -- ["@type.builtin"] = { fg = cp.yellow, style = { "italic" } },
            ["@type.qualifier"] = { link = "@keyword" },
            ["@variable.builtin"] = { fg = cp.red, style = { "italic" } },
            -- ["@function"] = { fg = cp.blue },
            ["@function.macro"] = { fg = cp.red, style = {} },
            ["@parameter"] = { fg = cp.rosewater },
            ["@keyword"] = { fg = cp.red, style = { "italic" } },
            ["@keyword.function"] = { fg = cp.maroon },
            ["@keyword.return"] = { fg = cp.pink, style = {} },
            -- ["@text.note"] = { fg = cp.base, bg = cp.blue },
            -- ["@text.warning"] = { fg = cp.base, bg = cp.yellow },
            -- ["@text.danger"] = { fg = cp.base, bg = cp.red },
            -- ["@constant.macro"] = { fg = cp.mauve },

            -- ["@label"] = { fg = cp.blue },
            ["@method"] = { fg = cp.blue, style = { "italic" } },
            ["@namespace"] = { fg = cp.rosewater, style = {} },
            ["@punctuation.delimiter"] = { fg = cp.teal },
            ["@punctuation.bracket"] = { fg = cp.overlay2 },
            -- ["@string"] = { fg = cp.green },
            -- ["@string.regex"] = { fg = cp.peach },
            ["@type"] = { fg = cp.yellow },
            ["@variable"] = { fg = cp.text },
            ["@tag.attribute"] = { fg = cp.mauve, style = { "italic" } },
            ["@tag"] = { fg = cp.peach },
            ["@tag.delimiter"] = { fg = cp.maroon },
            ["@text"] = { fg = cp.text },
            -- ["@text.uri"] = { fg = cp.rosewater, style = { "italic", "underline" } },
            -- ["@text.literal"] = { fg = cp.teal, style = { "italic" } },
            -- ["@text.reference"] = { fg = cp.lavender, style = { "bold" } },
            -- ["@text.title"] = { fg = cp.blue, style = { "bold" } },
            -- ["@text.emphasis"] = { fg = cp.maroon, style = { "italic" } },
            -- ["@text.strong"] = { fg = cp.maroon, style = { "bold" } },
            -- ["@string.escape"] = { fg = cp.pink },

            -- ["@property.toml"] = { fg = cp.blue },
            -- ["@field.yaml"] = { fg = cp.blue },

            -- ["@label.json"] = { fg = cp.blue },

            ["@function.builtin.bash"] = { fg = cp.red, style = { "italic" } },
            ["@parameter.bash"] = { fg = cp.yellow, style = { "italic" } },
            ["@field.lua"] = { fg = cp.lavender },
            ["@constructor.lua"] = { fg = cp.flamingo },
            ["@constant.java"] = { fg = cp.teal },
            ["@property.typescript"] = { fg = cp.lavender, style = { "italic" } },
            -- ["@constructor.typescript"] = { fg = cp.lavender },

            -- ["@constructor.tsx"] = { fg = cp.lavender },
            -- ["@tag.attribute.tsx"] = { fg = cp.mauve },

            ["@type.css"] = { fg = cp.lavender },
            ["@property.css"] = { fg = cp.yellow, style = { "italic" } },
            ["@type.builtin.c"] = { fg = cp.yellow, style = {} },
            ["@property.cpp"] = { fg = cp.text },
            ["@type.builtin.cpp"] = { fg = cp.yellow, style = {} },
            -- ["@symbol"] = { fg = cp.flamingo },
          }
        end,
      },
    },
    config = function(_, opts)
      local transparent_background = false -- Set background transparency here!
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme "catppuccin"
    end,
  },
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
        "<leader>do",
        "<cmd>TodoTrouble<cr>",
        desc = "TODOs sidebar",
      },
      {
        "[T",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Todo",
      },
      {
        "]T",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Todo",
      },
    },
    opts = {},
    event = { "BufReadPost", "BufNewFile" },
  },
  { --giusgad/pets.nvim
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
  { --tamton-aquib/duck.nvim
    "tamton-aquib/duck.nvim",
    keys = {
      {
        "gzd",
        function()
          -- 🦆 ඞ  🦀 🐈 🐎 🦖 🐤
          require("duck").hatch("🦆", "10")
        end,
        desc = "hatch a duck",
      },
    },
  },
  { --tzachar/local-highlight.nvim
    "tzachar/local-highlight.nvim",
    opts = {},
    config = function(_, opts)
      require("local-highlight").setup(opts)
      -- vim.api.nvim_create_autocmd("BufRead", {
      --   pattern = { "*.*" },
      --   callback = function(data)
      --     require("local-highlight").attach(data.buf)
      --   end,
      -- })
    end,
    event = { "BufReadPost", "BufNewFile" },
  },
}
