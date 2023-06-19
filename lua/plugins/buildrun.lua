-- TODO: use dr and yr
return {
  {
    "IndianBoy42/kitty.lua",
    dev = true,
    init = function() require "plugins.buildrun.kitty" end,
    config = function() require("kitty.current_win").setup {} end,
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
  -- https://github.com/Olical/conjure
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
      { "!!", "<Plug>SnipRun", desc = "SnipRun Line" },
      { "!", "<Plug>SnipRunOperator", desc = "SnipRun" },
      { "!", "<Plug>SnipRun", desc = "SnipRun", mode = "x" },
      { "<leader>xQ", "<Plug>SnipReset", desc = "SnipRun Reset" },
      { "<leader>xq", "<Plug>SnipReplMemoryClean", desc = "SnipRun Clean" },
      { "<leader>xi", "<Plug>SnipInfo", desc = "SnipRun Info" },
      { "<leader>xl", "<Plug>SnipLive", desc = "SnipRun Live" },
      { "<leader>xc", "<Plug>SnipClose", desc = "SnipRun Close" },
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
  -- use {
  --   "pianocomposer321/yabs.nvim",
  --   config = function()
  --     require("lv-yabs").config()
  --   end,
  --   module = { "yabs", "telescope._extensions.yabs" },

  -- }
  -- https://github.com/lpoto/telescope-tasks.nvim
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
      { "dP", utils.lazy_require("debugprint").debugprint, desc = "DbgPrnt Line abv", expr = true },
      {
        "dpv",
        utils.partial(utils.lazy_require("debugprint").debugprint, { variable = true }),
        desc = "DbgPrnt Var",
        expr = true,
      },
      {
        "dpV",
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
        "<leader>dp",
        utils.partial(utils.lazy_require("debugprint").debugprint, { variable = true, above = true }),
        desc = "DbgPrnt Var abv",
        mode = "x",
        expr = true,
      },
    },
  },
  {
    "rafcamlet/nvim-luapad",
    opts = {},
    cmd = { "Luapad", "LuaRun", "LuaAttach", "LuaDetach", "LuaEval" },
    config = function(_, opts)
      require("luapad").setup(opts)
      local cmd = function(name, fn, opts)
        vim.api.nvim_create_user_command(
          name,
          function(args) require("luapad")[fn](type(opts) == "function" and opts(args) or opts) end,
          { nargs = "*" }
        )
      end
      cmd("LuaAttach", "attach", {})
      cmd("LuaDetach", "detach", {})
      vim.api.nvim_create_user_command("LuaEval", function(args) require("luapad.state").current():eval() end, {})
    end,
  },
}
