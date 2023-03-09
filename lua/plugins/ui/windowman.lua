local prefix = "<C-w>"
local function window_hydra_setup()
  local Hydra = require "hydra"
  local splits = require "smart-splits"
  local splits_api = require "smart-splits"
  local function smart_splits(name, ...)
    local args = { ... }
    return function()
      splits[name](unpack(args))
    end
  end
  local function smart_splits_api(name, ...)
    local args = { ... }
    return function()
      splits_api[name](unpack(args))
    end
  end

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

      -- { "<M-h>", smart_splits_api("move_to_edge", "left", false), { desc = false } },
      -- { "<M-j>", smart_splits_api("move_to_edge", "down", false), { desc = false } },
      -- { "<M-k>", smart_splits_api("move_to_edge", "up", false), { desc = false } },
      -- { "<M-l>", smart_splits_api("move_to_edge", "right", false), { desc = false } },

      { "H", smart_splits "swap_buf_left" },
      { "J", smart_splits "swap_buf_down" },
      { "K", smart_splits "swap_buf_up" },
      { "L", smart_splits "swap_buf_right" },

      { "r", "<C-w>r" }, -- Rotate

      -- TODO: open nvim-tree if we go left far enough
      { "<C-h>", smart_splits("resize_left", 2) },
      { "<C-j>", smart_splits("resize_down", 2) },
      { "<C-k>", smart_splits("resize_up", 2) },
      { "<C-l>", smart_splits("resize_right", 2) },
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
    { "mrjones2014/smart-splits.nvim", opts = {
      cursor_follows_swapped_bufs = false,
    } },
    {
      "beauwilliams/focus.nvim",
      opts = {
        autoresize = false,
        signcolumn = false,
        cursorcolumn = false,
        number = false,
        relativenumber = false,
        hybridnumber = false,
        winhighlight = false,
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
    ignore = { --			  |windows.ignore|
      buftype = { "quickfix" },
      filetype = { "NvimTree", "neo-tree", "undotree", "gundo", "Outline" },
    },
  },
  config = function(_, opts)
    require("windows").setup(opts)
    window_hydra_setup()
  end,
  event = "VeryLazy",
}
