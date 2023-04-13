return {
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen" },
    keys = {
      { "<leader>os", "<cmd>AerialToggle<cr>", desc = "Aerial Outline" },
    },
    opts = {},
  },
  { --
    "simrat39/symbols-outline.nvim",
    opts = {
      highlight_hovered_item = true,
      show_guides = true,
      auto_preview = true,
      position = "right",
      keymaps = {
        close = "<Esc>",
        goto_location = "<Cr>",
        focus_location = "o",
        hover_symbol = "<localleader>h",
        rename_symbol = "<localleader>r",
        code_actions = "<localleader>a",
      },
      lsp_blacklist = {},
    },
    cmd = "SymbolsOutline",
    keys = {
      { "<leader>oS", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
    dependencies = {
      -- {
      --   "nvim-telescope/telescope.nvim",
      --   opts = function()
      --     local trouble = utils.lazy_require "trouble.providers.telescope"
      --     return {
      --       defaults = {
      --         mappings = {
      --           i = { ["<localleader>T"] = trouble.open_with_trouble },
      --           n = { ["<localleader>T"] = trouble.open_with_trouble },
      --         },
      --       },
      --     }
      --   end,
      -- },
    },
    keys = {
      { "<leader>dS", "<cmd>TroubleToggle<cr>", desc = "Trouble Sidebar" },
      { "<leader>dd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document" },
      { "<leader>dD", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace" },
      { "<leader>dr", "<cmd>TroubleToggle lsp_references<cr>", desc = "References" },
      { "<leader>ds", "<cmd>TroubleToggle lsp_definitions<cr>", desc = "Definitions" },
      { "<leader>dq", "<cmd>TroubleToggle quickfix<cr>", desc = "Quick Fixes" },
      -- { "<leader>dL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List" },
      -- { "<leader>do", "<cmd>TroubleToggle todo<cr>", desc = "TODOs" },
    },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      position = "right",
      auto_preview = false,
      hover = "h",
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd(
        { "CursorMoved", "InsertLeave", "BufEnter", "BufWinEnter", "TabEnter", "BufWritePost" },
        { command = "TroubleRefresh" }
      )

      require("trouble").setup(opts)
    end,
  },
  -- "ldelossa/litee-calltree.nvim"
  -- "stevearc/aerial.nvim/"
  { "liuchengxu/vista.vim", cmd = "Vista" },
  {
    "GustavoKatel/sidebar.nvim",
    opts = {
      open = false,
      sections = {
        "datetime",
        "git-status",
        "lsp-diagnostics",
        "todos",
      },
    },
    cmd = "SidebarNvimToggle",
  },
}
