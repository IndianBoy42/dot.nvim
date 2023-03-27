return {
  {
    "IndianBoy42/kitty.lua",
    dev = true,
    init = function()
      vim.api.nvim_create_user_command("Kitty", function(args)
        if args.fargs and #args.fargs > 0 then
          require("kitty").new_tab({}, args.fargs)
        else
          require("kitty").open()
        end
      end, {
        nargs = "*",
        -- preview = function(opts, ns, buf)
        --   -- TODO: livestream to kitty
        -- end,
      })
      vim.api.nvim_create_user_command("KittyOverlay", function(args)
        local cmd = args.fargs
        if not cmd or #cmd == 0 then
          cmd = {} -- TODO: something
        end
        require("kitty.current_win").new_overlay({}, cmd)
      end, { nargs = "*" })
    end,
    config = function()
      local K = require("kitty").setup {
        -- from_current_win = "tab",
        target_providers = {
          function(T) T.helloworld = { desc = "Hello world", cmd = "echo hello world" } end,
          "just",
          "cargo",
        },
      }
      require("kitty.current_win").setup {}
      K.setup_make()

      require("rust-tools").config.options.tools.executor = K.rust_tools_executor()

      local p = utils.partial
      vim.keymap.set("n", "<leader>tk", p(K.run), { desc = "Kitty Run" })
      vim.keymap.set("n", "<leader>tt", p(K.make), { desc = "Kitty Make" })
      vim.keymap.set("n", "<leader>t<CR>", p(K.make, "last"), { desc = "Kitty ReMake" })
      -- vim.keymap.set("n", "<leader>tK", KT.run, { desc = "Kitty Run" })
      -- vim.keymap.set("n", "", require("kitty").send_cell, { buffer = 0 })
    end,
    -- cmd = { "Kitty", "KittyOverlay" },
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
    },
  },
  -- https://github.com/Olical/conjure
  {
    "michaelb/sniprun",
    build = "bash ./install.sh 1",
    opts = {
      selected_interpreters = { "Python3_fifo" },
      repl_enable = { "Python3_fifo" },

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
      { "<leader>tQ", "<Plug>SnipReset", desc = "SnipRun Reset" },
      { "<leader>tq", "<Plug>SnipReplMemoryClean", desc = "SnipRun Clean" },
      { "<leader>ti", "<Plug>SnipInfo", desc = "SnipRun Info" },
      { "<leader>tl", "<Plug>SnipLive", desc = "SnipRun Live" },
      { "<leader>tc", "<Plug>SnipClose", desc = "SnipRun Close" },
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
  {
    "goerz/jupytext.vim",
    build = "pipx install jupytext",
    event = { "BufRead *.ipynb" },
    init = function()
      vim.g.jupytext_fmt = "md:markdown"
      vim.g.jupytext_fmt = "py:percent"
    end,
  },
  -- {
  --   "untitled-ai/jupyter_ascending.vim",
  --   build = "pipx install jupyter_ascending",
  --   init = function()
  --     vim.g.jupyter_ascending_default_mappings = false
  --   end,
  -- },
  -- use {
  --   "pianocomposer321/yabs.nvim",
  --   config = function()
  --     require("lv-yabs").config()
  --   end,
  --   module = { "yabs", "telescope._extensions.yabs" },

  -- }
  -- https://github.com/lpoto/telescope-tasks.nvim
}
