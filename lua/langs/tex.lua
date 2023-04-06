local function au_unconceal(level)
  vim.opt_local.conceallevel = level
  utils.define_augroups {
    _lightspeed_unconceal = {
      { "User", "LightspeedEnter", "setlocal conceallevel=0" },
      { "User", "LightspeedExit", "setlocal conceallevel=" .. level },
    },
  }
end
local surroundings = function(ms)
  local ui = ms.user_input
  return {
    -- ["?"] = {
    --   input = function()
    --     local env = ui "environment"
    --     if env == nil or env == "" then
    --       return
    --     end
    --     return { "\\begin{" .. vim.pesc(env) .. "%*?}().-()\\end{" .. vim.pesc(env) .. "%*?}" }
    --   end,
    --   output = function()
    --     local env = ui "Left surrounding"
    --     if env == nil then
    --       return
    --     end
    --     return { left = env, right = env }
    --   end,
    -- },
    ["e"] = {
      input = function()
        -- local env = ui "environment"
        -- if env == nil or env == "" then
        --   return
        -- end
        -- return { "\\begin{" .. vim.pesc(env) .. "%*?}().-()\\end{" .. vim.pesc(env) .. "%*?}" }
        return { "\\begin{.+}().-()\\end{.*}" }
      end,
      output = function()
        local env = ui "environment"
        if env == nil then return end
        return { left = env, right = env }
      end,
    },
    p = {
      input = function() return { "\\left().-()\\right" } end,
      output = function() return { left = nil, right = nil } end,
    },
    ["$"] = {
      input = function() return { "\\%(().-()\\%)" } end,
      output = function() return { left = "(", right = ")" } end,
    },
  }
