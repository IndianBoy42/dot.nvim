return {
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = {},
  --   ---@param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     opts.sources = vim.list_extend(opts.sources, {
  --       { name = "jupyter", group_index = 2 },
  --     })
  --   end,
  -- },
  {
    "lkhphuc/jupyter-kernel.nvim",
    init = function()
      vim.api.nvim_create_autocmd("Filetype", {
        pattern = "python",
        callback = function()
          require("langs.complete").add_sources { { name = "jupyter" } }
          vim.keymap.set("n", "gh", "<cmd>JupyterInspect<cr>", { buffer = 0 })
        end,
        group = vim.api.nvim_create_augroup("jupyter_kernel_setup", {}),
      })
    end,
    cmd = { "JupyterAttach", "JupyterInspect", "JupyterExecute" },
    build = ":UpdateRemotePlugins",
    opts = {},
  },

  require("langs").mason_ensure_installed { "python-lsp-server" },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pylsp = {},
        -- pyright = {
        --   handlers = {
        --     ["textDocument/publishDiagnostics"] = function() end,
        --   },
        --   on_attach = function(client, _) client.server_capabilities.codeActionProvider = false end,
        --   settings = {
        --     pyright = {
        --       disableOrganizeImports = true,
        --     },
        --     python = {
        --       analysis = {
        --         autoSearchPaths = true,
        --         typeCheckingMode = "basic",
        --         useLibraryCodeForTypes = true,
        --       },
        --     },
        --   },
        -- },
        -- ["ruff_lsp"] = {
        --   on_attach = function(client, _) client.server_capabilities.hoverProvider = false end,
        --   init_options = {
        --     settings = {
        --       args = {},
        --     },
        --   },
        -- },
      },
    },
  },
}
