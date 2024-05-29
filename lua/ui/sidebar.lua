return {
  {
    "folke/trouble.nvim",
    branch = "dev",
    cmd = "Trouble",
    keys = {

      { "<leader>osD", "<cmd>Trouble diagnostics open<cr>", desc = "Diagnostics workspace" },
      { "<leader>osd", "<cmd>Trouble diagnostics_buffer open<cr>", desc = "Diagnostics" },
      { "<leader>osr", "<cmd>Trouble lsp_references open<cr>", desc = "References" },
      { "<leader>osi", "<cmd>Trouble lsp_implementations open<cr>", desc = "Implementations" },
      { "<leader>osq", "<cmd>Trouble qflist open<cr>", desc = "Quick Fix" },
      { "<leader>osL", "<cmd>Trouble loclist open<cr>", desc = "Loc List" },
      { "<leader>osl", "<cmd>Trouble lsp open<cr>", desc = "All LSP" },
      { "<leader>oss", "<cmd>Trouble symbols<cr>", desc = "LSP Symbols" },
    },
    opts = {
      -- Defaults are opposite
      focus = true, -- Focus the window when opened
      pinned = true, -- When pinned, the opened trouble window will be bound to the current buffer
      win = { position = "right", size = { width = 80 } },
      keys = { -- key mappings for actions in the trouble list
        ["<Down>"] = "next",
        ["<Up>"] = "prev",
        h = "fold_close_recursive",
        l = "fold_open_recursive",
        a = "jump",
      },
      modes = {
        diagnostics = {
          win = {
            size = { width = 80 },
          },
        },
        diagnostics_buffer = {
          mode = "diagnostics", -- inherit from diagnostics mode
          filter = { buf = 0 }, -- filter diagnostics to the current buffer
        },
        -- TODO: add custom contextual keys 
        -- TODO: rename in symbols
        -- TODO: codeaction in diagnostics
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
  -- TODO: "ldelossa/litee-calltree.nvim"
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
        hover_symbol = O.hover_key,
        rename_symbol = "R",
        code_actions = O.action_key,
        fold_reset = "zR",
        fold_all = "zm",
        unfold_all = "zr",
      },
      lsp_blacklist = {},
    },
    cmd = "SymbolsOutline",
  },
  -- TODO: quickfix helpers
  -- https://github.com/kevinhwang91/nvim-bqf
}
