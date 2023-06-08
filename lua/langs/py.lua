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
          local srcs = require("langs.complete").sources
          srcs(vim.list_extend(srcs(), { name = "jupyter", group_index = 2 }))
          vim.keymap.set("n", "H", "<cmd>JupyterInspect<cr>", { buffer = 0 })
          vim.keymap.set("n", "<localleader>i", "<cmd>JupyterInspect<cr>", { buffer = 0 })
          vim.keymap.set("n", "<localleader>e", "<cmd>JupyterExecute<cr>", { buffer = 0 })
          vim.keymap.set("x", "<localleader>e", ":JupyterExecute<cr>", { buffer = 0 })
          vim.keymap.set("n", "<localleader>ja", "<cmd>JupyterAttach<cr>", { buffer = 0 })
        end,
        group = vim.api.nvim_create_augroup("jupyter_kernel_setup", {}),
      })
    end,
    cmd = { "JupyterAttach", "JupyterInspect", "JupyterExecute" },
    build = ":UpdateRemotePlugins",
    opts = {},
  },
  -- {
  --   "WhiteBlackGoose/magma-nvim-goose",
  --   run = ":UpdateRemotePlugins",
  -- },
  -- {
  --   "untitled-ai/jupyter_ascending.vim",
  --   build = "pipx install jupyter_ascending",
  --   init = function()
  --     vim.g.jupyter_ascending_default_mappings = false
  --   end,
  -- },
  {
    "goerz/jupytext.vim",
    build = "pipx install jupytext",
    event = { "BufRead *.ipynb" },
    init = function()
      vim.g.jupytext_fmt = "md:markdown"
      vim.g.jupytext_fmt = "py:percent"
    end,
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