end
local sandwich_recipes = {
  { __filetype__ = "tex", buns = { "“", "”" }, nesting = 1, input = { 'u"' } },
  { __filetype__ = "tex", buns = { "„", "“" }, nesting = 1, input = { 'U"', "ug", "u," } },
  { __filetype__ = "tex", buns = { "«", "»" }, nesting = 1, input = { "u<", "uf" } },
  { __filetype__ = "tex", buns = { "`", "'" }, nesting = 1, input = { "l'", "l`" } },
  { __filetype__ = "tex", buns = { "``", "''" }, nesting = 1, input = { 'l"' } },
  { __filetype__ = "tex", buns = { '"`', "\\\"'" }, nesting = 1, input = { 'L"' } },
  { __filetype__ = "tex", buns = { ",,", "``" }, nesting = 1, input = { "l," } },
  { __filetype__ = "tex", buns = { "<<", ">>" }, nesting = 1, input = { "l<" } },
  { __filetype__ = "tex", buns = { "&", "\\\\" }, nesting = 1, input = { "&" } },
  { __filetype__ = "tex", buns = { "$", "$" }, nesting = 0 },
  {
    __filetype__ = "tex",
    buns = { "\\(", "\\)" },
    nesting = 1,
    input = { "\\(" },
    ["indentkeys-"] = "{,},0{,0}",
  },
  {
    __filetype__ = "tex",
    buns = { "\\(", "\\)" },
    nesting = 1,
    input = { "$" },
    ["indentkeys-"] = "{,},0{,0}",
  },
  {
    __filetype__ = "tex",
    buns = { "\\{", "\\}" },
    nesting = 1,
    input = { "\\{" },
    ["indentkeys-"] = "{,},0{,0}",
  },
  {
    __filetype__ = "tex",
    buns = { "\\{", "\\}" },
    nesting = 1,
    input = { "$$" },
    ["indentkeys-"] = "{,},0{,0}",
  },
  {
    __filetype__ = "tex",
    buns = { "\\|", "\\|" },
    nesting = 1,
    input = { "\\|" },
    ["indentkeys-"] = "{,},0{,0}",
  },
  {
    __filetype__ = "tex",
    buns = { "\\[", "\\]" },
    nesting = 1,
    input = { "\\[" },
    ["indentkeys-"] = "{,},0{,0}",
  },
  {
    __filetype__ = "tex",
    buns = { "\\left( ", " \\right)" },
    nesting = 1,
    input = { "m(" },
    action = { "add" },
    ["indentkeys-"] = "(,)",
  },
  {
    __filetype__ = "tex",
    buns = { "\\left[ ", " \\right]" },
    nesting = 1,
    input = { "m[" },
    action = { "add" },
    ["indentkeys-"] = "[,]",
  },
  {
    __filetype__ = "tex",
    buns = { "\\left| ", " \\right|" },
    nesting = 1,
    input = { "m|" },
    action = { "add" },
  },
  {
    __filetype__ = "tex",
    buns = { "\\left\\{ ", " \\right\\}" },
    nesting = 1,
    input = { "m{" },
    action = { "add" },
    ["indentkeys-"] = "{,},0{,0}",
  },
  {
    __filetype__ = "tex",
    buns = { "\\left\\langle ", "\\right\\rangle " },
    nesting = 1,
    input = { "m<" },
    action = { "add" },
  },
  {
    __filetype__ = "tex",
    buns = { "\\bigl(", "\\bigr)" },
    nesting = 1,
    input = { "M(" },
    action = { "add" },
    ["indentkeys-"] = "(,)",
  },
  {
    __filetype__ = "tex",
    buns = { "\\bigl[", "\\bigr]" },
    nesting = 1,
    input = { "M[" },
    action = { "add" },
    ["indentkeys-"] = "[,]",
  },
  {
    __filetype__ = "tex",
    buns = { "\\bigl|", "\\bigr|" },
    nesting = 1,
    input = { "M|" },
    action = { "add" },
  },
  {
    __filetype__ = "tex",
    buns = { "\\bigl\\{", "\\bigr\\}" },
    nesting = 1,
    input = { "M{" },
    action = { "add" },
    ["indentkeys-"] = "{,},0{,0}",
  },
  {
    __filetype__ = "tex",
    buns = { "\\bigl\\langle ", "\\bigr\\rangle " },
    nesting = 1,
    input = { "M<" },
    action = { "add" },
  },
  {
    __filetype__ = "tex",
    buns = { "\\textbf{", "}" },
    nesting = 1,
    input = { "bf" },
    action = { "add" },
  },
  {
    __filetype__ = "tex",
    buns = { "\\frac{", "}{}" },
    nesting = 1,
    input = { "fr" },
    action = { "add" },
  },
  {
    __filetype__ = "tex",
    buns = { "\\textit{", "}" },
    nesting = 1,
    input = { "it" },
    action = { "add" },
  },
  {
    __filetype__ = "tex",
    buns = { "\\text{", "}" },
    nesting = 1,
    input = { "tt" },
    action = { "add" },
  },
  {
    __filetype__ = "tex",
    buns = { "\\bm{", "}" },
    nesting = 1,
    input = { "bm" },
    action = { "add" },
  },
  {
    __filetype__ = "tex",
    buns = { "\\mathbb{", "}" },
    nesting = 1,
    input = { "bb" },
    action = { "add" },
  },
  {
    __filetype__ = "tex",
    buns = { "\\sqrt{", "}" },
    nesting = 1,
    input = { "rt" },
    action = { "add" },
  },
  {
    __filetype__ = "tex",
    buns = { "\\mathcal{", "}" },
    nesting = 1,
    input = { "cal" },
    action = { "add" },
  },
  {
    __filetype__ = "tex",
    buns = { "\\begingroup", "\\endgroup" },
    nesting = 1,
    input = { "gr", "\\gr" },
    linewise = 1,
  },
  {
    __filetype__ = "tex",
    buns = { "\\toprule", "\\bottomrule" },
    nesting = 1,
    input = { "tr", "\\tr", "br", "\\br" },
    linewise = 1,
  },
  {
    __filetype__ = "tex",
    buns = "sandwich#filetype#tex#CmdInput()",
    kind = { "add", "replace" },
    action = { "add" },
    listexpr = 1,
    nesting = 1,
    input = { "c" },
    ["indentkeys-"] = "{,},0{,0}",
  },
  {
    __filetype__ = "tex",
    buns = "sandwich#filetype#tex#EnvInput()",
    kind = { "add", "replace" },
    action = { "add" },
    listexpr = 1,
    nesting = 1,
    linewise = 1,
    input = { "e" },
    ["indentkeys-"] = "{,},0{,0}",
    autoindent = 0,
  },
  {
    __filetype__ = "tex",
    buns = { "\\\\\a\\+\\*\\?{", "}" },
    kind = { "delete", "replace", "auto", "query" },
    regex = 1,
    nesting = 1,
    input = { "c" },
    ["indentkeys-"] = "{,},0{,0}",
  },
  {
    __filetype__ = "tex",
    buns = { "\\\begin{[^}]*}\\%(\\[.*\\]\\)\\?", "\\end{[^}]*}" },
    kind = { "delete", "replace", "auto", "query" },
    regex = 1,
    nesting = 1,
    linewise = 1,
    input = { "e" },
    ["indentkeys-"] = "{,},0{,0}",
    autoindent = 0,
  },
  {
    __filetype__ = "tex",
    external = {
      "\\<Plug>(textobj-sandwich-filetype-tex-marks-i)",
      "\\<Plug>(textobj-sandwich-filetype-tex-marks-a)",
    },
    kind = { "delete", "replace", "auto", "query" },
    noremap = 0,
    input = { "ma" },
    indentkeys = "{,},0{,0}",
    autoindent = 0,
  },
}
local function sandwhich_mark_recipe_fn()
  local map = vim.keymap.set
  map(
    "x",
    "<Plug>(textobj-sandwich-filetype-tex-marks-i)",
    "textobj#sandwich#auto('x', 'i', {'synchro': 0}, b:sandwich_tex_marks_recipes)",
    { silent = true, expr = true }
  )
  map(
    "x",
    "<Plug>(textobj-sandwich-filetype-tex-marks-a)",
    "textobj#sandwich#auto('x', 'a', {'synchro': 0}, b:sandwich_tex_marks_recipes)",
    { silent = true, expr = true }
  )
