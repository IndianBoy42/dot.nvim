return {
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = {},
  --   ---@param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     local cmp = require "cmp"
  --     opts.sources = cmp.config.sources(vim.list_extend(opts.sources, {
  --       { name = "jupyter" },
  --     }))
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
    cmd = "JupyterAttach",
    build = ":UpdateRemotePlugins",
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {},
    },
  },
}
