local cmd = utils.cmd
local go_to_buffer_abs = false
local M = {
  tab_new_or = function(orelse)
    if #vim.api.nvim_list_tabpages() == 1 then
      vim.cmd "tabnew"
    else
      vim.cmd(orelse)
    end
  end,
}
M.tab_new_or_next = function() M.tab_new_or "tabnext" end
M.tab_new_or_prev = function() M.tab_new_or "tabprev" end
M.tab_new_or_last = function() M.tab_new_or "tabnext #" end
M.setup = function()
  local hydra_peek_buffer = nil
  local function switch_buffer(func)
    if func then func() end
    hydra_peek_buffer = vim.api.nvim_get_current_buf()
  end
  local hydra_peek = require "hydra" {
    name = "Peek Buffers",
    body = "<leader>B",
    config = {
      color = "red",
      on_enter = function() hydra_peek_buffer = vim.api.nvim_get_current_buf() end,
      on_exit = function() vim.api.nvim_set_current_buf(hydra_peek_buffer) end,
    },
    heads = {
      { "1", function() require("bufferline").go_to(1, go_to_buffer_abs) end, { desc = "to 1" } },
      { "2", function() require("bufferline").go_to(2, go_to_buffer_abs) end, { desc = "to 2" } },
      { "3", function() require("bufferline").go_to(3, go_to_buffer_abs) end, { desc = "to 3" } },
      { "4", function() require("bufferline").go_to(4, go_to_buffer_abs) end, { desc = "to 4" } },
      { "5", function() require("bufferline").go_to(5, go_to_buffer_abs) end, { desc = "to 5" } },
      { "6", function() require("bufferline").go_to(6, go_to_buffer_abs) end, { desc = "to 6" } },
      { "7", function() require("bufferline").go_to(7, go_to_buffer_abs) end, { desc = "to 7" } },
      { "8", function() require("bufferline").go_to(8, go_to_buffer_abs) end, { desc = "to 8" } },
      { "9", function() require("bufferline").go_to(9, go_to_buffer_abs) end, { desc = "to 9" } },
      { "h", cmd "BufferLineCycleNext", { desc = "Next" } },
      { "l", cmd "BufferLineCyclePrev", { desc = "Prev" } },
    },
  }
  require "hydra" {
    name = "Buffers",
    -- TODO:
    hint = [[
         ^ ^^S^^w^^i^^t^^c^^h^^ ^^ ^   ^ ^    Sort        ^ ^   Close
      ---^-^^-^^-^^-^^-^^-^^-^^-^^-^-- ^-^--------------  ^-^--------------
      <- _h_^ ^^P^^e^^e^^k^^ ^_l_^ ^-> _SD_: by Directory _d_: This Buf
      <- _j_^S^^w^^i^^t^^c^^h^_k_^ ^-> _SE_: by Extension _c_: This+Win
         _1__2__3__4__5__6__7__8__9_   _p_: Toggle Pin    _H_, _L_: Left/Right
      <- _J_^ ^^M^^o^^v^^e^^ ^_K_^ ^-> ^ ^    Exit       
      ^^^^^^^^^^^^^^^ _<tab>_: Last ^  ^-^--------------  _O_: Others
      ^^^^^^^^^^^^^^^ _n_: New      ^  _<ESC>_: Peek      _U_: Unpinned
      ^^^^^^^^^^^^^^^ _s_: Telescope^  _<CR>_: Switch     _G_: Group ]],

    config = {
      on_key = function()
        vim.wait(200, function()
          vim.cmd.redraw()
          return true
        end, 30, false)
      end,
      color = "red",
      invoke_on_body = true,
      hint = {
        float_opts = { border = "rounded" },
        type = "window",
        position = "bottom",
        show_name = true,
      },
      on_enter = function() hydra_peek_buffer = vim.api.nvim_get_current_buf() end,
      on_exit = function() vim.api.nvim_set_current_buf(hydra_peek_buffer) end,
    },
    body = "<leader>b",
    heads = {
      { "C", function() switch_buffer(vim.cmd.bdelete) end, { desc = false } },
      { "D", function() switch_buffer(vim.cmd.Bdelete) end, { desc = false } },
      { "c", function() switch_buffer(vim.cmd.bdelete) end, { exit = true, desc = "Close+Win" } },
      { "d", function() switch_buffer(vim.cmd.Bdelete) end, { exit = true, desc = "Delete" } },
      { "p", cmd "BufferLineTogglePin", { desc = "Pin" } },
      -- { "P", function() hydra_peek:activate() end, { desc = "Peek", exit_before = true } },
      { "n", cmd "enew", { desc = "New", exit_before = true } },
      { "s", cmd "Telescope buffers", { desc = "Search", exit_before = true } },
      { "<tab>", cmd "b#", { desc = "last" } },
      { "<C-1>", function() require("bufferline").go_to(1, go_to_buffer_abs) end, { desc = false } },
      { "<C-2>", function() require("bufferline").go_to(2, go_to_buffer_abs) end, { desc = false } },
      { "<C-3>", function() require("bufferline").go_to(3, go_to_buffer_abs) end, { desc = false } },
      { "<C-4>", function() require("bufferline").go_to(4, go_to_buffer_abs) end, { desc = false } },
      { "<C-5>", function() require("bufferline").go_to(5, go_to_buffer_abs) end, { desc = false } },
      { "<C-6>", function() require("bufferline").go_to(6, go_to_buffer_abs) end, { desc = false } },
      { "<C-7>", function() require("bufferline").go_to(7, go_to_buffer_abs) end, { desc = false } },
      { "<C-8>", function() require("bufferline").go_to(8, go_to_buffer_abs) end, { desc = false } },
      { "<C-9>", function() require("bufferline").go_to(9, go_to_buffer_abs) end, { desc = false } },
      { "1", function() require("bufferline").move_to(1) end, { desc = "to 1" } },
      { "2", function() require("bufferline").move_to(2) end, { desc = "to 2" } },
      { "3", function() require("bufferline").move_to(3) end, { desc = "to 3" } },
      { "4", function() require("bufferline").move_to(4) end, { desc = "to 4" } },
      { "5", function() require("bufferline").move_to(5) end, { desc = "to 5" } },
      { "6", function() require("bufferline").move_to(6) end, { desc = "to 6" } },
      { "7", function() require("bufferline").move_to(7) end, { desc = "to 7" } },
      { "8", function() require("bufferline").move_to(8) end, { desc = "to 8" } },
      { "9", function() require("bufferline").move_to(9) end, { desc = "to 9" } },
      { "l", cmd "BufferLineCycleNext", { desc = "Peek Next" } },
      { "h", cmd "BufferLineCyclePrev", { desc = "Peek Prev" } },
      { "k", function() switch_buffer(vim.cmd.BufferLineCycleNext) end, { desc = "Next" } },
      { "j", function() switch_buffer(vim.cmd.BufferLineCyclePrev) end, { desc = "Prev" } },
      { "J", cmd "BufferLineMoveNext", { desc = "Move Next" } },
      { "K", cmd "BufferLineMovePrev", { desc = "Move Prev" } },
      { "SD", cmd "BufferLineSortByDirectory", { desc = "sort directory" } },
      { "SE", cmd "BufferLineSortByExtension", { desc = "sort language" } },
      { "H", cmd "BufferLineCloseLeft", { desc = "close left" } },
      { "L", cmd "BufferLineCloseRight", { desc = "close right" } },
      { "O", cmd "BufferLineCloseOthers", { desc = "close others" } },
      { "G", cmd "BufferLineGroupClose", { desc = "close group" } },
      { "U", function() require("bufferline").group_action("pinned", "close") end, { desc = "close unpinned" } },
      { "<ESC>", nil, { exit = true, nowait = true, desc = "exit" } },
      { "<CR>", switch_buffer, { exit = true, nowait = true, desc = "exit" } },
    },
  }

  -- Tab management keybindings
  local tab_mgmt = {
    t = {
      M.tab_new_or_last,
      "Next or",
    },
    -- ["<C-t>"] = { cmd "tabnext", "which_key_ignore" },
    n = { cmd "tabnew", "New" },
    q = { cmd "tabclose", "Close" },
    l = { cmd "tabnext", "Next" },
    h = { cmd "tabprev", "Prev" },
    L = { cmd "tabmove +1", "Move Next" },
    H = { cmd "tabmove -1", "Move Prev" },
    p = { cmd "Telescope telescope-tabs list_tabs", "Search tabs" },
    o = { cmd "tabonly", "Close others" },
    ["1"] = { cmd "tabfirst", "Tab 1" },
    ["2"] = { cmd "tabnext 2", "Tab 2" },
    ["3"] = { cmd "tabnext 3", "Tab 3" },
    ["4"] = { cmd "tabnext 4", "Tab 4" },
    ["5"] = { cmd "tabnext 5", "Tab 5" },
    ["6"] = { cmd "tabnext 6", "Tab 6" },
    ["7"] = { cmd "tabnext 7", "Tab 7" },
    ["8"] = { cmd "tabnext 8", "Tab 8" },
    ["9"] = { cmd "tabnext 9", "Tab 9" },
    ["0"] = { cmd "tablast", "Last tab" },
  }
  local map = vim.keymap.prefixed "<leader>t"
  map("n", "t", M.tab_new_or_last, { desc = "New or last" })
  map("n", "n", cmd "tabnew", { desc = "New" })
  map("n", "q", cmd "tabclose", { desc = "Close" })
  map("n", "l", cmd "tabnext", { desc = "Next" })
  map("n", "h", cmd "tabprev", { desc = "Prev" })
  map("n", "L", cmd "tabmove +1", { desc = "Move Next" })
  map("n", "H", cmd "tabmove -1", { desc = "Move Prev" })
  map("n", "p", cmd "Telescope telescope-tabs list_tabs", { desc = "Search tabs" })
  map("n", "o", cmd "tabonly", { desc = "Close others" })
  map("n", "1", cmd "tabfirst", { desc = "Tab 1" })
  map("n", "2", cmd "tabnext 2", { desc = "Tab 2" })
  map("n", "3", cmd "tabnext 3", { desc = "Tab 3" })
  map("n", "4", cmd "tabnext 4", { desc = "Tab 4" })
  map("n", "5", cmd "tabnext 5", { desc = "Tab 5" })
  map("n", "6", cmd "tabnext 6", { desc = "Tab 6" })
  map("n", "7", cmd "tabnext 7", { desc = "Tab 7" })
  map("n", "8", cmd "tabnext 8", { desc = "Tab 8" })
  map("n", "9", cmd "tabnext 9", { desc = "Tab 9" })
  map("n", "0", cmd "tablast", { desc = "Last tab" })
end

return M
