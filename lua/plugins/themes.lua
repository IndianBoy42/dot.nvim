--TODO: https://github.com/folke/styler.nvim
local bg = vim.env.NVIM_THEME_BG or "dark"
vim.opt.background = bg
local theme_choice = ({
  dark = vim.env.NVIM_THEME or "onedark_darker",
  light = vim.env.NVIM_LIGHT_THEME or "zenbones_zenwritten", -- tokyobones
})[bg]
-- local theme_choice = "tokyodark"
-- local theme_choice = "tokyonight_night"
-- local theme_choice = "nebulous_night"
local nebulous_bg = "#03070e"
local is_active_theme = function(s) return string.sub(theme_choice, 1, #s) == s end
local sub_theme = function(s, o)
  if is_active_theme(s) then
    local sub = string.sub(theme_choice, #s + 2)
    if #sub > 0 then return sub end
  end
  return o
end

local config_colorscheme = function(name, cscheme, cb)
  cscheme = cscheme or name
  return function(_, opts)
    require(name).setup(opts)
    vim.cmd.colorscheme(cscheme)
    if cb then vim.api.nvim_create_autocmd("ColorScheme", {
      callback = cb,
    }) end
  end
end

local enhance_cscheme = function(name, cb)
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function(args)
      if args.match == name then cb(args) end
    end,
  })
end

local function get_hl(name) return vim.api.nvim_get_hl(-1, { name = name }) end

local hilight_comments = {

  de_lighted = true,
  cache_comment_hl = {},
  comment_hl_name = { "@comment", "Comment" },
  bright_hl = function()
    local bright_hl_name = "DiagnosticVirtualTextHint"
    -- local bright_hl_name = "@text.strong"
    local hl = vim.api.nvim_get_hl(-1, { name = bright_hl_name })
    hl = vim.tbl_deep_extend("force", hl, {
      bg = hl.foreground,
      fg = "white",
      bold = true,
    })
    return hl
  end,
}
vim.api.nvim_create_user_command("HiLightComments", function()
  if not hilight_comments.de_lighted then return end
  local hl = vim.api.nvim_get_hl(-1, { name = hilight_comments.comment_hl_name[1] })
  hilight_comments.cache_comment_hl = vim.deepcopy(hl)
  hl = hilight_comments.bright_hl()

  for _, n in ipairs(hilight_comments.comment_hl_name) do
    vim.api.nvim_set_hl(0, n, hl)
  end
  hilight_comments.de_lighted = false
end, {})
vim.api.nvim_create_user_command("DeLightComments", function()
  if hilight_comments.de_lighted then return end
  local hl = hilight_comments.cache_comment_hl
  for _, n in ipairs(hilight_comments.comment_hl_name) do
    vim.api.nvim_set_hl(0, n, hl)
  end
  hilight_comments.de_lighted = true
end, {})
vim.api.nvim_create_user_command("ToggleHiLightComments", function()
  if hilight_comments.de_lighted then
    vim.cmd "HiLightComments"
  else
    vim.cmd "DeLightComments"
  end
end, {})

