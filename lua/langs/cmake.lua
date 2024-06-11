return {
  -- require("langs").mason_ensure_installed { "neocmakelsp", "gersemi" },
  {
    "neovim/nvim-lspconfig",
    -- dependencies = { "Civitasv/cmake-tools.nvim" },
    opts = {
      servers = {
        neocmake = {},
      },
    },
  },
}