end

local sandwich_marks_recipes = {
  {
    buns = { "\\%([[(]\\|\\{\\)", "\\%([])]\\|\\}\\)" },
    regex = 1,
    nesting = 1,
  },
  {
    buns = { "|", "|" },
    nesting = 0,
  },
  {
    buns = { "\\m\\C\\[Bb]igg\\?l|", "\\m\\C\\[Bb]igg\\?r|" },
    regex = 1,
    nesting = 1,
  },
  {
    buns = {
      "\\m\\C\\\\%(langle\\|lVert\\|lvert\\|lceil\\|lfloor\\)",
      "\\m\\C\\\\%(rangle\\|rVert\\|rvert\\|rceil\\|rfloor\\)",
    },
    regex = 1,
    nesting = 1,
  },
  {
    buns = {
      "\\m\\C\\left\\%([[(|.]\\|\\{\\|\\langle\\|\\lVert\\|\\lvert\\|\\lceil\\|\\lfloor\\)",
      "\\m\\C\\\right\\%([])|.]\\|\\}\\|\\\rangle\\|\\\rVert\\|\\\rvert\\|\\\rceil\\|\\\rfloor\\)",
    },
    regex = 1,
    nesting = 1,
  },
  --  NOTE: It is not reasonable to set 'nesting' on when former and latter surrounds are same.
  {
    buns = { "\\m\\C\\[Bb]igg\\?|", "\\m\\C\\[Bb]igg\\?|" },
    regex = 1,
    nesting = 0,
  },
  -- NOTE: The existence of '\\big.' makes the situation tricky.
  --       Try to search those two cases independently and adopt the nearest item.
  --         \\big. foo \\big)
  --         \\big( foo \\big.
  --       This roundabout enables the following:
  --         \\big( foo \\big. bar \\big. baz \\big)
  --       When the cursor is on;
  --         foo -> \\big( and \\big.
  --         bar -> nothing
  --         foo -> \\big. and \\big)
  --       were deleted by the input 'sdma'.
  {
    buns = {
      "\\m\\C\\[Bb]igg\\?l\\?\\%([[(]\\|\\{\\|\\langle\\|\\lVert\\|\\lvert\\|\\lceil\\|\\lfloor\\)",
      "\\m\\C\\[Bb]igg\\?r\\?\\%([]).]\\|\\}\\|\\\rangle\\|\\\rVert\\|\\\rvert\\|\\\rceil\\|\\\rfloor\\)",
    },
    regex = 1,
    nesting = 1,
  },
  {
    buns = {
      "\\m\\C\\[Bb]igg\\?l\\?\\%([[(.]\\|\\{\\|\\langle\\|\\lVert\\|\\lvert\\|\\lceil\\|\\lfloor\\)",
      "\\m\\C\\[Bb]igg\\?r\\?\\%([])]\\|\\}\\|\\\rangle\\|\\\rVert\\|\\\rvert\\|\\\rceil\\|\\\rfloor\\)",
    },
    regex = 1,
    nesting = 1,
  },
  {
    buns = { "\\m\\C\\[Bb]igg\\?|", "\\m\\C\\[Bb]igg\\?." },
    regex = 1,
    nesting = 0,
  },
  {
    buns = { "\\m\\C\\[Bb]igg\\?.", "\\m\\C\\[Bb]igg\\?|" },
    regex = 1,
    nesting = 0,
  },
  {
    buns = { "\\m\\C\\[Bb]igg\\?l|", "\\m\\C\\[Bb]igg\\?r[|.]" },
    regex = 1,
    nesting = 1,
  },
  {
    buns = { "\\m\\C\\[Bb]igg\\?l[|.]", "\\m\\C\\[Bb]igg\\?r|" },
    regex = 1,
    nesting = 1,
  },
}
local conf = {
  conceal = 2,
  -- theme = O.lighttheme,
  fontsize = O.bigfontsize,
  filetypes = { "tex", "bib" },
  texlab = {
    aux_directory = ".",
    bibtex_formatter = "texlab",
    build = {
      executable = "tectonic",
      args = {
        -- Input
        "%f",
        -- Flags
        "--synctex",
        "--keep-logs",
        "--keep-intermediates",
        -- Options
        -- OPTIONAL: If you want a custom out directory,
        -- uncomment the following line.
        --"--outdir out",
      },
      forwardSearchAfter = true,
      onSave = false,
    },
    chktex = { on_edit = true, on_open_and_save = true },
    diagnostics_delay = vim.opt.updatetime,
    formatter_line_length = 80,
    forward_search = { args = {}, executable = "" },
    latexFormatter = "latexindent",
    latexindent = { modify_line_breaks = false },
  },
}

