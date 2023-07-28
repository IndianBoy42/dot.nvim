return {
  {
    "IndianBoy42/kitty.lua",
    dev = true,
    lazy = false,
    config = function()
      require("kitty.terms").setup {
        dont_attach = not not vim.g.kitty_scrollback,
        attach = {
          target_providers = {
            function(T) T.helloworld = { desc = "Hello world", cmd = "echo hello world" } end,
            "just",
            "cargo",
          },
          current_win_setup = {},
          on_attach = function(_, K, _)
            K.setup_make()

            -- TODO:
            -- require("rust-tools").config.options.tools.executor = K.rust_tools_executor()
          end,
          bracketed_paste = true,
        },
      }
      local Terms = require "kitty.terms"
      local map = vim.keymap.set
      map("n", "<leader>mk", function() Terms.get_terminal(0):run() end, { desc = "Kitty Run" })
      map("n", "mk", function() Terms.get_terminal(0):make() end, { desc = "Kitty Make" })
      map("n", "mr", function() Terms.get_terminal(0):make "last" end, { desc = "Kitty ReMake" })
      map("n", "dx", function() Terms.get_terminal(0):send { selection = true } end, { desc = "Kitty Send" })
      map("x", "X", function() Terms.get_terminal(0):send { selection = true } end, { desc = "Kitty Send" })
      map("n", "dxx", function() Terms.get_terminal(0):send() end, { desc = "Kitty Send Line" })
      map("n", "yc", function() Terms.get_terminal(0):get_selection() end, { desc = "Yank From Kitty" })
    end,
    keys = {
      {
        "<leader>ok",
        "<cmd>Kitty<cr>",
        desc = "Kitty Open",
      },
      {
        "<leader>oK",
        "<cmd>KittyOverlay<cr>",
        desc = "Kitty Open",
      },
      { "<leader>K", ":=require'kitty.current_win'", desc = "Kitty Control" },
    },
  },
  -- TODO: https://github.com/Olical/conjure
  {
    "michaelb/sniprun",
    build = "bash ./install.sh 1",
    opts = {
      -- selected_interpreters = { "Python3_fifo" },
      -- repl_enable = { "Python3_fifo" },

      display = { "Terminal", "VirtualTextOk", "LongTempFloatingWindowErr", "NvimNotifyErr" },
      live_mode_toggle = "enable",
    },
    config = function(_, opts)
      require("sniprun").setup(opts)
      -- TODO: patch to use Kitty.lua
      -- local sd = require "sniprun.display"
      -- sd.term_close = function() end
      -- sd.term_open = function() end
      -- sd.write_to_term = function(message, ok) end
    end,
    cmd = "SnipRun",
    keys = {
      { "<leader>xx", "<Plug>SnipRun", desc = "SnipRun Line" },
      { "<leader>x", "<Plug>SnipRunOperator", desc = "SnipRun" },
      { "<leader>x", "<Plug>SnipRun", desc = "SnipRun", mode = "x" },
      { "<leader>xQ", "<Plug>SnipReset", desc = "SnipRun Reset" },
      { "<leader>xX", "<Plug>SnipReplMemoryClean", desc = "SnipRun Clean" },
      { "<leader>xI", "<Plug>SnipInfo", desc = "SnipRun Info" },
      { "<leader>xL", "<Plug>SnipLive", desc = "SnipRun Live" },
      { "<leader>xq", "<Plug>SnipClose", desc = "SnipRun Close" },
    },
  },
  -- TODO: https://github.com/Dax89/automaton.nvim
  -- use { -- TODO: configure vs-tasks
  --   "EthanJWright/vs-tasks.nvim",
  -- }
  -- TODO: https://github.com/stevearc/overseer.nvim

  -- use {
  --   "jubnzv/mdeval.nvim",
  --   config = function()
  --     require("lv-terms").mdeval()
  --   end,
  -- }
  -- TODO: https://github.com/lpoto/telescope-tasks.nvim
  {
    "t-troebst/perfanno.nvim",
    opts = {},
  },
  {
    "andrewferrier/debugprint.nvim",
    opts = { create_keymaps = false },
    -- TODO: use a hydra?
    keys = {
      { "dpp", utils.lazy_require("debugprint").debugprint, desc = "DbgPrnt Line", expr = true },
      {
        "dPP",
        utils.partial(utils.lazy_require("debugprint").debugprint, { above = true }),
        desc = "DbgPrnt Line abv",
        expr = true,
      },
      {
        "dpv",
        utils.partial(utils.lazy_require("debugprint").debugprint, { variable = true }),
        desc = "DbgPrnt Var",
        expr = true,
      },
      {
        "dPV",
        utils.partial(utils.lazy_require("debugprint").debugprint, { variable = true, above = true }),
        desc = "DbgPrnt Var abv",
        expr = true,
      },
      {
        "<leader>dp",
        utils.partial(utils.lazy_require("debugprint").debugprint, { variable = true }),
        desc = "DbgPrnt Var",
        mode = "x",
        expr = true,
      },
      {
        "<leader>dP",
        utils.partial(utils.lazy_require("debugprint").debugprint, { variable = true, above = true }),
        desc = "DbgPrnt Var abv",
        mode = "x",
        expr = true,
      },
    },
  },
}
