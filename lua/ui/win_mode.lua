local prefix = "<C-w>"
local function window_hydra_setup()
  local Hydra = require "hydra"
  local splits = require "smart-splits"
  local splits_api = require "smart-splits.api"
  local function smart_splits(name, ...)
    local args = { ... }
    return function() splits[name](unpack(args)) end
  end
  local function smart_splits_api(name, ...)
    local args = { ... }
    return function() splits_api[name](unpack(args)) end
  end

  local cmd = require("hydra.keymap-util").cmd
  local pcmd = require("hydra.keymap-util").pcmd

  local window_hint = [[
 ^^^^^^^^^^^^     Move      ^^    Size   ^^   ^^     Split      ^^     Tab
 ^^^^^^^^^^^^-------------  ^^-----------^^   ^^--------------- ^^---------------
 ^ ^ _k_ ^ ^  ^ ^ _K_ ^ ^   ^   _<C-k>_   ^   _s_: horizontally _t_: next _n_: new
 _h_ ^ ^ _l_  _H_ _O_ _L_   _<C-h>_ _<C-l>_   _v_: vertically   _m_: prev
 ^ ^ _j_ ^ ^  ^ ^ _J_ ^ ^   ^   _<C-j>_   ^   _c_, _q_: close ^ _C_, _Q_: close
 focus^^^^^^  window^^^^^^  ^_=_: equalize^   _z_: maximize     _P_: list
 _p_: pick buffer ^^^^^^^^^^_w_: pick win ^^  _o_: remain only  _o_: remain only ]]

  local heads = {
    -- TODO: open nvim-tree if we go left far enough
    { "<C-h>", smart_splits "move_cursor_left" },
    { "<C-j>", smart_splits "move_cursor_down" },
    { "<C-k>", smart_splits "move_cursor_up" },
    { "<C-l>", smart_splits "move_cursor_right" },

    -- { "<M-h>", smart_splits_api("move_to_edge", "left", false), { desc = false } },
    -- { "<M-j>", smart_splits_api("move_to_edge", "down", false), { desc = false } },
    -- { "<M-k>", smart_splits_api("move_to_edge", "up", false), { desc = false } },
    -- { "<M-l>", smart_splits_api("move_to_edge", "right", false), { desc = false } },

    { "h", smart_splits "swap_buf_left" },
    { "j", smart_splits "swap_buf_down" },
    { "k", smart_splits "swap_buf_up" },
    { "l", smart_splits "swap_buf_right" },

    { "O", cmd "RotatePanesAnti" }, -- Rotate

    { "H", smart_splits("resize_left", 2) },
    { "J", smart_splits("resize_down", 2) },
    { "K", smart_splits("resize_up", 2) },
    { "L", smart_splits("resize_right", 2) },
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

    {
      "w",
      function() require("ui.win_pick").pick_or_create(vim.api.nvim_set_current_win) end,
      { exit = true, desc = "Pick window" },
    },
    {
      "<C-w>",
      function() require("ui.win_pick").pick_or_create(vim.api.nvim_set_current_win) end,
      { exit = true, desc = false },
    },

    { "z", cmd "WindowsMaximize", { exit = true, desc = "maximize" } },
    { "<C-z>", cmd "WindowsMaximize", { exit = true, desc = false } },
    { "Z", cmd "WindowsMaximizeVertically", { exit = true, desc = "maximize" } },
    { "<C-A-z>", cmd "WindowsMaximizeVertically", { exit = true, desc = false } },

    { "o", "<C-w>o", { exit = true, desc = "remain only" } },
    { "<C-o>", "<C-w>o", { exit = true, desc = false } },

    { "p", cmd "BufferLinePick", { exit = true, desc = "choose buffer" } },
    { "b", cmd "Telescope buffers", { exit = true, desc = false } },

    { "c", pcmd("close", "E444") },
    { "q", cmd "bdelete", { desc = "close+buf" } },
    { "<C-c>", pcmd("close", "E444"), { desc = false } },
    { "<C-q>", pcmd("close", "E444"), { desc = false } },

    { "<Esc>", nil, { exit = true, desc = false } },
  }

  return Hydra {
    name = "Windows",
    hint = window_hint,
    config = {
      invoke_on_body = true,
      hint = {
        float_opts = { border = "rounded" },
        offset = -1,
      },
      timeout = 2000,
    },
    mode = "n",
    body = prefix,
    heads = heads,
  }
end
return {
  { "anuvyklack/middleclass" },
  {
    "mrjones2014/smart-splits.nvim",
    opts = {
      cursor_follows_swapped_bufs = true,
      -- at_edge = "split",
      at_edge = function(ctx)
        -- {
        --    mux = {
        --      type:'tmux'|'wezterm'|'kitty'
        --      current_pane_id():number,
        --      is_in_session(): boolean
        --      current_pane_is_zoomed():boolean,
        --      -- following methods return a boolean to indicate success or failure
        --      current_pane_at_edge(direction:'left'|'right'|'up'|'down'):boolean
        --      next_pane(direction:'left'|'right'|'up'|'down'):boolean
        --      resize_pane(direction:'left'|'right'|'up'|'down'):boolean
        --    },
        --    direction = 'left'|'right'|'up'|'down',
        --    split(), -- utility function to split current Neovim pane in the current direction
        -- }
        if require("ui.tree").cond then
          if ctx.direction == "left" then
            vim.cmd.NvimTreeFocus()
            return
          end
          -- elseif ctx.direction == "right" then
          --   vim.cmd.Trouble()
        end
        ctx.split()
      end,
    },
    keys = function()
      local smart_splits = function(fn, opts)
        return function() require("smart-splits")[fn](opts) end
      end
      return {
        { "<C-h>", smart_splits "move_cursor_left", mode = { "n", "t" }, desc = "Move/Split h" },
        { "<C-j>", smart_splits "move_cursor_down", mode = { "n", "t" }, desc = "Move/Split j" },
        { "<C-k>", smart_splits "move_cursor_up", mode = { "n", "t" }, desc = "Move/Split k" },
        { "<C-l>", smart_splits "move_cursor_right", mode = { "n", "t" }, desc = "Move/Split l" },
      }
    end,
  },
  {
    "anuvyklack/windows.nvim",
    opts = {
      autowidth = {
        enable = true,
        winwidth = 0.5,
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
      local hydra = window_hydra_setup()
      vim.keymap.set("n", "<leader>w", function() hydra:activate() end, { desc = "Windowman" })
    end,
    event = "VeryLazy",
  },
  {
    "IndianBoy42/ezlayout.nvim",
    dev = true,
    opts = {},
    cmd = { "RotatePanes", "RotatePanesAnti" },
  },
}
