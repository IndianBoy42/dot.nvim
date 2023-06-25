-- TODO: replace all keymaps with functions or something
-- TODO: <[cC][mM][dD]>lua
-- https://github.com/ziontee113/yt-tutorials/tree/nvim_key_combos_in_alacritty_and_kitty
local M = {}
local map = vim.keymap.set

-- Custom nN repeats
local custom_n_repeat = nil
local custom_N_repeat = nil
local nvim_feedkeys = vim.api.nvim_feedkeys
local termcode = vim.api.nvim_replace_termcodes
local function feedkeys(keys, o)
  if o == nil then o = "m" end
  nvim_feedkeys(termcode(keys, true, true, true), o, false)
end

function M.n_repeat()
  -- vim.cmd [[normal! m']]
  if custom_n_repeat == nil then
    feedkeys("n", "n")
  elseif type(custom_n_repeat) == "string" then
    feedkeys(custom_n_repeat)
  else
    custom_n_repeat()
  end
end

function M.N_repeat()
  -- vim.cmd [[normal! m']]
  if custom_N_repeat == nil then
    feedkeys("N", "n")
  elseif type(custom_N_repeat) == "string" then
    feedkeys(custom_N_repeat)
  else
    custom_N_repeat()
  end
end

local function register_nN_repeat(nN)
  nN = nN or { nil, nil }
  custom_n_repeat = nN[1]
  custom_N_repeat = nN[2]
end

M.register_nN_repeat = register_nN_repeat

-- Helper functions
local cmd = utils.cmd
local luareq = cmd.require
local telescope_fn = utils.telescope
local focus_fn = luareq "focus"
local lspbuf = vim.lsp.buf
local operatorfunc_scaffold = utils.operatorfunc_scaffold
local operatorfunc_keys = utils.operatorfunc_keys
local operatorfuncV_keys = utils.operatorfuncV_keys
local function make_nN_pair(pair, pre_action)
  return {
    function()
      vim.cmd [[normal! m']]
      if pre_action then
        pre_action[1]()
        if pre_action[3] then pre_action[3]() end
      end
      register_nN_repeat(pair)
      if type(pair[1]) == "string" then
        feedkeys(pair[1])
      else
        pair[1]()
      end
    end,
    function()
      vim.cmd [[normal! m']]
      if pre_action then
        pre_action[2]()
        if pre_action[3] then pre_action[3]() end
      end
      register_nN_repeat(pair)
      if type(pair[2]) == "string" then
        feedkeys(pair[2])
      else
        pair[2]()
      end
    end,
  }
end

M.make_nN_pair = make_nN_pair

vim.keymap.setl = function(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("keep", opts or {}, { buffer = 0 }))
end
local mapl = vim.keymap.setl
local sile = { silent = true, remap = true }
local nore = { noremap = true, silent = true }
local norexpr = { noremap = true, silent = true, expr = true }
local expr = { silent = true, expr = true }
local function op_from(lhs, rhs, opts)
  opts = opts or {}
  rhs = rhs or lhs

  map("o", lhs, "<cmd>normal v" .. rhs .. "<cr>", opts)
end

M.op_from = op_from
local function sel_map(lhs, rhs, opts)
  opts = opts or {}

  map("x", lhs, rhs, opts)
  op_from(lhs, rhs, opts)
end

M.sel_map = sel_map

function M.setup()
  local wk = require "which-key"

  -- Make CTRL-i work separate to <TAB>
  if vim.env.TERM == "xterm-kitty" then
    vim.cmd [[autocmd UIEnter * if v:event.chan ==# 0 | call chansend(v:stderr, "\x1b[>1u") | endif]]
    vim.cmd [[autocmd UILeave * if v:event.chan ==# 0 | call chansend(v:stderr, "\x1b[<1u") | endif]]
  end
  -- map("n", "<C-o>", "<NOP>", {})

  -- custom_n_repeat
  map("n", "n", M.n_repeat, nore)
  map("n", "N", M.N_repeat, nore)
  map("n", "<C-n>", function()
    M.n_repeat()
    vim.schedule(function() feedkeys "+" end)
  end, { desc = "Add Cursor at Next" })
  map("n", "<C-S-n>", function()
    M.N_repeat()
    vim.schedule(function() feedkeys "+" end)
  end, { desc = "Add Cursor at Prev" })
  local function srchrpt(k, op)
    return function()
      register_nN_repeat { nil, nil }
      feedkeys(type(k) == "function" and k() or k, op or "n")
    end
  end

  map("n", "/", srchrpt "/", { desc = "Search" })
  map("x", "g/", "/", { desc = "Search motion" })
  map("n", "<C-/>", srchrpt "?", { desc = "Search bwd" })
  map("n", "*", srchrpt "g*", { desc = "Search cword" }) -- Swap g* and *
  map("n", "<C-*>", srchrpt "g*", { desc = "Search cword" }) -- TODO: this could be used for something else
  map("n", "g*", srchrpt "*", { desc = "Search cword whole" })
  map("n", "g<C-*>", srchrpt "#", { desc = "Search cword whole" })
  map("n", "g.", [[/\V<C-r>"<CR>]] .. "cgn<C-a><ESC>", { desc = "Repeat change" }) -- Repeat the recent edit with cgn

  -- Command mode typos of wq
  --   vim.cmd [[
  --     cnoreabbrev W! w!
  --     cnoreabbrev Q! q!
  --     cnoreabbrev Qa! qa!
  --     cnoreabbrev Qall! qall!
  --     cnoreabbrev Wq wq
  --     cnoreabbrev Wa wa
  --     cnoreabbrev wQ wq
  --     cnoreabbrev WQ wq
  --     cnoreabbrev Wq wq
  --     cnoreabbrev qw wq
  --     cnoreabbrev Qw wq
  --     cnoreabbrev QW wq
  --     cnoreabbrev qW wq
  --     cnoreabbrev W w
  --     cnoreabbrev Q q
  --     cnoreabbrev Qa qa
  --     cnoreabbrev Qall qall
  -- ]]

  vim.o.mousetime = 0
  -- map("n", "<2-ScrollWheelUp>", "<nop>", sile)
  -- map("n", "<2-ScrollWheelDown>", "<nop>", sile)
  -- map("n", "<3-ScrollWheelUp>", "<nop>", sile)
  -- map("n", "<3-ScrollWheelDown>", "<nop>", sile)
  -- map("n", "<4-ScrollWheelUp>", "<nop>", sile)
  -- map("n", "<4-ScrollWheelDown>", "<nop>", sile)
  -- map("n", "<ScrollWheelUp>", "<C-a>", sile)
  -- map("n", "<ScrollWheelDown>", "<C-x>", sile)
  map("n", "<C-ScrollWheelUp>", "<C-a>", sile)
  map("n", "<C-ScrollWheelDown>", "<C-x>", sile)
  map("n", "<C-S-ScrollWheelUp>", cmd "FontUp", sile)
  map("n", "<C-S-ScrollWheelDown>", cmd "FontDown", sile)
  map("n", "<C-->", cmd "FontDown", sile)
  map("n", "<C-+>", cmd "FontUp", sile)

  -- More convenient incr/decr
  -- map("n", "+", "<C-a>", sile) -- recursive so we get dial.nvim
  -- map("n", "-", "<C-x>", sile)
  -- map("x", "+", "g<C-a>", sile)
  -- map("x", "-", "g<C-x>", sile)

  -- map("n", "<C-w><C-q>", function()
  --   for _, win in ipairs(vim.api.nvim_list_wins()) do
  --     local config = vim.api.nvim_win_get_config(win)
  --     if config.relative ~= "" then
  --       vim.api.nvim_win_close(win, false)
  --       print("Closing window", win)
  --     end
  --   end
  -- end)

  local resize_prefix = "<C-"
  if vim.fn.has "mac" == 1 then resize_prefix = "<M-" end
  map("n", resize_prefix .. "Up>", cmd "resize -2", sile)
  map("n", resize_prefix .. "Down>", cmd "resize +2", sile)
  map("n", resize_prefix .. "Left>", cmd "vertical resize -2", sile)
  map("n", resize_prefix .. "Right>", cmd "vertical resize +2", sile)

  -- Keep accidentally hitting J instead of j when first going visual mode
  map("x", "J", "j", nore)
  map("x", "<leader>J", "J", nore)

  function M.map_fast_indent()
    -- print "Setting up better indenting"
    mapl("n", ">", ">>", { nowait = true })
    mapl("n", "<", "<<", { nowait = true })
  end
  -- better indenting
  -- FIXME: broken with autosession??
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufReadPost", "BufNewFile" }, {
    callback = M.map_fast_indent,
  })
  map("n", "g<", "<", nore)
  map("n", "g>", ">", nore)
  map("x", "<", "<gv", nore)
  map("x", ">", ">gv", nore)

  -- for _, v in pairs { "h", "j", "k", "l" } do
  --   for _, m in pairs { "x", "n" } do
  --     map(m, v .. v, "<Nop>", sile)
  --   end
  -- end

  -- Tab switch buffer
  map("n", "<tab>", cmd "b#", nore)
  map("n", "<C-tab>", cmd "BufferLineCycleNext", nore)
  map("n", "<C-S-tab>", cmd "BufferLineCyclePrev", nore)
  map("n", "<tab><tab>", require("keymappings.buffer_mode").tab_new_or_next, nore)
  map("n", "<S-tab><S-tab>", require("keymappings.buffer_mode").tab_new_or_prev, nore)

  -- Move selection
  map("x", "<C-h>", "", {})
  map("x", "<C-j>", "", {})
  map("x", "<C-k>", "", {})
  map("x", "<C-l>", "", {})

  -- Preserve register on pasting in visual mode
  -- TODO: use the correct register
  -- map("x", "p", "pgvy", nore)
  map("x", "p", '"_dP', nore)
  map("x", "P", "p", nore) -- for normal p behaviour
  map("x", "<M-p>", "pgv", nore) -- Paste and keep selection

  -- Add meta version that doesn't affect the clipboard
  local function dont_clobber_if_meta(m, c)
    if string.upper(c) == c then
      map(m, "<M-S-" .. string.lower(c) .. ">", '"_' .. c, nore)
    else
      map(m, "<M-" .. c .. ">", '"_' .. c, nore)
    end
  end

  -- Make the default not touch the clipboard, and add a meta version that does
  local function dont_clobber_by_default(m, c)
    if string.upper(c) == c then
      map(m, "<M-S-" .. string.lower(c) .. ">", c, nore)
    else
      map(m, "<M-" .. c .. ">", c, nore)
    end
    -- map(m, c, '"_' .. c, nore)
    vim.keymap.amend(m, c, function(orig)
      feedkeys('"_', "ni") -- FIXME:
      vim.schedule(orig)
    end)
  end

  dont_clobber_if_meta("n", "d")
  dont_clobber_if_meta("n", "D")
  dont_clobber_if_meta("x", "r")
  -- dont_clobber_by_default("n", "c")
  -- dont_clobber_by_default("x", "c")
  -- dont_clobber_by_default("n", "C")
  dont_clobber_by_default("n", "x")
  -- dont_clobber_by_default("x", "x")

  -- Preserve cursor on yank in visual mode
  -- TODO: use register argument
  map("x", "y", "myy`y", nore)
  map("x", "Y", "myY`y", nore) -- copy linewise
  map("x", "<M-y>", "y", nore)

  map("n", "<M-p>", [[<cmd>call setreg('p', getreg('"'), 'c')<cr>"pp]], nore) -- charwise paste
  -- map("n", "<M-S-C-P>", [[<cmd>call setreg('p', getreg('+'), 'c')<cr>"pP]], nore) -- charwise paste
  -- map("n", "<M-S-p>", [[<cmd>call setreg('p', getreg('+'), 'l')<cr>"pp]], nore) -- linewise paste

  -- -- move along visual lines, not numbered ones
  -- -- without interferring with {count}<down|up>
  -- map("n", "<up>", "v:count == 0 ? 'gk' : '<up>'", norexpr)
  -- map("x", "<up>", "v:count == 0 ? 'gk' : '<up>'", norexpr)
  -- map("n", "<down>", "v:count == 0 ? 'gj' : '<down>'", norexpr)
  -- map("x", "<down>", "v:count == 0 ? 'gj' : '<down>'", norexpr)

  local repeatable = require("keymappings.jump_mode").repeatable

  -- QuickFix
  -- local quickfix_looping =
  --   { cmd "try | cnext | catch | cfirst | catch | endtry", cmd "try | cprev | catch | clast | catch | endtry" }
  local quickfix_looping = {
    function()
      local ok, _ = pcall(vim.cmd.cafter)
      if ok then return end
      local ok, _ = pcall(vim.cmd.cnext)
      if ok then return end
      vim.cmd.cfirst()
    end,
    function()
      local ok, _ = pcall(vim.cmd.cbefore)
      if ok then return end
      local ok, _ = pcall(vim.cmd.cprev)
      if ok then return end
      vim.cmd.clast()
    end,
  }
  local loclist_looping = {
    function()
      local ok, _ = pcall(vim.cmd.lafter)
      if ok then return end
      local ok, _ = pcall(vim.cmd.lnext)
      if ok then return end
      vim.cmd.lfirst()
    end,
    function()
      local ok, _ = pcall(vim.cmd.lbefore)
      if ok then return end
      local ok, _ = pcall(vim.cmd.lprev)
      if ok then return end
      vim.cmd.llast()
    end,
  }
  -- local quickfix_nN = make_nN_pair(quickfix_looping)
  -- map("n", O.goto_next .. "q", quickfix_nN[1], { desc = "Quickfix" })
  -- map("n", O.goto_previous .. "q", quickfix_nN[2], { desc = "Quickfix" })
  repeatable("q", "Quickfix", quickfix_looping, {})
  -- local loclist_nN = make_nN_pair(loclist_looping)
  -- map("n", O.goto_next .. "l", loclist_nN[1], { desc = "Loclist" })
  -- map("n", O.goto_previous .. "l", loclist_nN[2], { desc = "Loclist" })
  repeatable("l", "Loclist", loclist_looping, {})

  -- Diagnostics jumps
  -- local diag_nN = make_nN_pair { utils.lsp.diag_next, utils.lsp.diag_prev }
  -- map("n", O.goto_next .. "d", diag_nN[1], nore)
  -- map("n", O.goto_previous .. "d", diag_nN[2], nore)
  -- local error_nN = make_nN_pair { utils.lsp.error_next, utils.lsp.error_prev }
  -- map("n", O.goto_next .. "e", error_nN[1], nore)
  -- map("n", O.goto_previous .. "e", error_nN[2], nore)
  repeatable(
    { "d", "D", "e", "E" },
    "Diags",
    { utils.lsp.diag_next, utils.lsp.diag_prev, utils.lsp.error_next, utils.lsp.error_prev },
    {
      body = { O.goto_next, O.goto_previous, O.goto_next_outer, O.goto_previous_outer },
    }
  )
  repeatable("e", "Error", { utils.lsp.error_next, utils.lsp.error_prev }, {})

  local on_list_gen = function(pair)
    local on_list_next = {
      reuse_win = true,
      on_list = function(options)
        vim.fn.setqflist({}, " ", options)
        if #options.items > 1 then register_nN_repeat(pair) end
        pair[1]()
      end,
    }
    local on_list_prev = {
      reuse_win = true,
      on_list = function(options)
        vim.fn.setqflist({}, " ", options)
        if #options.items > 1 then register_nN_repeat(pair) end
        pair[2]()
      end,
    }
    return on_list_next, on_list_prev
  end
  local on_list_hydra = function(n, p, move)
    return on_list_gen {
      function()
        n:activate()
        if move and move[1] then move[1]() end
      end,
      function()
        p:activate()
        if move and move[2] then move[2]() end
      end,
    }
  end
  local on_list_next, on_list_prev = on_list_gen(quickfix_looping)

  local ref_n, ref_p = repeatable("r", "Reference", quickfix_looping, { body = false })
  local ref_list_next, ref_list_prev = on_list_hydra(ref_n, ref_p, quickfix_looping)
  map("n", O.goto_next .. "r", function() vim.lsp.buf.references(nil, ref_list_next) end, { desc = "Reference" })
  map("n", O.goto_previous .. "r", function() vim.lsp.buf.references(nil, ref_list_prev) end, { desc = "Reference" })
  local impl_n, impl_p = repeatable("i", "Implementation", quickfix_looping, { body = false })
  local impl_list_next, impl_list_prev = on_list_hydra(impl_n, impl_p, quickfix_looping)
  map("n", O.goto_next .. "i", function() vim.lsp.buf.implementation(impl_list_next) end, { desc = "Implementation" })
  map(
    "n",
    O.goto_previous .. "i",
    function() vim.lsp.buf.implementation(impl_list_prev) end,
    { desc = "Implementation" }
  )

  -- local para_nN = make_nN_pair { "}", "{" }
  -- map("n", O.goto_next .. "p", para_nN[1], { desc = "Para" })
  -- map("n", O.goto_previous .. "p", para_nN[2], { desc = "Para" })
  repeatable("p", "Paragraph", { "}", "{" }, {})

  local jumps = {
    -- d = "Diagnostics",
    -- e = "Errors",
    -- q = "QuickFix",
    -- l = "Loc List",
    -- g = "Git Hunk",
    -- u = "Usage",
    -- p = "Paragraph",
  }
  wk.register({
    ["]"] = jumps,
    ["["] = jumps,
  }, M.wkopts)

  local function undotree(body)
    require "hydra" {
      name = "undotree",
      body = body,
      on_enter = function() vim.cmd.UndotreeShow() end,
      on_exit = function() vim.cmd.UndotreeHide() end,
      config = {},
      heads = {
        { "u", "u", { desc = false } },
        { "<C-r>", "<C-r>", { desc = false } },
        { "+", "g+", { desc = false } },
        { "-", "g-", { desc = false } },
        { "q", nil, { exit = true } },
      },
    }
  end
  undotree "g+"
  undotree "g-"

  -- Close window
  map("n", "<c-q>", "<C-w>q", nore)
  map("n", "<c-s-q>", ":wqa", nore)

  map("n", "zz", "za", { desc = "Fold" })
  map("n", "zm", "zM", { desc = "Close under cursor" })
  map("n", "zr", "zR", { desc = "Close under cursor" })
  map("n", "zM", "zm", { desc = "Close one fold" })
  map("n", "zR", "zr", { desc = "Close under cursor" })

  -- Search textobject
  map("n", "<leader>*", operatorfunc_keys "*", { desc = "Search (op)" })

  -- Search for last edited text
  map("n", 'g"', [[/\V<C-r>"<CR>]], { desc = "Search for last cdy" })
  -- map("x", 'g"', [[:keepjumps normal! /\V<C-r>"<CR>gn]])
  map("x", 'g"', '<ESC>g"gn', { remap = true, desc = "Search for last cdy" })

  -- Start search and replace from search
  map("c", "<M-r>", [[<cr>:%s/<C-R>///g<Left><Left>]], {})
  -- Jump between matches without leaving search mode
  map("c", "<M-n>", [[<C-g>]], { silent = true })
  map("c", "<M-S-n>", [[<C-t>]], { silent = true })

  -- Continue the search and keep selecting (equivalent ish to doing `gn` in normal)
  map("x", "n", "<esc>ngn", nore)
  map("x", "N", "<esc>NgN", nore)
  -- Select the current/next search match
  map("x", "gn", "<esc>gn", nore)
  map("x", "gN", "<esc>NNgN", nore) -- current/prev

  -- Double Escape key clears search and spelling highlights
  -- FIXME: why do you delete yourself??
  map("n", "<esc>", function()
    local ok, _ = pcall(function() return vim.cmd "FzClear" end)
    vim.cmd "nohlsearch"

    pcall(function() require("blinker").blink_cursorline() end)
    vim.o.spell = false
    local ok, notify = pcall(require, "notify")
    if ok then notify.dismiss { silent = true } end
  end, sile)

  -- Go Back
  if true then
    -- require "hydra" {
    --   name = "Jumplist",
    --   mode = "n",
    --   config = {
    --     on_key = function()
    --       -- Preserve animation
    --       vim.wait(50, function()
    --         vim.cmd "redraw!"
    --         return false
    --       end, 30, false)
    --     end,
    --   },
    --   body = O.goto_prefix,
    --   heads = {
    --     { "h", function() feedkeys("<c-o>", "n") end, { desc = "Go Back" } },
    --     { "l", function() feedkeys("<c-i>", "n") end, { desc = "Go Forward" } },
    --     -- { "q", nil, { exit = true } },
    --     -- { "<ESC>", nil, { exit = true } },
    --   },
    -- }
    require "hydra" {
      name = "Changelist",
      body = O.goto_prefix .. "c",
      mode = "n",
      config = {
        on_key = function()
          -- Preserve animation
          vim.wait(50, function()
            vim.cmd "redraw!"
            return false
          end, 30, false)
        end,
      },
      heads = {
        { ";", function() feedkeys("g;", "n") end, { desc = "Go Back" } },
        { ",", function() feedkeys("g,", "n") end, { desc = "Go Forward" } },
        -- { "q", nil, { exit = true } },
        -- { "<ESC>", nil, { exit = true } },
      },
    }
  else
    map("n", "gb", "<c-o>", nore)
  end
  map("n", "<M-h>", "<c-o>", nore)
  map("n", "<M-l>", "<c-i>", nore)

  local function quick_toggle(prefix, suffix, callback, name)
    require "hydra" {
      name = name,
      body = prefix,
      mode = "n",
      config = {
        timeout = 5000,
        on_key = function()
          -- Preserve animation
          vim.wait(50, function()
            vim.cmd "redraw!"
            return false
          end, 30, false)
        end,
      },
      heads = {
        { suffix, callback, { desc = name } },
      },
    }
  end
  quick_toggle("<leader>T", "d", utils.lsp.toggle_diagnostics)
  quick_toggle("<leader>T", "i", F "vim.lsp.buf.inlay_hint(0)")

  -- Select last pasted
  map("n", "<leader>p", "v`[o`]", { desc = "Select Last Paste" })
  map("x", "<leader>p", "`[o`]", { desc = "Select Last Paste" })
  map("n", "<leader>P", "V`[o`]", { desc = "SelLine Last Paste" })
  map("x", "<leader>P", "<esc>gP", { remap = true, desc = "SelLine Last Paste" })
  map("n", "<leader><C-p>", "<C-v>`[o`]", { desc = "SelBlock Last Paste" })
  map("x", "<leader><C-p>", "<esc>g<C-p>", { remap = true, desc = "SelBlock Last Paste" })
  -- Use reselect as an operator
  op_from "<leader>gp"
  op_from "<leader>P"
  op_from "<leader><C-p>"

  local cmt_op = require("editor.edit").comment_operator
  map("n", "<leader>" .. cmt_op, operatorfuncV_keys("<leader>" .. cmt_op), sile)
  map("n", "<leader>" .. cmt_op .. cmt_op, "V<leader>" .. cmt_op, sile)

  -- Swap the mark jump keys
  map("n", "'", "`", nore)
  map("n", "`", "'", nore)
  map("n", "M", "m", nore)

  -- Spell checking
  -- map("i", "<C-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u", nore)

  map("i", "<M-a>", cmd "normal! A", nore)
  map("i", "<M-i>", cmd "normal! I", nore)

  -- Slightly easier commands
  map({ "n", "x" }, ";", ":", {})
  -- map('c', ';', "<cr>", sile)

  -- Add semicolon TODO: make this smarter
  -- map("i", ";;", "<esc>mzA;`z", nore)
  -- map("i", "<M-;>", "<C-o>A;", nore)
  map("i", "<M-;>", "<C-o>o", nore)

  map("i", "<M-r>", "<C-r>", nore)
  map("i", "<M-BS>", "<C-g>u<C-w>", nore)

  -- TODO: Use more standard regex syntax
  -- map("n", "/", "/\v", nore)

  -- Split line
  map("n", "go", "i<cr><ESC>k<cmd>sil! keepp s/\v +$//<cr><cmd>noh<cr>j^", { desc = "Split Line" })

  -- Quick activate macro
  -- map({ "n", "x" }, "Q", "@q", nore)

  -- Reselect visual linewise
  map("n", "gV", "'<V'>", nore)
  map("x", "gV", "<esc>gV", sile)
  -- Reselect visual block wise
  map("n", "g<C-v>", "'<C-v>'>", nore)
  map("x", "g<C-v>", "<esc>g<C-v>", sile)

  -- stuff
  map({ "n", "x", "o" }, "<c-e>", "ge", sile)
  map({ "n", "x", "o" }, "<c-s-e>", "gE", sile)

  -- Use reselect as an operator
  op_from "gv"
  op_from "gV"
  op_from "g<C-v>"

  local function undo_brkpt(key)
    -- map("i", key, key .. "<c-g>u", nore)
    map("i", key, "<c-g>u" .. key, nore)
  end

  local undo_brkpts = {
    "<cr>",
    ",",
    ".",
    ";",
    "{",
    "}",
    "[",
    "]",
    "(",
    ")",
    "'",
    '"',
  }
  for _, v in ipairs(undo_brkpts) do
    undo_brkpt(v)
  end
  map("n", "U", "<C-R>", nore)

  -- Go to multi insert from Visual mode
  map("s", "<M-i>", "<ESC>I", {})
  map("s", "<M-a>", "<ESC>A", {})

  -- Select all matching regex search
  -- map("n", "<M-S-/>", "<M-/><M-a>", {remap=true})

  -- Keymaps for easier access to 'ci' and 'di'
  local function quick_inside(key, no_v)
    map("o", key, "i" .. key, { remap = true })
    if not no_v then
      -- TODO: weirdly buggy with mini.surround
      -- map("x", key, "i" .. key, { remap = true })
    end
    map("n", "<M-" .. key .. ">", "vi" .. key, { remap = true })
  end

  local function quick_around(key)
    map("o", key, "a" .. key, { remap = true })
    if not no_v then
      -- TODO: weirdly buggy with mini.surround
      map("x", key, "i" .. key, { remap = true })
    end
    map("n", "<M-" .. key .. ">", "va" .. key, { remap = true })
  end

  quick_inside "w"
  quick_inside "W"
  -- quick_inside("p", true)
  -- quick_inside "b"
  -- quick_inside "B"
  -- quick_inside "["
  -- quick_around "]"
  -- quick_inside "("
  -- quick_around ")"
  -- quick_inside "{"
  -- quick_around "}"
  -- quick_inside '"'
  -- quick_inside "'"
  -- quick_inside "<"
  -- quick_inside ">"
  -- quick_inside "q"
  -- map("n", ",", "viw")

  -- "better" end and beginning of line
  map("o", "H", "^", { remap = true })
  map({ "o", "x" }, "L", "$", { remap = true })
  -- map("x", "H", "^", { remap = true })
  -- map("x", "L", "g_", { remap = true })
  -- map("n", "H", [[col('.') == match(getline('.'),'\S')+1 ? '0' : '^']], norexpr)
  -- map("n", "L", "$", { remap = true })
  map("n", "L", "i<C-l>", { remap = true })

  -- map("n", "m-/", "")

  -- Select whole file
  map("o", "ie", "<cmd>normal! mzggVG<cr>`z", nore)
  sel_map("ie", "gg0oG$", nore)

  -- Operator for current line
  -- sel_map("il", "g_o^")
  -- sel_map("al", "$o0")

  -- Make change line (cc) preserve indentation
  map("n", "cc", "^cg_", { desc = "Change line" })

  map("x", ".", ":normal .<CR>", sile)

  map("n", "dd", function()
    if vim.api.nvim_get_current_line():match "^%s*$" then
      return '"_dd'
    else
      return "dd"
    end
  end, { noremap = true, expr = true })

  -- add j and k with count to jumplist
  M.countjk()

  -- Terminal pass through escape key
  map("t", "<ESC>", "<ESC>", nore)
  map("t", "<ESC><ESC>", [[<C-\><C-n>]], nore)

  -- Leader shortcut for ][ jumping and )( swapping
  map("n", "<leader>j", O.goto_next, { remap = true, desc = "Jump next (])" })
  map("n", "<leader>k", O.goto_previous, { remap = true, desc = "Jump prev ([)" })
  map("n", "<leader>J", O.goto_next_outer, { remap = true, desc = "Jump next outer (]])" })
  map("n", "<leader>K", O.goto_previous_outer, { remap = true, desc = "Jump prev outer ([[)" })
  -- map("n", "<leader>h", ")", { remap = true, desc = "Hop" })

  map({ "n", "x" }, "<cr><cr>", "<cmd>wa<cr>", { desc = "Write" })

  map("n", "m", F 'require"which-key".show "m"')

  -- Selection mode
  if false then
    map("s", "i", "<C-g><esc>i")
    map("s", "a", "<C-g>o<esc>a")
    map("s", "c", "<C-o>c")
    map("s", "d", "<C-o>c")
    map("s", "y", "<C-o>y")
    map("s", "v", "<C-g>")
  else
    map("s", "<cr>", "<C-g>")
  end

  -- -- Open new line with a count
  -- map("n", "o", function()
  --   local count = vim.v.count
  --   feedkeys("o", "n")
  --   for _ = 1, count do
  --     feedkeys "<CR>"
  --   end
  -- end, nore)

  local leaderOpts = {
    mode = "n", -- NORMAL mode
    prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = false,
    -- silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = false, -- use `nowait` when creating keymaps
  }
  local vLeaderOpts = {
    mode = "v", -- Visual mode
    prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = false,
    -- silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = false, -- use `nowait` when creating keymaps
  }

  local leaderMappings = {
    [";"] = { telescope_fn.commands, "Srch Commands" },
    -- [";"] = { cmd "Dashboard", "Dashboard" },
    ["/"] = { telescope_fn.live_grep, "Global search" },
    -- f = { telescope_fn.find_files, "Smart Open File" },
    f = { telescope_fn.smart_open, "Smart Open File" },
    F = { telescope_fn.find_all_files, "Find all Files" },
    ["<Space>"] = { "<cmd>w<cr>", "Write" },
    W = {
      function()
        if vim.api.nvim_buf_get_name(0) == "" then
          vim.notify("No filename yet, complete in cmdline", vim.log.levels.WARN)
          feedkeys ":noau w "
          -- vim.ui.input({ prompt = "filename:" }, function(f)
          --   vim.cmd("w " .. f)
          -- end)
        else
          vim.cmd "noau w"
        end
      end,
      "Write (noau)",
    }, -- w = { cmd "noau up", "Write" },
    q = { "<C-W>q", "Quit" },
    ["<C-Q>"] = { "<cmd>qa<cr>", "Quit All" },
    Q = { function() return pcall(vim.cmd.tabclose) or pcall(vim.cmd.quitall) end, "Quit Tab" },
    e = {
      name = "Edit",
      m = "Move",
      c = "TextCase",
    },
    o = {
      name = "Open window",
      u = { cmd "UndotreeToggle", "Undo tree" },
      f = { F "MiniFiles.open()", "File Browser" },
      o = { cmd "SymbolsOutline", "Outline" },
      s = {
        e = { cmd "TroubleToggle workspace_diagnostics", "Diagnostics" },
        g = { cmd "TroubleToggle document_diagnostics", "Doc Diagnostics" },
        r = { cmd "TroubleToggle lsp_references", "References" },
        d = { cmd "TroubleToggle lsp_definitions", "Definitions" },
        q = { cmd "TroubleToggle quickfix", "Quick Fix" },
        l = { cmd "TroubleToggle loclist", "Loc List" },
        f = { cmd "NvimTreeToggle", "File Sidebar" },
      },
      t = { cmd "TroubleToggle", "Trouble" },
      n = { cmd "Navbuddy", "Navbuddy" },
      q = { utils.quickfix_toggle, "Quick fixes" },
      E = { cmd "!open '%:p:h'", "Open File Explorer" },
      M = { vim.g.goneovim and cmd "GonvimMiniMap" or cmd "MinimapToggle", "Minimap" },
      d = { cmd "DiffviewOpen", "Diffview" },
      H = { cmd "DiffviewFileHistory", "File History" },
      h = { cmd "NoiceHistory", "Noice History" },
      g = { cmd "!smerge '%:p:h'", "Sublime Merge" },
    },
    m = { name = "Make" },
    x = { name = "Run" },
    p = { name = "Project (Tasks)" },
    v = { name = "Visualize" },
    T = {
      name = "Toggle Opts",
      w = { cmd "setlocal wrap!", "Wrap" },
      s = { cmd "setlocal spell!", "Spellcheck" },
      c = { name = "Cursor/Column" },
      cc = { cmd "setlocal cursorcolumn!", "Cursor column" },
      cn = { cmd "setlocal number!", "Number column" },
      cs = { cmd "setlocal signcolumn!", "Cursor column" },
      cl = { cmd "setlocal cursorline!", "Cursor line" },
      h = { cmd "setlocal hlsearch", "hlsearch" },
      b = { cmd "set buflisted", "buflisted" },
      n = { utils.conceal_toggle, "Conceal" },
      H = { cmd "ToggleHiLightComments", "Comment Highlights" },
      v = { cmd "NvimContextVtToggle", "Context VT" },
      -- d = { utils.lsp.toggle_diagnostics, "Toggle Diags" },
      -- i = { F "vim.lsp.buf.inlay_hint(0)", "Toggle Inlay Hints" },
      d = "Toggle Diags",
      i = "Toggle Inlay Hints",
      fb = {
        utils.lsp.format_on_save_toggle(vim.b),
        "Toggle Format on Save",
      },
      fg = {
        utils.lsp.format_on_save_toggle(vim.g),
        "Toggle Format on Save (Global)",
      },
      fmb = {
        function() vim.b.Format_on_save_mode = "mod" end,
        "Format Mods on Save",
      },
      fmg = {
        function() vim.g.Format_on_save_mode = "mod" end,
        "Format Mods on Save (Global)",
      },
    },
    -- b = {
    --   name = "Buffers",
    --   -- n = { cmd "enew", "New" },
    --   -- s = { cmd "Telescope buffers", "Search" },
    -- },
    b = "+Buffers",
    g = { name = "Git" },
    i = {
      name = "Info",
      l = { cmd "LspInfo", "LSP" },
      n = { cmd "NullLsInfo", "Null-ls" },
      i = { cmd "Mason", "LspInstall" },
      t = { cmd "TSConfigInfo", "Treesitter" },
      p = { cmd "Lazy", "Lazy plugins" },
    },
    l = {
      name = "LSP",
      h = { lspbuf.hover, "Hover (H)" },
      a = { telescope_fn.code_actions_previewed, "Code Action (K)" },
      k = { vim.lsp.codelens.run, "Run Code Lens (gK)" },
      f = { utils.lsp.format, "Format" },
      c = { lspbuf.signature_help, "Signature Help" },
      C = {
        name = "Calls",
        i = { lspbuf.incoming_calls, "Incoming" },
        o = { lspbuf.outgoing_calls, "Outgoing" },
      },
      -- d = { telescope_fn.lsp_definitions, "Definitions" },
      -- D = { lspbuf.decalaration, "Declaration" },
      -- t = { lspbuf.type_definition, "Type Definition" },
      -- r = { telescope_fn.lsp_references, "References" },
      -- i = { telescope_fn.lsp_implementations, "Implementations" },
      -- s = {
      -- name = "View in Split", -- TODO: peek before pick
      d = { utils.lsp.view_location_pick "definition", "Definition" },
      D = { utils.lsp.view_location_pick "declaration", "Declaration" },
      t = { utils.lsp.view_location_pick "typeDefinition", "Type Def" },
      r = { utils.lsp.view_location_pick "references", "References" },
      i = { utils.lsp.view_location_pick "implementation", "Implementation" },
      -- },
      p = {
        name = "Peek in Float",
        d = { utils.lsp.preview_location_at "definition", "Definition" },
        D = { utils.lsp.preview_location_at "declaration", "Declaration" },
        t = { utils.lsp.preview_location_at "typeDefinition", "Type Def" },
        r = { telescope_fn.lsp_references, "References" },
        i = { telescope_fn.lsp_implementations, "Implementation" },
        e = { utils.lsp.diag_line, "Diagnostics" },
      },
      b = {
        name = "Sidebar",
        d = { cmd "TroubleToggle lsp_definitions", "Definitions" },
        r = { cmd "TroubleToggle lsp_references", "References" },
        e = { cmd "TroubleToggle workspace_diagnostics", "Diagnostics" },
        g = { cmd "TroubleToggle document_diagnostics", "Diagnostics" },
      },
    },
    s = {
      name = "Search",
      [" "] = { telescope_fn.resume, "Redo last" },
      -- n = { telescope_fn.notify.notify, "Notifications" },
      f = { telescope_fn.find_files, "Find File" },
      -- c = { telescope_fn.colorscheme, "Colorscheme" },
      s = { telescope_fn.lsp_document_symbols, "Document Symbols" },
      w = { telescope_fn.lsp_dynamic_workspace_symbols, "Workspace Symbols" },
      d = { telescope_fn.diagnostics, "Document Diagnostics" },
      D = { telescope_fn.workspace_diagnostics, "Workspace Diagnostics" },
      h = { telescope_fn.help_tags, "Find Help" },
      j = { telescope_fn.jumplist, "Jump List" },
      M = { telescope_fn.man_pages, "Man Pages" },
      -- R = { telescope_fn.registers, "Registers" },
      t = { telescope_fn.live_grep, "Text" },
      T = { telescope_fn.live_grep_all, "Text (ALL)" },
      -- b = { telescope_fn.curbuf, "Current Buffer" },
      b = { telescope_fn.buffers, "Buffers" },
      -- i = { telescope_fn.curbuf, "in Buffer" },
      k = { telescope_fn.keymaps, "Keymappings" },
      c = { telescope_fn.commands, "Commands" },
      [";"] = { telescope_fn.command_history, "Command History" },
      N = { telescope_fn.treesitter, "Treesitter Nodes" },
      u = { cmd "Telescope undo", "Telescope Undo" },
      o = { cmd "TodoTelescope", "TODOs search" },
      q = { telescope_fn.quickfix, "Quickfix" },
      ["*"] = { telescope_fn.grep_string, "Curr word" },
      ["/"] = { telescope_fn.grep_last_search, "Last Search" },
      -- ["."] = { [[:%s/<C-R>.//g<Left><Left>]], "Last insert" },
      m = { telescope_fn.marks, "Marks" },
      _ = { ":Telescope ", "Telescope ..." },
      ["<CR>"] = { telescope_fn.builtin, "Telescopes" },
      ["+"] = { [[/<C-R>+<cr>]], "Last yank" },
      ["."] = { [[/<C-R>.<cr>]], "Last insert" },
    },
    r = {
      name = "Replace/Refactor",
      -- n = { utils.lsp.rename, "Rename" }, -- Use IncRename
      ["/"] = { [[:%s/<C-R>///g<Left><Left>]], "Last search" },
      ["+"] = { [[:%s/<C-R>+//g<Left><Left>]], "Last yank" },
      ["."] = { [[:%s/<C-R>.//g<Left><Left>]], "Last insert" },
      s = { [[:%s///g<Left><Left><Left>]], "Sub In File" },
      i = "Inside",
      r = "Spectre",
      c = "TextCase",
    },
    n = {
      name = "Generate",
      n = { cmd "Neogen", "Gen Doc" },
      f = { cmd "Neogen func", "Func Doc" },
      F = { cmd "Neogen file", "File Doc" },
      t = { cmd "Neogen type", "type Doc" },
      c = { cmd "Neogen class", "Class Doc" },
      b = { name = "Comment Box" },
    },
    d = {
      name = "Diagnostics/Debug",
      l = { utils.lsp.diag_line, "Line Diagnostics" },
      b = { cmd "TroubleToggle workspace_diagnostics", "Diagnostics" },
      s = { telescope_fn.diagnostics, "Document Diagnostics" },
      w = { telescope_fn.workspace_diagnostics, "Workspace Diagnostics" },
      t = { utils.lsp.toggle_diagnostics, "Toggle Diags" },
      j = { utils.lsp.diag_next, "Next" },
      k = { utils.lsp.diag_prev, "Prev" },
    },
    u = {
      name = "(un) Clear",
      h = { cmd "nohlsearch", "Search Highlight" },
    },
    -- c = {
    --   operatorfunc_keys("<leader>c"),
    --   "Change all",
    -- },
  }

  local vLeaderMappings = {
    -- ["/"] = { cmd "CommentToggle", "Comment" },
    ["*"] = { telescope_fn.grep_string, "Curr selection" },
    l = {
      name = "LSP",
      d = { utils.lsp.range_diagnostics, "Range Diagnostics" },
      a = { telescope_fn.code_actions_previewed, "Code Actions" },
      f = { utils.lsp.format, "Format" },
    },
    r = {
      name = "Replace/Refactor",
      i = {
        name = "In",
        s = { ":s///g<Left><Left><Left>", "In Selection" },
      },
      ["/"] = { [[:%s/<C-R>///g<Left><Left>]], "Last search" },
      ["+"] = { [[:%s/<C-R>+//g<Left><Left>]], "Last yank" },
      ["."] = { [[:%s/<C-R>.//g<Left><Left>]], "Last insert" },
    },
    -- c = {
    --   [["z<M-y>:%s/<C-r>z//g<Left><Left>]],
    --   "Change all",
    -- },
    D = { name = "Debug" },
    e = { name = "Edit" },
  }

  -- TODO: move these to different modules?
  wk.register(leaderMappings, leaderOpts)
  wk.register(vLeaderMappings, vLeaderOpts)

  local iLeaderOpts = {
    mode = "i",
    prefix = "<F1>",
    noremap = false,
  }
  local maps = vim.api.nvim_get_keymap "i"
  local iLeaderMappings = {}
  for _, m in ipairs(maps) do
    -- keymaps starting with '<M-', '<C-'
    local mpat = "^<[mMcC]-(%w+)>$"
    local _, _, k = m.lhs:find(mpat)
    if k and not iLeaderMappings[k] then iLeaderMappings[k] = { m.lhs, m.desc } end
  end
  wk.register(iLeaderMappings, iLeaderOpts)

  local ops = { mode = "n" }
  wk.register({
    ["gy"] = "which_key_ignore",
    ["gyy"] = "which_key_ignore",
    ["z="] = {
      telescope_fn.spell_suggest,
      "Spelling suggestions",
    },
  }, ops)

  -- TODO: register all g prefix keys in whichkey

  require("keymappings.scroll_mode").setup()
  require("keymappings.fold_mode").setup()
  require("keymappings.buffer_mode").setup()

  vim.keymap.set("n", O.select_next, "v" .. O.select_next, { remap = true })
  vim.keymap.set("n", O.select_next_outer, "v" .. O.select_next_outer, { remap = true })
  vim.keymap.set("n", O.select_previous, "v" .. O.select_previous, { remap = true })
  vim.keymap.set("n", O.select_previous_outer, "v" .. O.select_previous_outer, { remap = true })

  -- FIXME: duplicate entries for some of the operators
end

local mincount = 5
function M.wrapjk()
  map({ "n", "x" }, "j", [[v:count ? (v:count > ]] .. mincount .. [[ ? "m'" . v:count : '') . 'j' : 'gj']], norexpr)
  map({ "n", "x" }, "k", [[v:count ? (v:count > ]] .. mincount .. [[ ? "m'" . v:count : '') . 'k' : 'gk']], norexpr)
end

function M.countjk()
  map("n", "j", [[(v:count > ]] .. mincount .. [[ ? "m'" . v:count : '') . 'j']], norexpr)
  map("n", "k", [[(v:count > ]] .. mincount .. [[ ? "m'" . v:count : '') . 'k']], norexpr)
end

M.wkopts = {
  mode = "n", -- NORMAL mode
  silent = true,
  noremap = false,
  nowait = false,
}
function M.whichkey(maps, opts)
  if opts == nil then opts = {} end
  require("which-key").register(maps, vim.tbl_extend("keep", opts, M.wkopts))
end

function M.localleader(maps, opts)
  if opts == nil then opts = {} end
  M.whichkey(
    maps,
    vim.tbl_extend("keep", opts, {
      prefix = "<localleader>",
      buffer = 0,
    })
  )
end

function M.ftleader(maps, opts)
  if opts == nil then opts = {} end
  M.whichkey(
    maps,
    vim.tbl_extend("keep", opts, {
      prefix = "<leader>",
      buffer = 0,
    })
  )
end

function M.vlocalleader(maps, opts)
  if opts == nil then opts = {} end
  M.localleader(maps, vim.tbl_extend("keep", opts, { mode = "v" }))
end

M.repeatable = require("keymappings.jump_mode").repeatable

utils.lsp.on_attach(function(client, bufnr)
  local map = function(mode, lhs, rhs, opts)
    if bufnr then opts.buffer = bufnr end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
  -- if client.server_capabilities.documentRangeFormattingProvider then
  --   map("n", "gq", utils.lsp.format_range_operator, { desc = "Format Range" })
  --   map("x", "gq", utils.lsp.format, { desc = "Format Range" })
  -- end

  local telescope_cursor = function(name)
    -- TODO: make this bigger
    return function() return telescope_fn[name](require("telescope.themes").get_cursor()) end
  end

  map("n", "gd", telescope_cursor "lsp_definitions", { desc = "Goto Definition" })
  map("n", O.goto_prefix .. "d", telescope_cursor "lsp_definitions", { desc = "Goto Definition" })
  -- map("n", "gd", vim.lsp.buf.definition, { desc = "Definition" })
  map("n", "gD", lspbuf.declaration, { desc = "Goto Declaration" })
  map("n", O.goto_prefix .. "D", lspbuf.declaration, { desc = "Goto Declaration" })
  map("n", O.goto_prefix .. "r", telescope_fn.lsp_references, { desc = "Goto References" })
  -- Preview variants -- TODO: preview and then open new window
  map("n", "gpd", utils.lsp.preview_location_at "definition", { desc = "Peek definition" }) -- TODO: replace with glance.nvim?
  map("n", "gpD", utils.lsp.preview_location_at "declaration", { desc = "Peek declaration" })
  map("n", "gpr", telescope_fn.lsp_references, { desc = "Peek references" })
  map("n", "gpi", telescope_fn.lsp_implementations, { desc = "Peek implementation" })
  map("n", "gpe", utils.lsp.diag_line, { desc = "Diags" })
  -- Hover
  -- map("n", "K", lspbuf.hover, sile)
  map("n", "H", utils.lsp.repeatable_hover, { desc = "LSP Hover" })
  map("n", "<M-i>", lspbuf.signature_help, { desc = "LSP Signature Help" })
  map({ "n", "x" }, "K", telescope_fn.code_actions_previewed, { remap = true, desc = "Do Code Action" })
  local code_action_op = operatorfunc_keys("K", "r")
  map("n", "<leader>K", code_action_op, { remap = true, desc = "Do Code Action At" })
  map("n", "<leader>H", operatorfunc_keys("<ESC>H", "rl"), { remap = true, desc = "Do Code Action At" })
  map("n", "<leader>H", operatorfunc_keys ":norm ", { remap = true, desc = "Do Code Action At" })

  -- Formatting keymaps
  map({ "n" }, "gf", utils.lsp.format, { desc = "Format Async" })
end, "lsp_mappings")

return setmetatable(M, {
  __call = function(tbl, ...) return map(unpack(...)) end,
})

-- m  t (in normal mode maybe?)
-- prefixes
-- c d y r
-- suffixes
-- p x o u . ; -
-- v is useful but not
-- op-op combinations
