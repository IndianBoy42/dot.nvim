return {
  require "plugins.langs.lspconfig",
  require "plugins.langs.complete",
  { import = "plugins.langs.copilot" },
  require "plugins.langs.null_ls",

  -- Languages
  { import = "plugins.langs.lua" },
  { import = "plugins.langs.tex" },
  { import = "plugins.langs.rust" },
  { import = "plugins.langs.markdown" },
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
