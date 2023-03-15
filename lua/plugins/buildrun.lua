return {
  {
    "IndianBoy42/kitty.lua",
    dev = true,
    config = function()
      local K = require("kitty").setup {
        -- from_current_win = "tab",
        target_providers = {
          function(T)
            T.helloworld = { desc = "Hello world", cmd = "echo hello world" }
          end,
          "just",
          "cargo",
        },
      }
      require("kitty.current_win").setup {}
      K.setup_make()

      require("rust-tools").config.options.tools.executor = K.rust_tools_executor()

      vim.keymap.set("n", "<leader>tk", function()
        K.run()
      end, { desc = "Kitty Run" })
      vim.keymap.set("n", "<leader>tt", function()
        K.make()
      end, { desc = "Kitty Make" })
      vim.keymap.set("n", "<leader>t<CR>", function()
        K.make "last"
      end, { desc = "Kitty ReMake" })
      -- vim.keymap.set("n", "<leader>tK", KT.run, { desc = "Kitty Run" })
      -- vim.keymap.set("n", "", require("kitty").send_cell, { buffer = 0 })
      vim.api.nvim_create_user_command("Kitty", function(args)
        -- if args.fargs and #args.fargs > 0 then
        --   K[args.fargs[1]](unpack(vim.list_slice(args.fargs, 2)))
        -- end
        if args.fargs and #args.fargs > 0 then
          K.new_tab({}, args.fargs)
        else
          K.open()
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
    cmd = { "Kitty", "KittyOverlay" },
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
  -- TODO: Figure all this bullshit out
  -- {
  --   "numToStr/FTerm.nvim",
  --   event = "BufRead",
  --   config = function()
  --     require("lv-terms").fterm()
  --   end,

  -- },
  -- use {
  --   "dccsillag/magma-nvim",
  --   setup = function()
  --     require("lv-terms").magma()
  --   end,
  --   run = ":UpdateRemotePlugins",
  --   -- python3.9 -m pip install cairosvg pnglatex jupyter_client ipython ueberzug pillow
  --   -- cmd = "MagmaStart", -- see lv-terms

  -- }
  -- -- Better neovim terminal
  -- use {
  --   "kassio/neoterm",
  --   config = function()
  --     require("lv-terms").neoterm()
  --   end,
  --   cmd = {
  --     "T",
  --     "Tmap",
  --     "Tnew",
  --     "Ttoggle",
  --     "Topen",
  --   },
  --   keys = {
  --     "<Plug>(neoterm-repl-send)",
  --     "<Plug>(neoterm-repl-send-line)",
  --   },

  -- }
  -- use {
  --   "CRAG666/code_runner.nvim",
  --   config = function()
  --     require("lv-terms").coderunner()
  --   end,
  --   cmd = { "CRFileType", "CRProjects", "RunCode", "RunFile", "RunProject" },

  -- }
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
  -- TODO: https://github.com/Dax89/automaton.nvim
  -- use { -- TODO: configure vs-tasks
  --   "EthanJWright/vs-tasks.nvim",
  --   config = function() end,
  -- }
  -- https://github.com/lpoto/telescope-tasks.nvim
}
