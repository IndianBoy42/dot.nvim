return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "folke/neodev.nvim", opts = {} },
    },
    opts = {
      servers = {
        lua_ls = {
          -- mason = false, -- set to false if you don't want this server to be installed with mason
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
          on_attach = function(client, bufnr)
            local map = vim.keymap.setl
            map("n", "<localleader>X", "<Plug>(Luadev-RunLine)") --	Execute the current line
            map("n", "<localleader>x", "<Plug>(Luadev-Run)") --	Operator to execute lua code over a movement or text object.
            map("n", "<localleader>rw", "<Plug>(Luadev-RunWord)") --	Eval identifier under cursor, including table.attr
            -- map("n", "<localleader>x", "<Plug>(Luadev-Complete)") --
          end,
        },
      },
    },
  },
  {
    "bfredl/nvim-luadev",
    opts = {},
    cmd = "Luadev",
  },
}
