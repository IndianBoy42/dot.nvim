local prefix = "<C-w>"
local function mode()
  local Hydra = require "hydra"
  local splits = require "smart-splits"

  local cmd = require("hydra.keymap-util").cmd
  local pcmd = require("hydra.keymap-util").pcmd

  local window_hint = [[
 ^^^^^^^^^^^^     Move      ^^    Size   ^^   ^^     Split      ^^     Tab
 ^^^^^^^^^^^^-------------  ^^-----------^^   ^^--------------- ^^---------------
 ^ ^ _k_ ^ ^  ^ ^ _K_ ^ ^   ^   _<C-k>_   ^   _s_: horizontally _t_: next _n_: new
 _h_ ^ ^ _l_  _H_ _r_ _L_   _<C-h>_ _<C-l>_   _v_: vertically   _m_: prev
 ^ ^ _j_ ^ ^  ^ ^ _J_ ^ ^   ^   _<C-j>_   ^   _c_, _q_: close ^ _C_, _Q_: close
 focus^^^^^^  window^^^^^^  ^_=_: equalize^   _z_: maximize     _P_: list
 ^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^   ^^ ^          ^   _o_: remain only  _O_: remain only
 _p_: pick buffer
]]

  Hydra {
    name = "Windows",
    hint = window_hint,
    config = {
      invoke_on_body = true,
      hint = {
        border = "rounded",
        offset = -1,
      },
    },
    mode = "n",
    body = prefix,
    heads = {
      { "h", "<C-w>h" },
      { "j", "<C-w>j" },
      { "k", pcmd("wincmd k", "E11", "close") },
      { "l", "<C-w>l" },

      { "H", cmd "WinShift left" },
      { "J", cmd "WinShift down" },
      { "K", cmd "WinShift up" },
      { "L", cmd "WinShift right" },

      { "r", "<C-w>r" },

      {
        "<C-h>",
        function()
          splits.resize_left(2)
        end,
      },
      {
        "<C-j>",
        function()
          splits.resize_down(2)
        end,
      },
      {
        "<C-k>",
        function()
          splits.resize_up(2)
        end,
      },
      {
        "<C-l>",
        function()
          splits.resize_right(2)
        end,
      },
      { "=", "<C-w>=", { desc = "equalize" } },

      { "n", cmd "tabnew", { desc = "New Tab" } },
      { "t", cmd "tabnext", { desc = "Next Tab" } },
      { "m", cmd "tabprev", { desc = "Prev Tab" } },
      { "C", cmd "tabclose", { desc = "Close Tab" } },
      { "Q", cmd "tabclose", { desc = "Close Tab" } },
      { "P", cmd "Telescope telescope-tabs list_tabs", { exit = true, desc = "List Tabs" } },
      { "O", cmd "tabonly", { exit = true, desc = "Close Other Tabs" } },

      { "s", pcmd("split", "E36") },
      { "<C-s>", pcmd("split", "E36"), { desc = false } },
      { "v", pcmd("vsplit", "E36") },
      { "<C-v>", pcmd("vsplit", "E36"), { desc = false } },

      { "w", "<C-w>w", { exit = true, desc = false } },
      { "<C-w>", "<C-w>w", { exit = true, desc = false } },

      { "z", cmd "WindowsMaximize", { exit = true, desc = "maximize" } },
      { "<C-z>", cmd "WindowsMaximize", { exit = true, desc = false } },

      { "o", "<C-w>o", { exit = true, desc = "remain only" } },
      { "<C-o>", "<C-w>o", { exit = true, desc = false } },

      { "p", cmd "BufferLinePick", { exit = true, desc = "choose buffer" } },
      { "b", cmd "Telescope buffers", { exit = true, desc = false } },

      { "c", pcmd("close", "E444") },
      { "q", pcmd("close", "E444"), { desc = "close window" } },
      { "<C-c>", pcmd("close", "E444"), { desc = false } },
      { "<C-q>", pcmd("close", "E444"), { desc = false } },

      { "<Esc>", nil, { exit = true, desc = false } },
    },
  }
end
return {
  "anuvyklack/windows.nvim",
  dependencies = {
    "anuvyklack/middleclass",
    { "mrjones2014/smart-splits.nvim", opts = {} },
    { "sindrets/winshift.nvim", opts = {} },
    {
      "beauwilliams/focus.nvim",
      opts = {
        autoresize = false,
        signcolumn = false,
        cursorcolumn = false,
        number = false,
        relativenumber = false,
        hybridnumber = false,
        winhighlight = true,
      },
      keys = function()
        -- stylua: ignore
        return {
          { "<C-h>", function() require 'focus'.split_command('h') end, mode = { "n", "t" }, desc = "Move/Split" },
          { "<C-j>", function() require 'focus'.split_command('j') end, mode = { "n", "t" }, desc = "Move/Split" },
          { "<C-k>", function() require 'focus'.split_command('k') end, mode = { "n", "t" }, desc = "Move/Split" },
          { "<C-l>", function() require 'focus'.split_command('l') end, mode = { "n", "t" }, desc = "Move/Split" },
        }
      end,
    },
  },
  opts = {
    autowidth = {
      enable = true,
      winwidth = 20,
    },
    animation = {
      enable = false,
      duration = 20,
      fps = 30,
      easing = "in_out_sine",
    },
  },
  config = function(_, opts)
    require("windows").setup(opts)
    mode()
  end,
  event = "VeryLazy",
}
