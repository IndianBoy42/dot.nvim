return {
  require "langs.lspconfig",
  require "langs.complete",
  { import = "langs.copilot" },
  require "langs.null_ls",

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
}
