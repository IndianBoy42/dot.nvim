-- TODO: replace all keymaps with functions or something
-- TODO: <[cC][mM][dD]>lua
-- https://github.com/ziontee113/yt-tutorials/tree/nvim_key_combos_in_alacritty_and_kitty
local M = {}

-- Custom nN repeats
local custom_n_repeat = nil
local custom_N_repeat = nil
local nvim_feedkeys = vim.api.nvim_feedkeys
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
local operatorfunc_cvkeys = utils.operatorfunc_cvkeys
local operatorfunc_Vkeys = utils.operatorfunc_Vkeys
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
local keydel = vim.keymap.del
vim.keymap.set = function(mode, lhs, rhs, opts)
  keyset(mode, lhs, rhs, vim.tbl_extend("keep", opts or {}, { silent = true }))
end
vim.keymap.setl = function(mode, lhs, rhs, opts)
  keyset(mode, lhs, rhs, vim.tbl_extend("keep", opts or {}, { buffer = 0, silent = true }))
end
vim.keymap.dell = function(mode, lhs, rhs, opts)
  keydel(mode, lhs, vim.tbl_extend("keep", opts or {}, { buffer = 0, silent = true }))
end
vim.keymap.prefixed = function(prefix)
  return function(mode, lhs, rhs, opts)
    keyset(mode, prefix .. lhs, rhs, vim.tbl_extend("keep", opts or {}, { silent = true }))
  end
end
vim.keymap.prefixedl = function(prefix)
  return function(mode, lhs, rhs, opts)
    keyset(
      mode,
      prefix .. lhs,
      rhs,
      vim.tbl_extend("keep", opts or {}, { buffer = 0, silent = true })
    )
  end
