-- TODO: formatter.nvim and nvim-lint
return {
  "nvimtools/none-ls.nvim",
  event = "LazyFile",
  dependencies = {
    {
      "williamboman/mason.nvim",
      opts = {
        -- TODO: split these to lang files
        ensure_installed = {
          "black",
          -- "cmake_format",
          "isort",
          "prettierd",
          "shfmt",
          -- "stylua", -- DONT install this because we want `cargo install stylua --features lua52`
          "markdownlint",
          "yamllint",
          "mdformat",
        },
      },
    },
    {
      "jay-babu/mason-null-ls.nvim",
      opts = {
        ensure_installed = nil,
        automatic_installation = true,
        automatic_setup = false,
      },
    },
  },
  opts = function()
    local null = require "null-ls"
    local diagnostics_format = "[#{c}] #{m} (#{s})"

    local formatters = null.builtins.formatting
    local diagnostics = null.builtins.diagnostics
    local code_actions = null.builtins.code_actions
    local hover = null.builtins.hover
    local compl = null.builtins.completion

    -- TODO: move this to individual files
    return {
      debug = true,
      diagnostics_format = diagnostics_format,
      -- TODO: split these to lang files
      sources = {
        -- Formatters
        formatters.stylua,
        formatters.prettierd,
        -- formatters.rustfmt,
        formatters.shfmt,
        formatters.black, -- yapf, autopep8
        -- formatters.isort,
        -- formatters.clang_format,
        -- formatters.uncrustify,
        formatters.cmake_format,
        formatters.elm_format,
        formatters.fish_indent,
        formatters.fnlfmt,
        -- formatters.json_tool,
        formatters.nixfmt,
        formatters.mdformat,
        formatters.markdownlint,
        formatters.gersemi,

        -- -- Diagnostics
        -- -- diagnostics.chktex, -- vimtex?
        -- diagnostics.selene, -- lua linter
        -- diagnostics.luacheck, -- lua linter
        -- diagnostics.eslint,
        -- diagnostics.hadolint,
        -- diagnostics.cppcheck,
        -- diagnostics.flake8,
        -- diagnostics.pylint,
        -- diagnostics.hadolint,
        -- -- diagnostics.luacheck,
        -- diagnostics.write_good,
        -- diagnostics.proselint,
        -- diagnostics.vale, -- lets install vale-linter
        -- -- diagnostics.misspell,
        diagnostics.markdownlint,
        diagnostics.yamllint,
        diagnostics.gccdiag.with {
          args = {
            "-i",
            "-fdiagnostics-color -O3 -O2",
            "-a",
            "-S",
            "--",
            "$FILENAME",
          },
        },

        -- Code Actions
        -- code_actions.gitsigns, -- TODO: reenable when I can lower the priority
        -- code_actions.proselint,
        code_actions.refactoring,
        code_actions.statix,

        -- compl.spell,

        -- Hover Info
        hover.dictionary.with {
          filetypes = { "txt", "markdown", "tex" },
        },
      },
    }
  end,
}
