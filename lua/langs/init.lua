return {
  require "langs.lspconfig",
  require "langs.complete",
  { import = "langs.copilot" },
  require "langs.null_ls",
  require "langs.refactoring",
  -- https://github.com/lukas-reineke/lsp-format.nvim
  -- Languages
  { import = "langs.lua" },
  { import = "langs.tex" },
  { import = "langs.rust" },
  { import = "langs.markdown" },
  { "NoahTheDuke/vim-just", ft = "just" },
  {
    "IndianBoy42/tree-sitter-just",
    opts = { ["local"] = true },
  },
  { "kmonad/kmonad-vim", ft = "kmonad" },
  { "gennaro-tedesco/nvim-jqx", ft = "json" },
  {
    "Kasama/nvim-custom-diagnostic-highlight",
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
}
