return {
  {
    "chrisgrieser/nvim-origami", -- Fold unfold automatically using h/l
    event = "LazyFile", -- later or on keypress would prevent saving folds
    opts = true, -- needed even when using default config
  },
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = {
  --     capabilities = {
  --       textDocument = {
  --         foldingRange = {
  --           dynamicRegistration = false,
  --           lineFoldingOnly = true,
  --         },
  --       },
  --     },
  --   },
  -- },
}