end
vim.keymap.leader = vim.keymap.prefixed "<leader>"
vim.keymap.localleader = vim.keymap.prefixedl "<localleader>"
local mapl = vim.keymap.setl
local map = vim.keymap.set
local norexpr = { noremap = true, silent = true, expr = true }
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
  map("n", "n", M.n_repeat, {})
  map("n", "N", M.N_repeat, {})
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
  -- map("n", "<2-ScrollWheelUp>", "<nop>", {})
  -- map("n", "<2-ScrollWheelDown>", "<nop>", {})
  -- map("n", "<3-ScrollWheelUp>", "<nop>", {})
  -- map("n", "<3-ScrollWheelDown>", "<nop>", {})
  -- map("n", "<4-ScrollWheelUp>", "<nop>", {})
  -- map("n", "<4-ScrollWheelDown>", "<nop>", {})
  -- map("n", "<ScrollWheelUp>", "<C-a>", {})
  -- map("n", "<ScrollWheelDown>", "<C-x>", {})
  map("n", "<C-ScrollWheelUp>", "<C-a>", {})
  map("n", "<C-ScrollWheelDown>", "<C-x>", {})
  map("n", "<C-S-ScrollWheelUp>", cmd "FontUp", {})
  map("n", "<C-S-ScrollWheelDown>", cmd "FontDown", {})
  map("n", "<C-->", cmd "FontDown", {})
  map("n", "<C-+>", cmd "FontUp", {})

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
  map("n", resize_prefix .. "Up>", cmd "resize -2", {})
  map("n", resize_prefix .. "Down>", cmd "resize +2", {})
  map("n", resize_prefix .. "Left>", cmd "vertical resize -2", {})
  map("n", resize_prefix .. "Right>", cmd "vertical resize +2", {})

  -- Keep accidentally hitting J instead of j when first going visual mode
  map("x", "J", "j", {})
  map("x", "<M-j>", "J", {})

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
  map("n", "g<", "<", {})
  map("n", "g>", ">", {})
  map("x", "<", "<gv", {})
  map("x", ">", ">gv", {})

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
  --     map(m, v .. v, "<Nop>", {})
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
  map("x", "<M-p>", "pgv", {}) -- Paste and keep selection

  -- Add meta version that doesn't affect the clipboard
  local function dont_clobber_if_meta(m, c)
    if string.upper(c) == c then
      map(m, "<M-S-" .. string.lower(c) .. ">", '"_' .. c, {})
    else
      map(m, "<M-" .. c .. ">", '"_' .. c, {})
    end
  end

  -- Make the default not touch the clipboard, and add a meta version that does
  local function dont_clobber_by_default(m, c)
    if string.upper(c) == c then
      map(m, "<M-S-" .. string.lower(c) .. ">", c, {})
    else
      map(m, "<M-" .. c .. ">", c, {})
    end
    -- map(m, c, '"_' .. c, {})
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
  -- map("n", O.goto_next .. "d", diag_nN[1], {})
  -- map("n", O.goto_previous .. "d", diag_nN[2], {})
  -- local error_nN = make_nN_pair { utils.lsp.error_next, utils.lsp.error_prev }
  -- map("n", O.goto_next .. "e", error_nN[1], {})
  -- map("n", O.goto_previous .. "e", error_nN[2], {})
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
  -- map("n", O.goto_next .. "r", function() vim.lsp.buf.references(nil, ref_list_next) end, { desc = "Reference" })
  map("n", O.goto_next .. "r", Snacks.words.jump, { desc = "Reference" })
  -- map("n", O.goto_previous .. "r", function() vim.lsp.buf.references(nil, ref_list_prev) end, { desc = "Reference" })
  local impl_n, impl_p = repeatable("i", "Implementation", quickfix_looping, { body = false })
  local impl_list_next, impl_list_prev = on_list_hydra(impl_n, impl_p, quickfix_looping)
  -- TODO: maybe indent is more useful
  map(
    "n",
    O.goto_next .. "i",
    function() vim.lsp.buf.implementation(impl_list_next) end,
    { desc = "Implementation" }
  )
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

  -- Close window
  -- TODO: for certain buffer types we can delete the buffer too
  -- unlisted, noname, etc
  map("n", "<c-c>", "<C-w>q", {})
  map("n", "<c-q>", "<C-w>q", {})
  map("n", "<c-s-q>", ":wqa", {})

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
  end, { expr = true, desc = "and Replace" })
  map("c", "<M-t>", function()
    local mode = vim.fn.getcmdtype()
    if mode == "/" or mode == "?" then
      -- TODO: from flash fuzzy search
      return [[<cr><leader>s/]]
    else
      return ""
    end
  end, { expr = true, remap = true, desc = "to Telescope" })
  -- Jump between matches without leaving search mode

  -- Continue the search and keep selecting (equivalent ish to doing `gn` in normal)
  -- TODO: select the current search match if not selected
  map("x", "n", "<esc>ngn", { expr = true })
  map("x", "N", "<esc>NgN", { expr = true })
  -- Select the current/next search match
  map("x", "gn", "<esc>gn", {})
  map("x", "gN", "<esc>NNgN", {}) -- current/prev

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
  end, {})
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
    map("n", "gb", "<c-o>", {})
  end
  map("n", "<M-h>", "<c-o>", {})
  map("n", "<M-l>", "<c-i>", {})

  Snacks.toggle.diagnostics():map "<leader>Td"
  Hilight_comments():map "<leader>TH"
  Snacks.toggle.inlay_hints():map "<leader>Ti"
  Snacks.toggle({
    name = "Blame",
    get = function() return require("blame").is_open() end,
    set = function(en)
      local alr = require("blame").is_open()
      if alr ~= en then vim.cmd.BlameToggle() end
    end,
  }):map "<leader>Tb"
  Snacks.toggle.option("wrap"):map "<leader>Tw"
  Snacks.toggle.dim():map "<leader>Tz"
  Snacks.toggle.profiler():map "<leader>Tpp"
  Snacks.toggle.profiler_highlights():map "<leader>Tph"
  map(
    "n",
    "<leader>Tps",
    function() Snacks.profiler.scratch() end,
    { desc = "Profiler Scratch Buffer" }
  )
  Snacks.toggle.option("spell"):map "<leader>TS"
  Snacks.toggle.option("cursorcolumn"):map "<leader>Tcc"
  Snacks.toggle.option("signcolumn"):map "<leader>Tcs"
  Snacks.toggle.option("cursorline"):map "<leader>Tcl"
  Snacks.toggle.line_number():map "<leader>Tcn"
  Snacks.toggle
    .option(
      "conceallevel",
      { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }
    )
    :map "<leader>Tn"

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
  map("n", "<cr>`", "'", {})
  map("n", "<cr>m", "m", {})

  -- Spell checking
  -- map("i", "<C-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u", {})

  map("i", "<M-a>", cmd "normal! A", {})
  map("i", "<M-i>", cmd "normal! I", {})

  -- Slightly easier commands
  map({ "n", "x" }, ";", ":", {})
  -- map('c', ';', "<cr>", {})

  -- Add semicolon TODO: make this smarter
  -- map("i", ";;", "<esc>mzA;`z", {})
  -- map("i", "<M-;>", "<C-o>A;", {})
  map("i", "<M-;>", "<C-o>o", {})

  map("i", "<M-r>", "<C-r>", {})
  map("i", "<M-BS>", "<C-g>u<C-w>", {})
  map("i", "<C-BS>", "<C-g>u<C-w>", {})

  -- TODO: Use more standard regex syntax
  -- map("n", "/", "/\v", {})

  -- Split line
  map("n", "<M-a>", "A<cr>")
  -- map("n", "O", "^kA<cr>")
  map("n", "go", "a<cr><ESC>k<cmd>sil! keepp s/\v +$//<cr><cmd>noh<cr>j^", { desc = "Split Line" })
  map("n", "<M-o>", "o<esc>", { remap = true, desc = "Split Line" })
  map("n", "<M-S-o>", "O<esc>", { remap = true, desc = "Split Line" })

  map("n", "gv", "'<v'>", {})
  -- Reselect visual linewise
  map("n", "gV", "'<V'>", {})
  map("x", "gV", "<esc>gV", {})
  -- Reselect visual block wise
  map("n", "g<C-v>", "'<C-v>'>", {})
  map("x", "g<C-v>", "<esc>g<C-v>", {})

  -- stuff
  map({ "n", "x", "o" }, "<c-e>", "ge", {})
  map({ "n", "x", "o" }, "<c-s-e>", "gE", {})

  -- Use reselect as an operator
  op_from "gv"
  op_from "gV"
  op_from "g<C-v>"

  local function undo_brkpt(key)
    -- map("i", key, key .. "<c-g>u", {})
    map("i", key, "<c-g>u" .. key, {})
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
  map("n", "U", "<C-R>", {})

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

  map("n", "L", utils.lsp.diag_line, { remap = true })

  -- map("n", "m-/", "")

  -- Select whole file
  -- map("o", "ie", "<cmd>normal! mzggVG<cr>`z", {})
  -- sel_map("ie", "gg0oG$", {})

  -- Operator for current line
  -- sel_map("il", "g_o^")
  -- sel_map("al", "$o0")

  -- Make change line (cc) preserve indentation
  map("n", "cc", "^cg_", { desc = "Change line" })

  map("x", ".", ":normal .<CR>", {})

  -- -- TODO: make v[hjkl] more like normal
  map("n", "v", operatorfunc_keys "", { expr = true, desc = "v (op)" })
  map("n", "V", operatorfunc_Vkeys "", { expr = true, desc = "V (op)" })
  map("n", "<C-v>", operatorfunc_cvkeys "", { expr = true, desc = "<C-v> (op)" })

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
  map("t", "<ESC>", "<ESC>", {})
  map("t", "<ESC><ESC>", [[<C-\><C-n>]], {})

  -- Leader shortcut for ][ jumping and )( swapping
  map("n", "<leader>j", O.goto_next, { remap = true, desc = "Jump next (])" })
  map("n", "<leader>k", O.goto_previous, { remap = true, desc = "Jump prev ([)" })
  map("n", "<leader>J", O.goto_next_outer, { remap = true, desc = "Jump next outer (]])" })
  map("n", "<leader>K", O.goto_previous_outer, { remap = true, desc = "Jump prev outer ([[)" })
  -- map("n", "<leader>h", ")", { remap = true, desc = "Hop" })

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
  map(
    "n",
    "yC",
    function() vim.fn.setreg("+", vim.fn.getreg(vim.v.register)) end,
    { desc = "To System Clipboard" }
  )

  -- -- Open new line with a count
  -- map("n", "o", function()
  --   local count = vim.v.count
  --   feedkeys("o", "n")
  --   for _ = 1, count do
  --     feedkeys "<CR>"
  --   end
  -- end, {})

  -- Define the new which-key mappings in the updated format
  local leaderMappings = {
    { "<leader>.", function() Snacks.scratch() end, desc = "Scratch buffer" },
    { "<leader>/", telescope_fn.live_grep, desc = "Global search" },
    { "<leader>;", telescope_fn.commands, desc = "Srch Commands" },
    { "<leader><C-q>", "<cmd>wqa<cr>", desc = "Quit All" },
    {
      "<leader><Space>",
      function()
        if vim.api.nvim_buf_get_name(0) == "" then
          vim.notify("No filename yet, complete in cmdline", vim.log.levels.WARN)
          return ":w "
        else
          return "<cmd>w<cr>"
        end
      end,
      desc = "Write",
      expr = true,
      nowait = false,
      remap = false,
      replace_keycodes = true,
      silent = false,
    },
    { "<leader>F", telescope_fn.find_all_files, desc = "Find all Files" },
    {
      "<leader>Q",
      function() return pcall(vim.cmd.tabclose) or pcall(vim.cmd.quitall) end,
      desc = "Quit Tab",
    },

    { "<leader>T", group = "Toggle" },
    { "<leader>Tb", "<cmd>set buflisted<cr>", desc = "buflisted" },

    { "<leader>Tc", group = "Cursor/Column" },

    { "<leader>Tf", group = "Formatting" },
    { "<leader>Tfb", utils.lsp.format_on_save_toggle(vim.b), desc = "Toggle Format on Save" },
    {
      "<leader>Tfg",
      utils.lsp.format_on_save_toggle(vim.g),
      desc = "Toggle Format on Save (Global)",
    },
    {
      "<leader>Tfmb",
      function() vim.b.Format_on_save_mode = "mod" end,
      desc = "Format Mods on Save",
    },
    {
      "<leader>Tfmg",
      function() vim.g.Format_on_save_mode = "mod" end,
      desc = "Format Mods on Save (Global)",
    },
    { "<leader>Th", "<cmd>setlocal hlsearch<cr>", desc = "hlsearch" },

    { "<leader>Tp", group = "Profiling" },
    { "<leader>Tv", "<cmd>NvimContextVtToggle<cr>", desc = "Context VT" },
    {
      "<leader>W",
      function()
        if vim.api.nvim_buf_get_name(0) == "" then
          vim.notify("No filename yet, complete in cmdline", vim.log.levels.WARN)
          return ":noau w "
        else
          return "<cmd>noau w<cr>"
        end
      end,
      desc = "Write (noau)",
      expr = true,
      nowait = false,
      remap = false,
      replace_keycodes = true,
      silent = false,
    },
    { "<leader>b", desc = "+Buffers" },

    { "<leader>d", group = "Diagnostics/Debug" },
    { "<leader>dL", utils.lsp.toggle_diag_vlines, desc = "Toggle VLines" },
    { "<leader>db", "<cmd>Trouble diagnostics toggle<cr>", desc = "Sidebar" },
    { "<leader>dj", utils.lsp.diag_next, desc = "Next" },
    { "<leader>dk", utils.lsp.diag_prev, desc = "Prev" },
    { "<leader>dl", utils.lsp.diag_line, desc = "Line Diagnostics" },
    { "<leader>ds", telescope_fn.diagnostics, desc = "Document Diagnostics" },
    { "<leader>dw", telescope_fn.workspace_diagnostics, desc = "Workspace Diagnostics" },

    { "<leader>e", group = "Edit" },
    { "<leader>ec", desc = "TextCase" },
    { "<leader>f", telescope_fn.smart_open, desc = "Smart Open File" },
    { "<leader>g", desc = "Git" },

    { "<leader>i", group = "Info" },
    { "<leader>ii", "<cmd>Mason<cr>", desc = "LspInstall" },
    { "<leader>il", "<cmd>LspInfo<cr>", desc = "LSP" },
    { "<leader>in", "<cmd>NullLsInfo<cr>", desc = "Null-ls" },
    { "<leader>ip", "<cmd>Lazy<cr>", desc = "Lazy plugins" },
    { "<leader>it", "<cmd>TSConfigInfo<cr>", desc = "Treesitter" },

    { "<leader>l", group = "LSP" },

    { "<leader>lC", group = "Calls" },
    { "<leader>lCi", telescope_cursor "incoming_calls", desc = "Incoming" },
    { "<leader>lCl", telescope_cursor "subtypes", desc = "Subtypes" },
    { "<leader>lCo", telescope_cursor "outgoing_calls", desc = "Outgoing" },
    { "<leader>lCu", telescope_cursor "supertypes", desc = "Supertypes" },
    { "<leader>lD", telescope_cursor "lsp_declarations", desc = "Declaration" },
    { "<leader>lF", utils.lsp.format_all, desc = "Format" },
    { "<leader>la", telescope_fn.code_actions_previewed, desc = "Code Action (K)" },
    { "<leader>lc", lspbuf.signature_help, desc = "Signature Help" },
    { "<leader>ld", telescope_cursor "lsp_definitions", desc = "Definition" },
    { "<leader>lf", utils.lsp.format, desc = "Format" },
    { "<leader>lh", lspbuf.hover, desc = "Hover (H)" },
    { "<leader>li", telescope_cursor "lsp_implementations", desc = "Implementation" },
    { "<leader>lk", vim.lsp.codelens.run, desc = "Run Code Lens (gK)" },

    { "<leader>lp", group = "Peek in Float" },
    { "<leader>lpD", utils.lsp.preview_location_at "declaration", desc = "Declaration" },
    { "<leader>lpd", utils.lsp.preview_location_at "definition", desc = "Definition" },
    { "<leader>lpe", utils.lsp.diag_line, desc = "Diagnostics" },
    { "<leader>lpi", telescope_fn.lsp_implementations, desc = "Implementation" },
    { "<leader>lpr", telescope_fn.lsp_references, desc = "References" },
    { "<leader>lpt", utils.lsp.preview_location_at "typeDefinition", desc = "Type Def" },
    { "<leader>lr", telescope_cursor "lsp_references", desc = "References" },
    { "<leader>lt", telescope_cursor "lsp_type_definitions", desc = "Type Def" },

    { "<leader>m", group = "Make" },

    { "<leader>n", group = "Generate" },
    { "<leader>nF", "<cmd>Neogen file<cr>", desc = "File Doc" },

    { "<leader>nb", group = "Comment Box" },
    { "<leader>nc", "<cmd>Neogen class<cr>", desc = "Class Doc" },
    { "<leader>nf", "<cmd>Neogen func<cr>", desc = "Func Doc" },
    { "<leader>nn", "<cmd>Neogen<cr>", desc = "Gen Doc" },
    { "<leader>nt", "<cmd>Neogen type<cr>", desc = "type Doc" },

    { "<leader>o", group = "Open window" },
    { "<leader>oE", "<cmd>!open '%:p:h'<cr>", desc = "Open File Explorer" },
    { "<leader>oH", "<cmd>DiffviewFileHistory<cr>", desc = "File History Git" },
    { "<leader>oM", "<cmd>MinimapToggle<cr>", desc = "Minimap" },
    { "<leader>oN", "<cmd>NoiceHistory<cr>", desc = "Noice History" },
    { "<leader>oa", "<cmd>KittyNew aider --watch-files<cr>", desc = "AIder" },
    { "<leader>oc", "<cmd>Codeium Chat<cr>", desc = "Codeium Chat" },
    { "<leader>od", "<cmd>DiffviewOpen<cr>", desc = "Diffview" },
    { "<leader>og", "<cmd>!smerge '%:p:h'<cr>", desc = "Sublime Merge" },

    { "<leader>oh", group = "Kitty Hints" },
    { "<leader>oi", function() require("ui.win_pick").gf() end, desc = "Open file in <window>" },
    { "<leader>on", "<cmd>Navbuddy<cr>", desc = "Navbuddy" },
    { "<leader>oo", "<cmd>SymbolsOutline<cr>", desc = "Outline" },
    { "<leader>oq", utils.quickfix_toggle, desc = "Quick fixes" },

    { "<leader>os", group = "Sidebar" },
    { "<leader>ot", "<cmd>Trouble toggle<cr>", desc = "Trouble" },
    { "<leader>q", "<cmd>wq<cr>", desc = "Quit" },

    { "<leader>r", group = "Replace/Refactor" },
    -- TODO: fuck these, just use vim-visual-multi?
    { '<leader>r"', ':%s/<C-R>"//g<Left><Left>', desc = "Last cdy" },
    { "<leader>r+", ":%s/<C-R>+//g<Left><Left>", desc = "Last clipboard" },
    { "<leader>r.", ":%s/<C-R>.//g<Left><Left>", desc = "Last insert" },
    { "<leader>r/", ":%s/<C-R>///g<Left><Left>", desc = "Last search" },
    { "<leader>rc", desc = "Rename with TextCase" },
    { "<leader>rg", desc = "Global Replace" },
    { "<leader>ri", desc = "Inside" },
    { "<leader>rs", ":%s///g<Left><Left><Left>", desc = "Sub In File" },

    { "<leader>s", group = "Search" },
    { "<leader>s ", telescope_fn.resume, desc = "Redo last" },
    { '<leader>s"', '/<C-R>"<cr>', desc = "Last cdy" },
    { "<leader>s*", telescope_fn.grep_string, desc = "Curr word" },
    { "<leader>s+", "/<C-R>+<cr>", desc = "Last clipboard" },
    { "<leader>s.", "/<C-R>.<cr>", desc = "Last insert" },
    { "<leader>s/", telescope_fn.grep_last_search, desc = "Last Search" },
    { "<leader>s;", telescope_fn.command_history, desc = "Command History" },
    { "<leader>s<CR>", telescope_fn.builtin, desc = "Telescopes" },
    { "<leader>sD", telescope_fn.workspace_diagnostics, desc = "Workspace Diagnostics" },
    { "<leader>sM", telescope_fn.man_pages, desc = "Man Pages" },
    { "<leader>sN", telescope_fn.treesitter, desc = "Treesitter Nodes" },
    { "<leader>sT", telescope_fn.live_grep_all, desc = "Text (ALL)" },
    { "<leader>s_", ":Telescope ", desc = "Telescope ..." },
    { "<leader>sb", telescope_fn.buffers, desc = "Buffers" },
    { "<leader>sc", telescope_fn.commands, desc = "Commands" },
    { "<leader>sd", telescope_fn.diagnostics, desc = "Document Diagnostics" },
    { "<leader>sf", telescope_fn.current_buffer_fuzzy_find, desc = "Fuzzy buffer" },
    { "<leader>sh", telescope_fn.help_tags, desc = "Find Help" },
    { "<leader>sj", telescope_fn.jumplist, desc = "Jump List" },
    { "<leader>sk", telescope_fn.keymaps, desc = "Keymappings" },
    { "<leader>sm", telescope_fn.marks, desc = "Marks" },
    { "<leader>so", "<cmd>TodoTelescope<cr>", desc = "TODOs search" },
    { "<leader>sq", telescope_fn.quickfix, desc = "Quickfix" },
    { "<leader>ss", telescope_fn.lsp_document_symbols, desc = "Document Symbols" },
    { "<leader>st", telescope_fn.live_grep, desc = "Text" },
    { "<leader>su", "<cmd>Telescope undo<cr>", desc = "Telescope Undo" },
    { "<leader>sw", telescope_fn.lsp_dynamic_workspace_symbols, desc = "Workspace Symbols" },

    { "<leader>u", group = "(un) Clear" },
    { "<leader>uh", "<cmd>nohlsearch<cr>", desc = "Search Highlight" },
    { "<leader>uw", utils.close_all_floats, desc = "Close all Floats" },

    { "<leader>v", group = "Visualize" },

    { "<leader>x", group = "Run" },
  }

  local vLeaderMappings = {
    {
      mode = { "v" },
      { "<leader>*", telescope_fn.grep_string, desc = "Curr selection" },

      { "<leader>D", group = "Debug" },

      { "<leader>e", group = "Edit" },

      { "<leader>l", group = "LSP" },
      { "<leader>la", telescope_fn.code_actions_previewed, desc = "Code Actions" },
      { "<leader>ld", utils.lsp.range_diagnostics, desc = "Range Diagnostics" },
      { "<leader>lf", utils.lsp.format, desc = "Format" },
      -- TODO: fuck these, just use vim-visual-multi?

      { "<leader>r", group = "Replace/Refactor" },
      { '<leader>r"', ':%s/<C-R>"//g<Left><Left>', desc = "Last cdy" },
      { "<leader>r+", ":%s/<C-R>+//g<Left><Left>", desc = "Last clipboard" },
      { "<leader>r.", ":%s/<C-R>.//g<Left><Left>", desc = "Last insert" },
      { "<leader>r/", ":%s/<C-R>///g<Left><Left>", desc = "Last search" },
      { "<leader>rs", ":s///g<Left><Left><Left>", desc = "In Selection" },
    },
  }

  wk.add(leaderMappings)
  wk.add(vLeaderMappings)

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

  map("n", "z=", telescope_fn.spell_suggest, { desc = "Spelling suggestions" })

  -- TODO: register all g prefix keys in whichkey

  require("keymappings.scroll_mode").setup()
  require("keymappings.fold_mode").setup()
  require("keymappings.buffer_mode").setup()

  -- FIXME: duplicate entries for some of the operators
end

local mincount = 5
function M.wrapjk()
  map(
    { "n", "x" },
    "j",
    [[v:count ? (v:count > ]] .. mincount .. [[ ? "m'" . v:count : '') . 'j' : 'gj']],
    norexpr
  )
  map(
    { "n", "x" },
    "k",
    [[v:count ? (v:count > ]] .. mincount .. [[ ? "m'" . v:count : '') . 'k' : 'gk']],
    norexpr
  )
end

function M.countjk()
  map("n", "j", [[(v:count > ]] .. mincount .. [[ ? "m'" . v:count : '') . 'j']], norexpr)
  map("n", "k", [[(v:count > ]] .. mincount .. [[ ? "m'" . v:count : '') . 'k']], norexpr)
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
  map(
    "n",
    O.goto_prefix .. "d",
    utils.lsp.view_location_pick "definition",
    { desc = "Goto Definition" }
  )
  map(
    "n",
    O.goto_prefix .. "t",
    utils.lsp.view_location_pick "typeDefinition",
    { desc = "Goto TypeDefinition" }
  )
  map(
    "n",
    O.goto_prefix .. "D",
    utils.lsp.view_location_pick "declaration",
    { desc = "Goto Declaration" }
  )
  map("n", O.goto_prefix .. "id", vim.lsp.buf.definition, { desc = "Definition" })
  map("n", O.goto_prefix .. "it", vim.lsp.buf.type_definition, { desc = "TypeDefinition" })
  map("n", O.goto_prefix .. "iD", vim.lsp.buf.declaration, { desc = "Declaration" })
  -- Preview variants -- TODO: preview and then open new window
  map(
    "n",
    O.goto_prefix .. "r",
    utils.lsp.view_location_pick "references",
    { desc = "Goto References" }
  )
  map(
    "n",
    O.goto_prefix .. "pd",
    utils.lsp.preview_location_at "definition",
    { desc = "Peek Definition" }
  ) -- TODO: replace with glance.nvim?
  map(
    "n",
    O.goto_prefix .. "pt",
    utils.lsp.preview_location_at "typeDefinition",
    { desc = "Peek TypeDefinition" }
  )
  map(
    "n",
    O.goto_prefix .. "pD",
    utils.lsp.preview_location_at "declaration",
    { desc = "Peek Declaration" }
  )
  map("n", O.goto_prefix .. "pr", telescope_fn.lsp_references, { desc = "Peek References" })
  map(
    "n",
    O.goto_prefix .. "pi",
    telescope_fn.lsp_implementations,
    { desc = "Peek implementation" }
  )
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
  map(
    "x",
    O.action_key_vis or O.action_key,
    telescope_fn.code_actions_previewed,
    { desc = "Do Code Action" }
  )
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
  map(
    "n",
    "<leader>K",
    function() require("leap.remote").action { input = O.action_key } end,
    { desc = "Remote Code Action" }
  )
  map(
    "n",
    "<leader>q",
    function() require("leap.remote").action { input = "qu" } end,
    { desc = "Remote Quickfix" }
  )
  map(
    "n",
    "<leader>H",
    function() require("leap.remote").action { input = "H" } end,
    { desc = "Remote Hover" }
  )
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
-- normal M is free
-- normal S is free
