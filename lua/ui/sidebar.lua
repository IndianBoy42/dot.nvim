return {
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
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      position = "right",
      auto_preview = true,
      auto_fold = true,
      action_keys = { -- key mappings for actions in the trouble list
        -- map to {} to remove a mapping, for example:
        -- close = {},
        close = "q", -- close the list
        cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r", -- manually refresh
        jump = { "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
        open_split = { "<c-x>" }, -- open buffer in new split
        open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
        open_tab = { "<c-t>" }, -- open buffer in new tab
        jump_close = { "o" }, -- jump to the diagnostic and close the list
        toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
        toggle_preview = "P", -- toggle auto_preview
        hover = "H", -- opens a small popup with the full multiline message
        preview = "p", -- preview the diagnostic location
        close_folds = { "zm", "h" }, -- close all folds
        open_folds = { "zr", "l" }, -- open all folds
        toggle_fold = { "zZ", "zz" }, -- toggle fold of current file
        previous = "k", -- previous item
        next = "j", -- next item
      },
    },
    config = function(_, opts)
      local trouble = require "trouble"
      trouble.setup(opts)
      local t = {
        function() trouble.next { skip_groups = true, jump = true } end,
        function() trouble.previous { skip_groups = true, jump = true } end,
      }
      mappings.repeatable("t", "Trouble", t, {})
      -- t = make_nN_pair(t)
      -- vim.keymap.set("n", O.goto_next .. "t", t[1], { desc = "Next Trouble" })
      -- vim.keymap.set("n", O.goto_next .. "t", t[2], { desc = "Prev Trouble" })
    end,
  },
  -- "ldelossa/litee-calltree.nvim"
  { --
    "simrat39/symbols-outline.nvim",
    opts = {
      highlight_hovered_item = true,
      show_guides = true,
      auto_preview = true,
      position = "right",
      keymaps = {
        close = "<C-q>",
        toggle_preview = "P",
        focus_location = "o",
        hover_symbol = "H",
        rename_symbol = "R",
        code_actions = "K",
        fold_reset = "zR",
        fold_all = "zm",
        unfold_all = "zr",
      },
      lsp_blacklist = {},
    },
    cmd = "SymbolsOutline",
  },
}