return {
  -- Colorschemes
  { -- "navarasu/onedark.nvim",
    "navarasu/onedark.nvim",
    lazy = not is_active_theme "onedark",
    priority = 1000,
    opts = {
      style = sub_theme("onedark", "darker"),
      code_style = {
        comments = "italic",
        strings = "italic",
        keywords = "none",
        -- functions = "underline",
        -- variables = "underline",
      },
      colors = {
        -- Darken backgrounds
        bg_d = "#181b20",
        bg0 = "#181b20",
        bg1 = "#1f2329",
        bg2 = "#282c34",
        bg3 = "#30363f",
      },
    },
    init = function()
      enhance_cscheme("onedark", function()
        local maps = {
          ["@lsp.type.class"] = { link = "Structure" },
          ["@lsp.type.decorator"] = { link = "Function" },
          -- ["@lsp.type.enum"] = { link = "Structure" },
          ["@lsp.type.enumMember"] = { link = "Constant" },
          ["@lsp.type.function"] = { link = "Function" },
          -- ["@lsp.type.interface"] = { link = "Structure" },
          ["@lsp.type.macro"] = { link = "Macro" },
          ["@lsp.type.method"] = { link = "Function" },
          -- ["@lsp.type.namespace"] = { link = "Structure" },
          -- ["@lsp.type.parameter"] = { link = "Identifier" },
          -- ["@lsp.type.property"] = { link = "Identifier" },
          ["@lsp.type.struct"] = { link = "Structure" },
          ["@lsp.type.type"] = { link = "Type" },
          ["@lsp.type.typeParameter"] = { link = "TypeDef" },
          -- ["@lsp.type.variable"] = { link = "Identifier" },
          -- Above this is builtins
          -- Below are custom definition
          ["@lsp.type.comment"] = { link = "@comment" },
          ["@lsp.type.enum"] = { link = "@type" },
          -- ["@lsp.type.interface"] = { link = "Identifier" },
          ["@lsp.type.keyword"] = { link = "@keyword" },
          ["@lsp.type.namespace"] = { link = "@namespace" },
          ["@lsp.type.parameter"] = { link = "@parameter" },
          ["@lsp.type.property"] = { link = "@field" },
          ["@lsp.type.variable"] = {}, -- use treesitter styles for regular variables
          ["@lsp.typemod.method.defaultLibrary"] = { link = "@function.builtin" },
          ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
          ["@lsp.typemod.operator.injected"] = { link = "@operator" },
          ["@lsp.typemod.string.injected"] = { link = "@string" },
          ["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
          ["@lsp.typemod.variable.injected"] = { link = "@variable" },
          -- Below are language customs
          ["@lsp.type.enumMember.rust"] = { link = "@type" },
          ["@lsp.mod.mutable.rust"] = { bg = get_hl("DiagnosticVirtualTextHint").background },
          ["@lsp.mod.reference.rust"] = { bg = get_hl("DiagnosticVirtualTextInfo").background },
          ["LspInlayHint"] = { link = "DiagnosticVirtualTextInfo" },
        }
        for k, v in pairs(maps) do
          vim.api.nvim_set_hl(0, k, v)
        end
      end)
    end,
    config = config_colorscheme("onedark", "onedark"),
  },
  { -- "olimorris/onedarkpro.nvim",
    "olimorris/onedarkpro.nvim",
    lazy = not is_active_theme "onedarkpro",
    priority = 1000,
    opts = {
      styles = {
        strings = "italic",
        comments = "italic",
        numbers = "NONE",
        constants = "NONE",
        keywords = "NONE",
        types = "NONE",
        methods = "NONE",
        functions = "NONE",
        operators = "NONE",
        variables = "NONE",
        parameters = "NONE",
        conditionals = "NONE",
        virtual_text = "NONE",
      },
      options = {
        highlight_inactive_windows = false, -- When the window is out of focus, change the normal background?
      },
    },
    config = config_colorscheme("onedarkpro", "onedark_dark"),
  },
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
    opts = {
      theme_style = sub_theme("github", "dark_default"),
      comment_style = "italic",
      keyword_style = "italic",
      function_style = "italic",
      variable_style = "italic",
    },
    config = config_colorscheme("github-theme", "github_" .. sub_theme("github", "dark_default")),
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
      on_colors = function(colors)
        colors.bg_dark = nebulous_bg
        colors.bg = colors.bg_dark

        if false then
          colors.none = "NONE"
          colors.bg_dark = "#1f2335"
          colors.bg = "#242424"
          colors.bg_highlight = "#292929"
          colors.terminal_black = "#414141"
          colors.fg = "#c7c7c7"
          colors.fg_dark = "#a1a1a1"
          colors.fg_gutter = "#3b3b3b"
          colors.dark3 = "#5a5a5a"
          colors.comment = "#6e6e6e"
          colors.dark5 = "#8c8c8c"
          colors.blue0 = "#3c7dcf"
          colors.blue = "#7dbbff"
          colors.cyan = "#7dcfff"
          colors.blue1 = "#2ac3de"
          colors.blue2 = "#0db9d7"
          colors.blue5 = "#a0ddff"
          colors.blue6 = "#d1f9ff"
          colors.blue7 = "#394b70"
          colors.magenta = "#c574dd"
          colors.magenta2 = "#ff007c"
          colors.purple = "#a57de8"
          colors.orange = "#ff9e64"
          colors.yellow = "#e0af68"
          colors.green = "#9ece6a"
          colors.green1 = "#73daca"
          colors.green2 = "#41a6b5"
          colors.teal = "#1abc9c"
          colors.red = "#ff869a"
          colors.red1 = "#db4b4b"
          colors.git = { change = "#6183bb", add = "#449dab", delete = "#914c54" }
          colors.gitSigns = { add = "#266d6a", change = "#536c9e", delete = "#b2555b" }
        else
          colors.none = "NONE"
          colors.bg_dark = "#1f1f1f"
          colors.bg = "#242424"
          colors.bg_highlight = "#292929"
          colors.terminal_black = "#414141"
          colors.fg = "#c7c7c7"
          colors.fg_dark = "#a1a1a1"
          colors.fg_gutter = "#3b3b3b"
          colors.dark3 = "#5a5a5a"
          colors.comment = "#6e6e6e"
          colors.dark5 = "#8c8c8c"
          colors.blue0 = "#7daaff"
          colors.blue = "#aaffff"
          colors.cyan = "#7dcfff"
          colors.blue1 = "#2ac3de"
          colors.blue2 = "#0db9d7"
          colors.blue5 = "#a0ddff"
          colors.blue6 = "#d1f9ff"
          colors.blue7 = "#394b70"
          colors.magenta = "#ff9bff"
          colors.magenta2 = "#ff007c"
          colors.purple = "#c97bff"
          colors.orange = "#ff9e64"
          colors.yellow = "#ffe16e"
          colors.green = "#9ece6a"
          colors.green1 = "#73daca"
          colors.green2 = "#41a6b5"
          colors.teal = "#1abc9c"
          colors.red = "#ff869a"
          colors.red1 = "#db4b4b"
          colors.git = { change = "#6183bb", add = "#449dab", delete = "#914c54" }
          colors.gitSigns = { add = "#266d6a", change = "#536c9e", delete = "#b2555b" }
        end
      end,
      day_brightness = 1.,
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
    config = function() vim.cmd.colorscheme "oxocarbon" end,
  },
  { --wuelnerdotexe/vim-enfocado
    "wuelnerdotexe/vim-enfocado",
    lazy = not is_active_theme "enfocado",
    init = function() vim.g.enfocado_style = sub_theme("enfocado", "neon") end,
    priority = 1000,
    config = function() vim.cmd.colorscheme "enfocado" end,
  },
  { --NTBBloodbath/sweetie.nvim
    "NTBBloodbath/sweetie.nvim",
    lazy = not is_active_theme "sweetie",
    opts = {},
    config = config_colorscheme("sweetie", "sweetie"),
    priority = 1000,
  },
  { --Mofiqul/vscode.nvim
    "Mofiqul/vscode.nvim",
    lazy = not is_active_theme "vscode",
    opts = {},
    config = config_colorscheme("vscode", "vscode"),
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
          -- rosewater = "#F5E0DC",
          -- flamingo = "#F2CDCD",
          -- mauve = "#DDB6F2",
          -- pink = "#F5C2E7",
          -- red = "#F28FAD",
          -- maroon = "#E8A2AF",
          -- peach = "#F8BD96",
          -- yellow = "#FAE3B0",
          -- green = "#ABE9B3",
          -- blue = "#96CDFB",
          -- sky = "#89DCEB",
          -- teal = "#B5E8E0",
          -- lavender = "#C9CBFF",
          --
          -- text = "#D9E0EE",
          -- subtext1 = "#BAC2DE",
          -- subtext0 = "#A6ADC8",
          -- overlay2 = "#C3BAC6",
          -- overlay1 = "#988BA2",
          -- overlay0 = "#6E6C7E",
          -- surface2 = "#6E6C7E",
          -- surface1 = "#575268",
          -- surface0 = "#302D41",

          base = nebulous_bg,
          mantle = nebulous_bg,
          crust = nebulous_bg,
          -- base = "#1E1E2E",
          -- mantle = "#1A1826",
          -- crust = "#161320",
        },
      },
      highlight_overrides = {
        -- mocha = function(cp)
        --   return {
        --     -- For base configs.
        --     NormalFloat = { fg = cp.text, bg = transparent_background and cp.none or cp.base },
        --     CursorLineNr = { fg = cp.green },
        --     Search = { bg = cp.surface1, fg = cp.pink, style = { "bold" } },
        --     IncSearch = { bg = cp.pink, fg = cp.surface1 },
        --     Keyword = { fg = cp.pink },
        --     Type = { fg = cp.blue },
        --     Typedef = { fg = cp.yellow },
        --     StorageClass = { fg = cp.red, style = { "italic" } },
        --     -- For native lsp configs.
        --     DiagnosticVirtualTextError = { bg = cp.none },
        --     DiagnosticVirtualTextWarn = { bg = cp.none },
        --     DiagnosticVirtualTextInfo = { bg = cp.none },
        --     DiagnosticVirtualTextHint = { fg = cp.rosewater, bg = cp.none },
        --     DiagnosticHint = { fg = cp.rosewater },
        --     LspDiagnosticsDefaultHint = { fg = cp.rosewater },
        --     LspDiagnosticsHint = { fg = cp.rosewater },
        --     LspDiagnosticsVirtualTextHint = { fg = cp.rosewater },
        --     LspDiagnosticsUnderlineHint = { sp = cp.rosewater },
        --     -- For fidget.
        --     FidgetTask = { bg = cp.none, fg = cp.surface2 },
        --     FidgetTitle = { fg = cp.blue, style = { "bold" } },
        --     -- For trouble.nvim
        --     TroubleNormal = { bg = cp.base },
        --     -- For treesitter.
        --     ["@field"] = { fg = cp.rosewater },
        --     ["@property"] = { fg = cp.yellow },
        --     ["@include"] = { fg = cp.teal },
        --     -- ["@operator"] = { fg = cp.sky },
        --     ["@keyword.operator"] = { fg = cp.sky },
        --     ["@punctuation.special"] = { fg = cp.maroon },
        --     -- ["@float"] = { fg = cp.peach },
        --     -- ["@number"] = { fg = cp.peach },
        --     -- ["@boolean"] = { fg = cp.peach },
        --
        --     ["@constructor"] = { fg = cp.lavender },
        --     -- ["@constant"] = { fg = cp.peach },
        --     -- ["@conditional"] = { fg = cp.mauve },
        --     -- ["@repeat"] = { fg = cp.mauve },
        --     ["@exception"] = { fg = cp.peach },
        --     ["@constant.builtin"] = { fg = cp.lavender },
        --     -- ["@function.builtin"] = { fg = cp.peach, style = { "italic" } },
        --     -- ["@type.builtin"] = { fg = cp.yellow, style = { "italic" } },
        --     ["@type.qualifier"] = { link = "@keyword" },
        --     ["@variable.builtin"] = { fg = cp.red, style = { "italic" } },
        --     -- ["@function"] = { fg = cp.blue },
        --     ["@function.macro"] = { fg = cp.red, style = {} },
        --     ["@parameter"] = { fg = cp.rosewater },
        --     ["@keyword"] = { fg = cp.red, style = { "italic" } },
        --     ["@keyword.function"] = { fg = cp.maroon },
        --     ["@keyword.return"] = { fg = cp.pink, style = {} },
        --     -- ["@text.note"] = { fg = cp.base, bg = cp.blue },
        --     -- ["@text.warning"] = { fg = cp.base, bg = cp.yellow },
        --     -- ["@text.danger"] = { fg = cp.base, bg = cp.red },
        --     -- ["@constant.macro"] = { fg = cp.mauve },
        --
        --     -- ["@label"] = { fg = cp.blue },
        --     ["@method"] = { fg = cp.blue, style = { "italic" } },
        --     ["@namespace"] = { fg = cp.rosewater, style = {} },
        --     ["@punctuation.delimiter"] = { fg = cp.teal },
        --     ["@punctuation.bracket"] = { fg = cp.overlay2 },
        --     -- ["@string"] = { fg = cp.green },
        --     -- ["@string.regex"] = { fg = cp.peach },
        --     ["@type"] = { fg = cp.yellow },
        --     ["@variable"] = { fg = cp.text },
        --     ["@tag.attribute"] = { fg = cp.mauve, style = { "italic" } },
        --     ["@tag"] = { fg = cp.peach },
        --     ["@tag.delimiter"] = { fg = cp.maroon },
        --     ["@text"] = { fg = cp.text },
        --     -- ["@text.uri"] = { fg = cp.rosewater, style = { "italic", "underline" } },
        --     -- ["@text.literal"] = { fg = cp.teal, style = { "italic" } },
        --     -- ["@text.reference"] = { fg = cp.lavender, style = { "bold" } },
        --     -- ["@text.title"] = { fg = cp.blue, style = { "bold" } },
        --     -- ["@text.emphasis"] = { fg = cp.maroon, style = { "italic" } },
        --     -- ["@text.strong"] = { fg = cp.maroon, style = { "bold" } },
        --     -- ["@string.escape"] = { fg = cp.pink },
        --
        --     -- ["@property.toml"] = { fg = cp.blue },
        --     -- ["@field.yaml"] = { fg = cp.blue },
        --
        --     -- ["@label.json"] = { fg = cp.blue },
        --
        --     ["@function.builtin.bash"] = { fg = cp.red, style = { "italic" } },
        --     ["@parameter.bash"] = { fg = cp.yellow, style = { "italic" } },
        --     ["@field.lua"] = { fg = cp.lavender },
        --     ["@constructor.lua"] = { fg = cp.flamingo },
        --     ["@constant.java"] = { fg = cp.teal },
        --     ["@property.typescript"] = { fg = cp.lavender, style = { "italic" } },
        --     -- ["@constructor.typescript"] = { fg = cp.lavender },
        --
        --     -- ["@constructor.tsx"] = { fg = cp.lavender },
        --     -- ["@tag.attribute.tsx"] = { fg = cp.mauve },
        --
        --     ["@type.css"] = { fg = cp.lavender },
        --     ["@property.css"] = { fg = cp.yellow, style = { "italic" } },
        --     ["@type.builtin.c"] = { fg = cp.yellow, style = {} },
        --     ["@property.cpp"] = { fg = cp.text },
        --     ["@type.builtin.cpp"] = { fg = cp.yellow, style = {} },
        --     -- ["@symbol"] = { fg = cp.flamingo },
        --   }
        -- end,
      },
    },
    config = function(_, opts)
      local transparent_background = false -- Set background transparency here!
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme "catppuccin"
    end,
  },
  { --ray-x/starry.nvim
    "ray-x/starry.nvim",
    lazy = not is_active_theme "starry",
    priority = 1000,
    init = function()
      vim.g.starry_set_hl = true
      vim.g.starry_daylight_switch = true
      vim.g.starry_borders = true
      vim.g.starry_style = sub_theme("starry", "moonlight")
    end,
    config = function() vim.cmd.colorscheme "starry" end,
  },
  {
    "rafamadriz/neon",
    lazy = not is_active_theme "neon",
    priority = 1000,
    init = function() vim.g.neon_style = sub_theme("neon", "dark") end,
    config = function() vim.cmd.colorscheme "neon" end,
  },
  {
    "tiagovla/tokyodark.nvim",
    lazy = not is_active_theme "tokyodark",
    priority = 1000,
    init = function() end,
    config = function() vim.cmd.colorscheme "tokyodark" end,
  },
  {
    "Mofiqul/dracula.nvim",
    lazy = not is_active_theme "dracula",
    priority = 1000,
    opts = { colors = { bg = nebulous_bg } },
    config = config_colorscheme("dracula", "dracula"),
  },
  {

    "mcchrish/zenbones.nvim",
    init = function()
      vim.g.bones_compat = 1
      vim.g[sub_theme("zenbones", "zenwritten")] = {
        lightness = "bright",
        darkness = "stark",
      }
    end,
    lazy = not is_active_theme "zenbones",
    priority = 1000,
    config = function() vim.cmd.colorscheme(sub_theme("zenbones", "zenwritten")) end,
  },
  -- TODO: https://github.com/AstroNvim/astrotheme
}
