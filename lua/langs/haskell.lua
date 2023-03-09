return {
  {
    "neovim/nvim-lspconfig",
    -- TODO: https://github.com/mrcjkb/haskell-tools.nvim
    dependencies = { "mrcjkb/haskell-tools.nvim" },
    opts = {
      setup = {
        hls = function(_, _opts)
          local ht = require "haskell-tools"
          local buffer = vim.api.nvim_get_current_buf()
          local def_opts = { noremap = true, silent = true }
          ht.start_or_attach {
            hls = {
              on_attach = function(client, bufnr)
                local opts = vim.tbl_extend("keep", def_opts, { buffer = bufnr })
                -- haskell-language-server relies heavily on codeLenses,
                -- so auto-refresh (see advanced configuration) is enabled by default
                vim.keymap.set("n", "<leader>ls", ht.hoogle.hoogle_signature, opts)
                vim.keymap.set("n", "<leader>xa", ht.lsp.buf_eval_all, opts)

                -- Toggle a GHCi repl for the current package
                vim.keymap.set("n", "<localleader>r", ht.repl.toggle, opts)
                -- Toggle a GHCi repl for the current buffer
                vim.keymap.set("n", "<localleader>f", function()
                  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
                end, def_opts)
                vim.keymap.set("n", "<localleader>q", ht.repl.quit, opts)
              end,
            },
          }
          return true
        end,
      },
    },
  },
  {
    "kiyoon/haskell-scope-highlighting.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    ft = "haskell",
    init = function()
      -- Consider disabling other highlighting
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "haskell",
        callback = function()
          vim.cmd.syntax "off"
          vim.cmd.TSDisable "highlight"
        end,
      })
    end,
  },
}
