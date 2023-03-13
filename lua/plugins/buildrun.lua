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
  --   disable = not O.plugin.floatterm,
  -- },
  -- use {
  --   "dccsillag/magma-nvim",
  --   setup = function()
  --     require("lv-terms").magma()
  --   end,
  --   run = ":UpdateRemotePlugins",
  --   -- python3.9 -m pip install cairosvg pnglatex jupyter_client ipython ueberzug pillow
  --   -- cmd = "MagmaStart", -- see lv-terms
  --   disable = not O.plugin.magma,
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
  --   disable = not O.plugin.neoterm,
  -- }
  -- use {
  --   "CRAG666/code_runner.nvim",
  --   config = function()
  --     require("lv-terms").coderunner()
  --   end,
  --   cmd = { "CRFileType", "CRProjects", "RunCode", "RunFile", "RunProject" },
  --   disable = not O.plugin.coderunner,
  -- }
  -- use {
  --   "jubnzv/mdeval.nvim",
  --   config = function()
  --     require("lv-terms").mdeval()
  --   end,
  -- }
  -- use { "goerz/jupytext.vim" }
  -- use {
  --   "untitled-ai/jupyter_ascending.vim",
  --   setup = function()
  --     vim.g.jupyter_ascending_default_mappings = false
  --   end,
  -- }
  -- use {
  --   "pianocomposer321/yabs.nvim",
  --   config = function()
  --     require("lv-yabs").config()
  --   end,
  --   module = { "yabs", "telescope._extensions.yabs" },
  --   disable = not O.plugin.yabs,
  -- }
  -- -- use { -- TODO: configure vs-tasks
  -- --   "EthanJWright/vs-tasks.nvim",
  -- --   config = function() end,
  -- -- }
  -- https://github.com/lpoto/telescope-tasks.nvim
}
