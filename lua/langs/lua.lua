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
                callSnippet = "Both",
                keywordSnippet = "Both",
              },
              hint = {
                enable = true,
                setType = false,
                arrayIndex = "Disable",
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
  {
    "ii14/neorepl.nvim",
    opts = {},
    cmd = "Repl",
    init = function()
      vim.api.nvim_create_user_command("NeoRepl", function()
        -- get current buffer and window
        local buf = vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_get_current_win()
        -- create a new split for the repl
        vim.cmd "split"
        -- spawn repl and set the context to our buffer
        require("neorepl").new {
          buffer = buf,
          window = win,
        }
        -- resize repl window and make it fixed height
        vim.cmd "resize 10"
        vim.bo.winfixheight = true
      end, {})
    end,
    keys = {
      { "g:", "<cmd>NeoRepl<cr>", "NeoRepl" },
    },
  },
}
