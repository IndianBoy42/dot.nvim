local diagnostic_config_all = {
  _virtual_text = function(ns, bufnr)
    local highest = require("utils.lsp").get_highest_diag(ns, bufnr)
    return {
      spacing = 4,
      prefix = "",
      severity = { min = highest },
    }
  end,
  virtual_text_config = {
    spacing = 4,
    prefix = "",
    severity_limit = "Warning",
  },
  virtual_lines = true,
  signs = true,
  underline = { severity = "Error" },
  severity_sort = true,
  update_in_insert = true,
}
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
    main = "nu",
    opts = {},
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
  diagnostic_config = vim.tbl_extend("keep", {
    virtual_text = false,
    signs = false,
  }, diagnostic_config_all),
  diagnostic_config_all = diagnostic_config_all,
  codelens_config = {
    virtual_text = { spacing = 0, prefix = "" },
    signs = true,
    underline = true,
    severity_sort = true,
  },
}
