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
local t = vim.keycode
local function feedkeys(keys, o)
  if o == nil then o = "m" end
  nvim_feedkeys(t(keys), o, false)
end
vim.feedkeys = feedkeys

function M.n_repeat()
  -- vim.cmd [[normal! m']]
  if custom_n_repeat == nil then
    feedkeys("n", "n")
    vim.opt.wrapscan = true
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
    vim.opt.wrapscan = true
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
local telescope_cursor = function(name)
  -- TODO: make this bigger
  return function() return telescope_fn[name](require("telescope.themes").get_cursor()) end
end
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

local keyset = vim.keymap.set
vim.keymap.set = function(mode, lhs, rhs, opts)
  keyset(mode, lhs, rhs, vim.tbl_extend("keep", opts or {}, { silent = true }))
end
vim.keymap.setl = function(mode, lhs, rhs, opts)
  keyset(mode, lhs, rhs, vim.tbl_extend("keep", opts or {}, { buffer = 0, silent = true }))
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
  map("i", "<C-i>", "<C-i>", {})

  -- custom_n_repeat
  map("n", "n", M.n_repeat, nore)
  map("n", "N", M.N_repeat, nore)
  -- TODO: this broke
  -- map("n", "<C-n>", function()
  --   M.n_repeat()
  --   vim.schedule(function() feedkeys "+" end)
  -- end, { desc = "Add Cursor at Next" })
  -- map("n", "<C-S-n>", function()
  --   M.N_repeat()
  --   vim.schedule(function() feedkeys "+" end)
  -- end, { desc = "Add Cursor at Prev" })
  local function srchrpt(k, op)
    return function()
      register_nN_repeat { nil, nil }
      feedkeys(type(k) == "function" and k() or k, op or "n")
    end
  end

  map("n", "/", srchrpt "/", { desc = "Search" })
  map("x", "g/", "/", { desc = "Search motion" })
  map("n", "<C-/>", srchrpt "?", { desc = "Search bwd" })
  -- Swap g* and * ?
  -- TODO: the visual mode versions need repeating
  map("n", "*", srchrpt "*", { desc = "Search cword" })
  map("n", "<C-*>", srchrpt "#", { desc = "Search cword" })
  map("n", "g*", srchrpt "g*", { desc = "Search cword whole" })
  map("n", "<C-g><C-*>", srchrpt "g#", { desc = "Search cword whole" })
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

  -- make gf follow line number as well
  -- TODO: use window-picker
  map({ "x", "n" }, "gf", "gF", { desc = "Goto File:Nr" })
  map({ "x", "n" }, "gF", "gf", { desc = "Goto File" })
  map({ "x", "n" }, O.goto_prefix .. "f", "gF", { desc = "Goto File:Nr" })
  map({ "x", "n" }, O.goto_prefix .. "F", "gf", { desc = "Goto File" })
  map({ "x", "n" }, O.goto_prefix .. "x", "gx", { desc = "Open URL" })
  -- TODO:
  map({ "x", "n" }, O.goto_prefix .. "pf", function() end, { desc = "Peek File:Nr" })
  map({ "x", "n" }, O.goto_prefix .. "pF", function() end, { desc = "Peek File" })
  -- for _, v in pairs { "h", "j", "k", "l" } do
  --   for _, m in pairs { "x", "n" } do
  --     map(m, v .. v, "<Nop>", sile)
  --   end
  -- end

  -- Tab switch buffer
  map("n", "<tab>", cmd "b#", { desc = "Last Buffer" })
  map("n", "<S-tab>", require("keymappings.buffer_mode").tab_new_or_next, { desc = "Next Tab" })
  -- map("n", "<S-cr><S-tab>", require("keymappings.buffer_mode").tab_new_or_prev, { desc = "Prev Tab" })

  -- Move selection
  map("x", "<C-h>", "", {})
  map("x", "<C-j>", "", {})
  map("x", "<C-k>", "", {})
  map("x", "<C-l>", "", {})

  -- Preserve register on pasting in visual mode
  -- TODO: use the correct register
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

  if true then
    local xcount = 0
    local reg = '"x'
    local not_repeat = true
    local op = "v:lua.__merging_single_char_del"
    _G.__merging_single_char_del = function()
      if not_repeat then
        not_repeat = false
      else
        vim.cmd("normal! " .. tostring(xcount) .. reg .. "x")
      end
    end
    local plug = vim.keycode "<Plug>(del-single-char)"
    map("n", "x", function()
      vim.go.operatorfunc = op
      xcount = 1
      vim.api.nvim_feedkeys(reg .. "x", "n", false)
      vim.api.nvim_feedkeys(plug, "m", false)
    end, { desc = "del single char" })
    -- timed out, clear
    map("n", "<Plug>(del-single-char)", function()
      not_repeat = true
      return "g@l"
    end, { expr = true })
    -- x was hit within the timeout
    local cont = function()
      vim.cmd.undojoin()
      xcount = xcount + 1
      vim.api.nvim_feedkeys(reg:upper() .. "x", "n", false)
      vim.api.nvim_feedkeys(plug, "m", false)
    end
    map("n", "<Plug>(del-single-char)x", cont, {})
    map("n", "<Plug>(del-single-char)i", function()
      vim.cmd.undojoin()
      vim.api.nvim_feedkeys("i", "n", false)
    end, {})
  end
  -- TODO: merge d<motion>i to be like c<motion>

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
    {}
  )
  repeatable(
    { "e", "E", "d", "D" },
    "Error",
    { utils.lsp.error_next, utils.lsp.error_prev, utils.lsp.diag_next, utils.lsp.diag_prev },
    {}
  )

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
  -- TODO: maybe indent is more useful
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

  require "hydra" {
    name = "undotree",
    body = "g",
    on_enter = function() vim.cmd.UndotreeShow() end,
    on_exit = function() vim.cmd.UndotreeHide() end,
    config = {
      invoke_on_body = false,
    },
    heads = {
      { "u", "u", { desc = false, private = true } },
      { "<C-r>", "<C-r>", { desc = false, private = true } },
      { "+", "g+", { desc = false } },
      { "-", "g-", { desc = false } },
    },
  }
  -- Close window
  -- TODO: for certain buffer types we can delete the buffer too
  -- unlisted, noname, etc
  map("n", "<c-c>", "<C-w>q", nore)
  map("n", "<c-q>", "<C-w>q", nore)
  map("n", "<c-s-q>", ":wqa", nore)

  -- Search textobject
  map("n", "<leader>*", operatorfunc_keys "*", { desc = "Search (op)", expr = true })

  -- Start search and replace from search
  map("c", "<M-r>", function()
    local mode = vim.fn.getcmdtype()
    if mode == "/" or mode == "?" then
      return [[<cr>:%s/<C-R>///g<Left><Left>]]
    else
      return ""
    end
  end, { expr = true })
  -- Jump between matches without leaving search mode
  map("c", "<M-n>", [[<C-g>]], { silent = true })
  map("c", "<M-S-n>", [[<C-t>]], { silent = true })

  -- Continue the search and keep selecting (equivalent ish to doing `gn` in normal)
  map("x", "n", "<esc>ngn", nore)
  map("x", "N", "<esc>NgN", nore)
  -- Select the current/next search match
  map("x", "gn", "<esc>gn", nore)
  map("x", "gN", "<esc>NNgN", nore) -- current/prev

  -- Escape key clears search and spelling highlights
  -- FIXME: why do you delete yourself??
  map("n", "<esc>", function()
    vim.cmd "nohlsearch"

    vim.o.spell = false

    local ok, notify = pcall(require, "notify")
    if ok then notify.dismiss { pending = true, silent = true } end

    return "<Plug>(double-esc)"
  end, { silent = true, expr = true, remap = true })
  map("i", "<esc>", function()
    vim.cmd.stopinsert()
    feedkeys(t "<esc>", "n")
    feedkeys(t "<Plug>(double-esc)", "n")
    -- vim.cmd.normal { bang = true, "==" } -- Reindent line
  end, sile)
  map("n", "<Plug>(double-esc)<esc>", function()
    -- TODO: close floating windows
    pcall(vim.cmd.write)
    pcall(function() require("blinker").blink_cursorline() end)
  end)

  map("n", "<c-f>", function()
    local wins = vim
      .iter(vim.api.nvim_list_wins())
      :map(function(w)
        local cfg = vim.api.nvim_win_get_config(w)
        cfg.id = w
        vim.print(cfg)
        return cfg
      end)
      :filter(function(w)
        -- TODO: actually compute the position because they may not use cursor
        return w.focusable and w.relative == "cursor"
      end)
      :totable()
    vim.print(wins)
    for _, win in ipairs(wins) do
      if (not win.row or win.row == 0) and (not win.col or win.col == 0) then
        vim.api.nvim_tabpage_set_win(0, win.id)
      end
    end
  end)

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

  M.quick_toggle("<leader>T", "d", utils.lsp.toggle_diagnostics)
  M.quick_toggle("<leader>T", "i", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end)
  M.quick_toggle("<leader>T", "b", "<cmd>ToggleBlame virtual<cr>")

  -- Select last pasted
  -- TODO: use yanky
  map("x", "<leader>vo", "`[o`]", { desc = "Select Last Paste/Op" })
  map("x", "<leader>vO", "V`[o`]", { desc = "SelLine Last Paste/Op" })
  map("x", "<leader>v<C-o>", "<C-v>`[o`]", { desc = "SelBlock Last Paste/Op" })
  map("n", "<leader>vo", "v`[o`]", { desc = "Select Last Paste/Op" })
  map("n", "<leader>vO", "V`[o`]", { desc = "SelLine Last Paste/Op" })
  map("n", "<leader>v<C-o>", "<C-v>`[o`]", { desc = "SelBlock Last Paste/Op" })
  -- Use reselect as an operator
  op_from "<leader>p"
  op_from "<leader>P"
  op_from "<leader><C-p>"

  -- Swap the mark jump keys
  map("n", "<cr>`", "'", nore)
  map("n", "<cr>m", "m", nore)

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
  map("i", "<C-BS>", "<C-g>u<C-w>", nore)

  -- TODO: Use more standard regex syntax
  -- map("n", "/", "/\v", nore)

  -- Split line
  map("n", "<M-a>", "A<cr>")
  -- map("n", "O", "^kA<cr>")
  map("n", "go", "a<cr><ESC>k<cmd>sil! keepp s/\v +$//<cr><cmd>noh<cr>j^", { desc = "Split Line" })
  map("n", "<M-o>", "o<esc>", { remap = true, desc = "Split Line" })
  map("n", "<M-S-o>", "O<esc>", { remap = true, desc = "Split Line" })

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

  -- Select all matchching regex search
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

  -- "better" end and beginning of line
  -- map({ "o", "x" }, "H", "^", { remap = true })
  -- map({ "o", "x" }, "L", "$", { remap = true })
  -- map("x", "H", "^", { remap = true })
  -- map("x", "L", "g_", { remap = true })
  -- map("n", "H", [[col('.') == match(getline('.'),'\S')+1 ? '0' : '^']], norexpr)
  -- map("n", "L", "$", { remap = true })

  map("n", "L", "a<C-l>", { remap = true })

  -- map("n", "m-/", "")

  -- Select whole file
  -- map("o", "ie", "<cmd>normal! mzggVG<cr>`z", nore)
  -- sel_map("ie", "gg0oG$", nore)

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

  map("n", "m", F 'require"which-key".show "m"')

  -- TODO: quickly run short commands
  local short_cmd = require "keymappings.short_cmd"
  map({ "x", "n" }, "'", short_cmd(), { desc = "Short command" })
  map({ "x", "n" }, "!", short_cmd "!", { desc = "Short command" })

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

  map({ "n", "x" }, "=", "gq", { desc = "Format Op" })
  map("n", "==", "gqq", { desc = "Format Line" })
  map({ "n", "x" }, "gq", "=", { desc = "Indent Op" })
  map("n", "gqq", "==", { desc = "Indent Line" })

  map(
    "n",
    "<cr>v",
    function() return require("editor.nav.lib").select_mapping() end,
    { desc = "Visual Select", expr = true }
  )

  require("plugins.git.keys").hydra(nil)

  map("c", "<c-a>", function()
    local line = vim.fn.getcmdline()
    local pos = vim.fn.getcmdpos()
    if line:sub(1, 1) == "%" then
      line = line:sub(2)
      pos = pos - 1
    else
      line = "%" .. line
      pos = pos + 1
    end
    vim.fn.setcmdline(line, pos)
    -- TODO: refresh inccomand
    return "i<bs>"
  end, { expr = true, desc = "Toggle file range" })
  map("c", "<c-v>", function()
    local line = vim.fn.getcmdline()
    local pos = vim.fn.getcmdpos()
    local prefix = "'<,'>"
    if line:sub(1, #prefix) == prefix then
      line = line:sub(#prefix + 1)
      pos = pos - #prefix
    else
      line = prefix .. line
      pos = pos + #prefix
    end
    vim.fn.setcmdline(line, pos)
    -- TODO: refresh inccomand
    return "i<bs>"
  end, { expr = true, desc = "Toggle visual range" })
  -- FIXME: Totally jank
  -- map("ca", "s", function()
  --   if vim.fn.getcmdtype() == ":" then
  --     return "s//g<left><left><left>"
  --   else
  --     return "s"
  --   end
  -- end, { expr = true })

  if false then -- bailing operator pending mode to operator
    for _, k in ipairs { "s", "y", "d", "c", "r", "x", "X", "q", "Q", "u" } do
      map("o", k, function()
        -- TODO: doesnt work for custom operators (r)
        local opkey = vim.v.operator
        feedkeys("<C-\\><C-n>", "n")
        feedkeys("<esc>", "n")
        feedkeys(opkey .. k, "m")
      end, {})
    end
  end

  for _, v in ipairs {
    { "cp", '"+p', mode = "n", desc = "Clipboard p", remap = true },
    { "cP", '"+P', mode = "n", desc = "Clipboard P", remap = true },
    { "<leader>p", '"+P', mode = "x", desc = "Clipboard p", remap = true },
    { "<leader>P", '"+p', mode = "x", desc = "Clipboard P", remap = true },
    { "r+", '"+r', mode = "n", desc = "Clipboard r", remap = true },
    { "r+", '"+rr', mode = "n", desc = "Clipboard rr", remap = true },
    { "cy", '"+y', mode = "n", desc = "Clipboard y", remap = true },
    { "cyy", '"+yy', mode = "n", desc = "Clipboard yy", remap = true },
    { "cY", '"+Y', mode = "n", desc = "Clipboard Y", remap = true },
    { "cd", '"+d', mode = "n", desc = "Clipboard d" },
    { "cdd", '"+dd', mode = "n", desc = "Clipboard dd" },
    { "cD", '"+D', mode = "n", desc = "Clipboard D" },
  } do
    map(v.mode or "n", v[1], v[2], { desc = v.desc, remap = v.remap })
  end
  map("n", "yC", function() vim.fn.setreg("+", vim.fn.getreg(vim.v.register)) end, { desc = "To System Clipboard" })

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
    ["<Space>"] = {
      function()
        if vim.api.nvim_buf_get_name(0) == "" then
          vim.notify("No filename yet, complete in cmdline", vim.log.levels.WARN)
          return ":w "
        else
          return "<cmd>w<cr>"
        end
      end,
      "Write",
      expr = true,
      replace_keycodes = true,
    },
    W = {
      function()
        if vim.api.nvim_buf_get_name(0) == "" then
          vim.notify("No filename yet, complete in cmdline", vim.log.levels.WARN)
          return ":noau w "
        else
          return "<cmd>noau w<cr>"
        end
      end,
      "Write (noau)",
      expr = true,
      replace_keycodes = true,
    }, -- w = { cmd "noau up", "Write" },
    q = { "<cmd>wq<cr>", "Quit" },
    ["<C-q>"] = { "<cmd>wqa<cr>", "Quit All" },
    Q = { function() return pcall(vim.cmd.tabclose) or pcall(vim.cmd.quitall) end, "Quit Tab" },
    e = {
      name = "Edit",
      c = "TextCase",
    },
    o = {
      name = "Open window",
      -- TODO: some of these should be in plugin files
      u = { cmd "UndotreeToggle", "Undo tree" },
      o = { cmd "SymbolsOutline", "Outline" },
      s = {
        name = "Sidebar",
      },
      t = { cmd "Trouble toggle", "Trouble" },
      n = { cmd "Navbuddy", "Navbuddy" },
      q = { utils.quickfix_toggle, "Quick fixes" },
      E = { cmd "!open '%:p:h'", "Open File Explorer" },
      M = { vim.g.goneovim and cmd "GonvimMiniMap" or cmd "MinimapToggle", "Minimap" },
      d = { cmd "DiffviewOpen", "Diffview" },
      H = { cmd "DiffviewFileHistory", "File History Git" },
      N = { cmd "NoiceHistory", "Noice History" },
      g = { cmd "!smerge '%:p:h'", "Sublime Merge" },
      a = { cmd "KittyNew aider --watch-files", "AIder" },
      i = { function() require("ui.win_pick").gf() end, "Open file in <window>" },
      h = { name = "Kitty Hints" },
    },
    m = { name = "Make" },
    x = { name = "Run" },
    P = { name = "Project (Tasks)" },
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
    g = "Git",

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
      F = { utils.lsp.format_all, "Format" },
      c = { lspbuf.signature_help, "Signature Help" },
      C = {
        name = "Calls",
        i = { telescope_cursor "incoming_calls", "Incoming" },
        o = { telescope_cursor "outgoing_calls", "Outgoing" },
        l = { telescope_cursor "subtypes", "Subtypes" },
        u = { telescope_cursor "supertypes", "Supertypes" },
      },
      -- d = { telescope_fn.lsp_definitions, "Definitions" },
      -- D = { lspbuf.decalaration, "Declaration" },
      -- t = { lspbuf.type_definition, "Type Definition" },
      -- r = { telescope_fn.lsp_references, "References" },
      -- i = { telescope_fn.lsp_implementations, "Implementations" },
      -- s = {
      -- name = "View in Split", -- TODO: peek before pick
      d = { telescope_cursor "lsp_definitions", "Definition" },
      D = { telescope_cursor "lsp_declarations", "Declaration" },
      t = { telescope_cursor "lsp_type_definitions", "Type Def" },
      r = { telescope_cursor "lsp_references", "References" },
      i = { telescope_cursor "lsp_implementations", "Implementation" },
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
    },
    s = {
      name = "Search",
      [" "] = { telescope_fn.resume, "Redo last" },
      -- n = { telescope_fn.notify.notify, "Notifications" },
      -- f = { telescope_fn.find_files, "Find File" },
      -- c = { telescope_fn.colorscheme, "Colorscheme" },
      -- TODO: fallback to treesitter
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
      f = {
        function() telescope_fn.grep_string(vim.fn.expand "%") end,
        "Curr word",
      },
      ["/"] = { telescope_fn.grep_last_search, "Last Search" },
      -- ["."] = { [[:%s/<C-R>.//g<Left><Left>]], "Last insert" },
      m = { telescope_fn.marks, "Marks" },
      _ = { ":Telescope ", "Telescope ..." },
      ["<CR>"] = { telescope_fn.builtin, "Telescopes" },
      ["+"] = { [[/<C-R>+<cr>]], "Last clipboard" },
      ["."] = { [[/<C-R>.<cr>]], "Last insert" },
      ['"'] = { [[/<C-R>"<cr>]], "Last cdy" },
    },
    r = {
      name = "Replace/Refactor",
      -- n = { utils.lsp.rename, "Rename" }, -- Use IncRename
      ["/"] = { [[:%s/<C-R>///g<Left><Left>]], "Last search" },
      ["+"] = { [[:%s/<C-R>+//g<Left><Left>]], "Last clipboard" },
      ["."] = { [[:%s/<C-R>.//g<Left><Left>]], "Last insert" },
      ['"'] = { [[:%s/<C-R>"//g<Left><Left>]], "Last cdy" },
      s = { [[:%s///g<Left><Left><Left>]], "Sub In File" },
      i = "Inside",
      g = "Global Replace",
      c = "Rename with TextCase",
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
      b = { cmd "Trouble diagnostics toggle", "Sidebar" },
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
      s = { ":s///g<Left><Left><Left>", "In Selection" },
      -- TODO: I, A versions using substitute.nvim
      ["/"] = { [[:%s/<C-R>///g<Left><Left>]], "Last search" },
      ["+"] = { [[:%s/<C-R>+//g<Left><Left>]], "Last clipboard" },
      ["."] = { [[:%s/<C-R>.//g<Left><Left>]], "Last insert" },
      ['"'] = { [[:%s/<C-R>"//g<Left><Left>]], "Last cdy" },
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

  -- local iLeaderOpts = {
  --   mode = "i",
  --   prefix = "<F1>",
  --   noremap = false,
  -- }
  -- local maps = vim.api.nvim_get_keymap "i"
  -- local iLeaderMappings = {}
  -- for _, m in ipairs(maps) do
  --   -- keymaps starting with '<M-', '<C-'
  --   local mpat = "^<[mMcC]-(%w+)>$"
  --   local _, _, k = m.lhs:find(mpat)
  --   if k and not iLeaderMappings[k] then iLeaderMappings[k] = { m.lhs, m.desc } end
  -- end
  -- wk.register(iLeaderMappings, iLeaderOpts)

  local ops = { mode = "n" }
  wk.register({
    ["z="] = {
      telescope_fn.spell_suggest,
      "Spelling suggestions",
    },
  }, ops)

  -- TODO: register all g prefix keys in whichkey

  require("keymappings.scroll_mode").setup()
  require("keymappings.fold_mode").setup()
  require("keymappings.buffer_mode").setup()

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
function M.quick_toggle(prefix, suffix, callback, name)
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

utils.lsp.on_attach(function(client, bufnr)
  local map = function(mode, lhs, rhs, opts)
    if bufnr then opts.buffer = bufnr end
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- TODO: clean up the goto-* keybindings (faster, better selection of which window)
  map("n", "gd", utils.lsp.view_location_pick "definition", { desc = "Goto Definition" })
  map("n", "gt", utils.lsp.view_location_pick "typeDefinition", { desc = "Goto TypeDefinition" })
  map("n", "gD", utils.lsp.view_location_pick "declaration", { desc = "Goto Declaration" })
  map("n", O.goto_prefix .. "d", utils.lsp.view_location_pick "definition", { desc = "Goto Definition" })
  map("n", O.goto_prefix .. "t", utils.lsp.view_location_pick "typeDefinition", { desc = "Goto TypeDefinition" })
  map("n", O.goto_prefix .. "D", utils.lsp.view_location_pick "declaration", { desc = "Goto Declaration" })
  map("n", O.goto_prefix .. "id", vim.lsp.buf.definition, { desc = "Definition" })
  map("n", O.goto_prefix .. "it", vim.lsp.buf.type_definition, { desc = "TypeDefinition" })
  map("n", O.goto_prefix .. "iD", vim.lsp.buf.declaration, { desc = "Declaration" })
  -- Preview variants -- TODO: preview and then open new window
  map("n", O.goto_prefix .. "r", utils.lsp.view_location_pick "references", { desc = "Goto References" })
  map("n", O.goto_prefix .. "pd", utils.lsp.preview_location_at "definition", { desc = "Peek Definition" }) -- TODO: replace with glance.nvim?
  map("n", O.goto_prefix .. "pt", utils.lsp.preview_location_at "typeDefinition", { desc = "Peek TypeDefinition" })
  map("n", O.goto_prefix .. "pD", utils.lsp.preview_location_at "declaration", { desc = "Peek Declaration" })
  map("n", O.goto_prefix .. "pr", telescope_fn.lsp_references, { desc = "Peek References" })
  map("n", O.goto_prefix .. "pi", telescope_fn.lsp_implementations, { desc = "Peek implementation" })
  map("n", O.goto_prefix .. "pe", utils.lsp.diag_line, { desc = "Diags" })
  map("n", "<M-r>", function()
    -- TODO: use treesitter to detect identifiers
    local new_name = vim.fn.expand "<cword>"
    vim.cmd "undo!"
    vim.lsp.buf.rename(new_name)
  end, { desc = "Rename after" })
  map("i", "<M-r>", "<esc><M-r>", { remap = true, desc = "Rename after" })
  -- Hover
  map({ "x", "n" }, O.hover_key, utils.lsp.repeatable_hover, { desc = "LSP Hover" })
  map("i", "<C-i>", lspbuf.signature_help, { desc = "LSP Signature Help" })
  map("i", "<tab>", "<m-l>", { remap = true }) -- FIXME: i don't like this hardcoding
  map("n", O.action_key, telescope_fn.code_actions_previewed, { desc = "Do Code Action" })
  map("x", O.action_key_vis or O.action_key, telescope_fn.code_actions_previewed, { desc = "Do Code Action" })
  local function quick_code_action(i, name)
    map(
      "n",
      "q" .. i,
      utils.repeatable(
        function()
          telescope_fn.code_actions_previewed {
            context = { only = { name } },
            apply = true,
          }
        end
      ),
      { desc = "Do" .. name }
    )
  end
  quick_code_action("u", "quickfix") -- TODO: collect quickfixes from all diagnostics and let us apply in batches from telescope
  quick_code_action("w", "quickfix") -- TODO: collect quickfixes from all diagnostics and let us apply in batches from telescope
  quick_code_action("i", "refactor.inline")
  quick_code_action("r", "refactor.rewrite")
  quick_code_action("e", "refactor.extract")
  map("n", "qr", "<leader>rn", { desc = "Rename" })

  -- TODO: operators for all the above to use with remote?
  local code_action_op = operatorfunc_keys("<esc>" .. O.action_key, "<Plug>(leap-remote)")
  map("n", "<leader>c", code_action_op, { desc = "Do Code Action At" })
  local quickfix_op = operatorfunc_keys("<esc>" .. "qu", "<Plug>(leap-remote)")
  map("n", "<leader>q", quickfix_op, { desc = "Quickfix" })
end, "lsp_mappings")

-- JUST FYI
M.weird_mappings = {
  { "<BS>", "<C-h>" },
  { "<Tab>", "<C-i>" },
  { "<CR>", "<C-m>" },
  -- {"<NL>", "<C-m>"},
  -- {"<Del>", "<C-m>"},
}

return setmetatable(M, {
  __call = function(tbl, ...) return map(unpack(...)) end,
})

-- m  t (in normal mode maybe?)
-- prefixes
-- c d y r = !
-- suffixes
-- p x o u . ; - =  ! > <
-- v is useful but not
-- op-op combinations
-- visual Y is free
-- normal M is free
