local function kitty_terms()
  -- TODO: handle this situation better
  if vim.g.flatten_is_nested then return end
  local kutils = require "kitty.utils"
  Terms = require "kitty.terms"
  Terms.setup {
    dont_attach = not not vim.g.kitty_scrollback,
    attach = {
      default_launch_location = "os-window",
      -- create_new_win = "os-window",
      target_providers = {
        "just",
        "cargo",
      },
      current_win_setup = {},
      on_attach = function(_, K, _)
        K.setup_make()

        -- TODO:
        -- require("rust-tools").config.options.tools.executor = K.rust_tools_executor()
        _G.Term = kutils.staticify(Terms.get_terminal(0), {})
        Term.make_cmd "Make"
      end,
      bracketed_paste = true,
    },
  }

  if vim.g.neovide then require("kitty.current_win").focus = function() pcall(vim.cmd.NeovideFocus) end end

  local map = vim.keymap.set
  -- TODO: move upstream
  map("n", "mK", function() Term.run() end, { desc = "Kitty Run" })
  map("n", "mk", function() Term.make() end, { desc = "Kitty Make" })
  map("n", "mkk", function() Term.make_last() end, { desc = "Kitty ReMake" })
  -- TODO: S-CR and C-CR can be used
  map("n", "mr", function() return Term.send_operator() end, { expr = true, desc = "Kitty Send" })
  map("x", "R", function() return Term.send_operator() end, { expr = true, desc = "Kitty Send" })
  map(
    "n",
    "mrr",
    function() return Term.send_operator { type = "line", range = "$" } end,
    { expr = true, desc = "Kitty Send Line" }
  )
  map("n", "yu", function() Term.get_selection() end, { desc = "Yank selection From Kitty" })
  map(
    "n",
    "yhu",
    function() Term.hints { type = "url", yank = "register" } end,
    { desc = "Yank hinted url From Kitty" }
  )
  map(
    "n",
    "yhf",
    function() Term.hints { type = "path", yank = "register" } end,
    { desc = "Yank hinted path From Kitty" }
  )
  map(
    "n",
    "yhl",
    function() Term.hints { type = "line", yank = "register" } end,
    { desc = "Yank hinted line From Kitty" }
  )
  map(
    "n",
    "yhe",
    function() Term.hints { type = "linenum", yank = "register" } end,
    { desc = "Yank hinted linenum From Kitty" }
  )
  map(
    "n",
    "yhw",
    function() Term.hints { type = "word", yank = "register" } end,
    { desc = "Yank hinted word From Kitty" }
  )
  map(
    "n",
    "<leader>ohu",
    function() Term.hints { type = "url", program = true } end,
    { desc = "hinted url From Kitty" }
  )
  map(
    "n",
    "<leader>ohf",
    function() Term.hints { type = "path", launch = "nvim" } end,
    { desc = "hinted file From Kitty in Nvim" }
  )
  map(
    "n",
    "<leader>ohp",
    function() Term.hints { type = "path", program = true } end,
    { desc = "hinted file From Kitty" }
  )
  map(
    "n",
    "<leader>ohe",
    function() Term.hints { type = "linenum", launch = "nvim" } end,
    { desc = "hinted linenum From Kitty" }
  )
  map("n", "<c-;>", "<cmd>Kitty<cr>", { desc = "Kitty Open" })
  map("n", "<leader>ok", "<cmd>Kitty<cr>", { desc = "Kitty Open" })
  map("n", "<leader>oKC", function() Term.cmd("cd " .. vim.fn.getpwd()) end, { desc = "Kitty CWD" })
  map("n", "<leader>oKT", function() Term.move "this-tab" end, { desc = "Kitty To This Tab" })
  map("n", "<leader>oKN", function() Term.move "new-tab" end, { desc = "Kitty To New Tab" })
  map("n", "<leader>oKW", function() Term.move "new-window" end, { desc = "Kitty To New OSWin" })
  map("ca", "K", ":=require'kitty.current_win'", { desc = "Kitty Control" })
  map("ca", "T", ":=Term", { desc = "Kitty Control" })
  map("ca", "KT", ":=require'kitty.terms'", { desc = "Kitty Control" })
  map("ca", "KK", ":=require'kitty'", { desc = "Kitty Control" })

  -- TODO:
  local function scroll(opts)
    return function() Term.scroll(opts) end
  end
  local vert_spd = require("keymappings.scroll_mode").vert_spd
  local scroll_hydra = require "hydra" {
    name = "Scroll Terminal",
    hint = "",
    config = {
      invoke_on_body = true,
      hint = {
        float_opts = { border = "rounded" },
        offset = -1,
      },
    },
    mode = "n",
    body = "<leader>vt",
    heads = {
      -- TODO: emulate this
      -- { "b", "zb", {exit = true, desc = "Center this Line" } },
      -- { "t", "zt", {exit = true, desc = "Bottom this Line" } },
      -- { "c", "zz", {exit = true, desc = "Top this Line" } },
      { "j", scroll { down = vert_spd } },
      { "k", scroll { up = vert_spd } },
      { "J", scroll { prompts = "1" } },
      { "K", scroll { prompts = "-1" } },
      { "d", scroll { down = "0.5p" } },
      { "u", scroll { up = "0.5p" } },
      { "G", scroll "end" },
      { "gg", scroll "start" },
      { "p", scroll { prompts = "0" } },
      { "<esc>", nil, { exit = true, nowait = true, desc = "exit" } },
    },
  }
  local key = function(from, to, opts)
    to = to or from:sub(2, -2) -- strip the <>
    return { from, function() Term.send_key(to) end, { desc = from } }
  end
  map("n", "mtt", function() Term.send_key { "up", "enter" } end, { desc = "Kitty Redo Cmd" })
  local cmdline_hydra = require "hydra" {
    name = "Remote Cmdline",
    hint = "",
    config = {
      invoke_on_body = false,
      hint = {
        float_opts = { border = "rounded" },
        offset = -1,
      },
    },
    mode = "n",
    body = "mt",
    heads = {
      key("k", "up"),
      key("j", "down"),
      key("h", "left"),
      key("l", "right"),
      { "K", scroll { prompts = "1" } },
      { "J", scroll { prompts = "-1" } },
      { "p", scroll { prompts = "0" } },
      { "d", scroll { down = "0.5p" } },
      { "u", scroll { up = "0.5p" } },
      { "G", scroll "end" },
      { "gg", scroll "start" },
      key "<esc>",
      key "<enter>",
      key "<tab>",
      key("c", "ctrl+c"), -- TODO: use signal_child instead
      key("d", "ctrl+d"),
      key("z", "ctrl+z"),
      { "f", function() Term.hints { yank = "" } end },
      { "<esc>", nil, { exit = true, nowait = true, desc = "exit" } },
    },
  }
end
return {
  -- FIXME: breaks when not run inside kitty, make it optional? no
  {
    "IndianBoy42/kitty.lua",
    event = "VeryLazy",
    cond = not not vim.env.KITTY_PID and not vim.g.kitty_scrollback,
    config = function() kitty_terms() end,
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
