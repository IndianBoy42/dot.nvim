return {
  -- require "langs.lspconfig",
  -- require "langs.complete",
  -- { import = "langs.copilot" },
  -- require "langs.null_ls",
  -- require "langs.refactoring",
  -- https://github.com/lukas-reineke/lsp-format.nvim
  -- Languages
  { "kmonad/kmonad-vim", ft = "kmonad" },
  { "gennaro-tedesco/nvim-jqx", ft = "json" },
  {
    "Kasama/nvim-custom-diagnostic-highlight",
    opts = {},
  },
  {
    "LhKipp/nvim-nu",
    build = ":TSInstall nu",
    opts = {},
    config = function(_, opts)
      require("nu").setup(opts)
    end,
  },

  -- EXTRAS
  inlay_hint_opts = {
    auto = true,
    -- Only show inlay hints for the current line
    only_current_line = false,
    -- Event which triggers a refersh of the inlay hints.
    -- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
    -- not that this may cause  higher CPU usage.
    -- This option is only respected when only_current_line and
    -- autoSetHints both are true.
    -- only_current_line_autocmd = "CursorHold",

    show_parameter_hints = true,
    parameter_hints_prefix = "« ",
    -- default: "<-"
    -- parameter_hints_prefix = "❰❰ ",
    other_hints_prefix = "∈ ",
    -- default: "=>"
    -- other_hints_prefix = ":: ",
  },
  mason_ensure_installed = function(app)
    return {
      "williamboman/mason.nvim",
      opts = function(_, opts)
        vim.list_extend(opts.ensure_installed, app)
      end,
    }
  end,
}