return {
  {
    "lervag/vimtex",
    ft = "tex",
    init = function()
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_view_automatic = 1
      vim.g.vimtex_quickfix_mode = 0
      vim.g.tex_conceal = "abdmgs"
      vim.g.vimtex_subfile_start_local = 1

      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_generic = { cmd = "watchexec -e tex -- tectonic --synctex --keep-logs *.tex" }
      vim.g.vimtex_compiler_tectonic = {
        ["options"] = { "--synctex", "--keep-logs" },
      }
      vim.g.vimtex_compiler_latexmk = {
        ["options"] = {
          "-shell-escape",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-pdflatex",
          "-interaction=nonstopmode",
        },
      }
    end,
  },

  require("langs").mason_ensure_installed { "texlab", "latexindent" },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        texlab = {
          filetypes = conf.filetypes,
          settings = {
            texlab = conf.texlab,
          },
          on_attach = function(client, bufnr) client.server_capabilities.semanticTokensProvider = nil end,
        },
      },
    },
  },
  on_open_file = function()
    vim.b.vimtex_main = "main.tex"
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt.number = false
    vim.opt.relativenumber = false
    vim.opt.iskeyword:append "\\"

    local map = vim.keymap.setl
    require("keymappings").wrapjk()
    -- TODO: this sucks ass
    map("v", "<C-b>", "Smb", { remap = true, silent = true })
    map("v", "<C-t>", "Smi", { remap = true, silent = true })
    map("n", "<C-b>", "ysiwbm", { remap = true, silent = true })
    map("n", "<C-t>", "ysiwmi", { remap = true, silent = true })
    map("i", "<C-b>", "<cmd>normal ysiwmb<cr>", { silent = true })
    map("i", "<C-t>", "<cmd>normal ysiwmi<cr>", { silent = true })

    au_unconceal(conf.conceal)
    -- vim.opt_local.background = "light"
    if conf.theme then
      vim.cmd(conf.theme)
      -- utils.define_augroups {
      --   _switching_themes = {
      --     { "BufWinEnter", "<buffer>", latexconf.background },
      --     { "BufLeave", "<buffer>", " lua require'theme'()" },
      --   },
      -- }
    end
    if conf.fontsize then utils.set_guifont(conf.fontsize) end

    -- TODO: cursorhold autoformat (but longer time)

    -- TODO: mini.surround
    -- require("plugins.pairs.sandwich").add_local_recipes(sandwich_recipes)
    -- vim.b.sandwich_tex_marks_recipes = vim.fn.deepcopy(sandwich_marks_recipes) -- TODO: idk what this does
    -- sandwhich_mark_recipe_fn()
    vim.b.minisurround_config = {
      custom_surroundings = surroundings(require "mini.surround"),
    }
    -- vim.b.miniai_config = {
    --   custom_textobjects
    -- }
    vim.keymap.set("n", "<leader>lr", "<F8>", { remap = true, desc = "Add \\left\\right" })
    -- vim.keymap.set("n", "<leader>es", "<F8>", { remap = true, desc = "Toggle \\left\\right" })

    -- Localleader
    local cmd = utils.cmd
    mappings.localleader {
      f = { cmd "call vimtex#fzf#run()", "Fzf Find" },
      i = { cmd "VimtexInfo", "Project Information" },
      s = { cmd "VimtexStop", "Stop Project Compilation" },
      t = { cmd "VimtexTocToggle", "Toggle Table Of Content" },
      v = { cmd "VimtexView", "View PDF" },
      c = { utils.conceal_toggle, "Toggle Conceal" },
      b = { cmd "VimtexCompile", "Compile" },
      o = { cmd "VimtexCompileOutput", "Compile Output" },
      e = { cmd "VimtexErrors", "Errors" },
      l = { cmd "TexlabBuild", "Texlab Build" },
      n = { function() require("nabla").popup() end, "Nabla" },
      m = { cmd "VimtexToggleMain", "Toggle Main File" },
      a = { cmd "AirLatex", "Air Latex" },
    }
    mappings.ftleader {
      ot = { cmd "VimtexTocToggle", "Table of Contents" },
      ol = { cmd "VimtexLabelsToggle", "Latex Labels" },
    }

    -- utils.define_augroups { _vimtex_event = {
    --   { "InsertLeave", "*.tex", "VimtexCompile" },
    -- } }

    vim.b.knap_settings = {
      textopdfviewerlaunch = "zathura"
        .. "--synctex-editor-command"
        .. "'nvim --headless -es --cmd \"lua require('\"'\"'knaphelper'\"'\"').relayjump('\"'\"'%servername%'\"'\"','\"'\"'%{input}'\"'\"',%{line},0)\"'"
        .. "outputfile%",
      textopdfviewerrefresh = "none",
      textopdfforwardjump = "zathura --synctex-forward=%line%:%column%:%srcfile% %outputfile%",
    }
  end,
}
