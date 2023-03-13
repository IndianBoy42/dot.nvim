-- TODO: replace all keymaps with functions or something
-- TODO: <[cC][mM][dD]>lua
-- https://github.com/ziontee113/yt-tutorials/tree/nvim_key_combos_in_alacritty_and_kitty
local M = {}
local map = vim.keymap.set

-- Custom nN repeats
local custom_n_repeat = nil
local custom_N_repeat = nil
local feedkeys_ = vim.api.nvim_feedkeys
local termcode = vim.api.nvim_replace_termcodes
local function feedkeys(keys, o)
  if o == nil then
    o = "m"
  end
  feedkeys_(termcode(keys, true, true, true), o, false)
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
  custom_n_repeat = nN[1]
  custom_N_repeat = nN[2]
end

M.register_nN_repeat = register_nN_repeat

-- Helper functions
local cmd = require("utils").cmd
local luareq = cmd.require
local gitsigns_fn = luareq "gitsigns"
local telescope_fn = require "telescopes"
local focus_fn = luareq "focus"
local lspbuf = vim.lsp.buf
local lsputil = require "utils.lsp"
local operatorfunc_scaffold = require("utils").operatorfunc_scaffold
local operatorfunc_keys = require("utils").operatorfunc_keys
local operatorfuncV_keys = require("utils").operatorfuncV_keys
local function make_nN_pair(pair, pre_action)
  return {
    function()
      vim.cmd [[normal! m']]
      if pre_action then
        pre_action[1]()
        if pre_action[3] then
          pre_action[3]()
        end
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
        if pre_action[3] then
          pre_action[3]()
        end
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
  if opts == nil then
    opts = nore
  end
  if rhs == nil then
    rhs = lhs
  end

  map("o", lhs, "<cmd>normal v" .. rhs .. "<cr>", opts)
end

M.op_from = op_from
local function sel_map(lhs, rhs, opts)
  if opts == nil then
    opts = nore
  end
  map("x", lhs, rhs, opts)
  op_from(lhs, rhs, opts)
end

M.sel_map = sel_map

function M.sile(mode, from, to)
  map(mode, from, to, sile)
end

function M.nore(mode, from, to)
  map(mode, from, to, nore)
end

function M.expr(mode, from, to)
  map(mode, from, to, expr)
end

function M.norexpr(mode, from, to)
  map(mode, from, to, norexpr)
end

function M.setup()
  local wk = require "which-key"

  -- Make CTRL-i work separate to <TAB>
  if vim.env.TERM == "xterm-kitty" then
    vim.cmd [[autocmd UIEnter * if v:event.chan ==# 0 | call chansend(v:stderr, "\x1b[>1u") | endif]]
    vim.cmd [[autocmd UILeave * if v:event.chan ==# 0 | call chansend(v:stderr, "\x1b[<1u") | endif]]
  end

  -- Free keys for reference
  map("n", "<C-p>", "<NOP>", {})
  -- map("n", "<C-o>", "<NOP>", {})

  -- custom_n_repeat
  map("n", "n", M.n_repeat, nore)
  map("n", "N", M.N_repeat, nore)
  local function srchrpt(k, op)
    return function()
      register_nN_repeat { nil, nil }
      feedkeys(k, op or "n")
    end
  end

  map("n", "/", srchrpt "/", nore)
  map("n", "?", srchrpt "?", nore)
  map("n", "*", srchrpt("viw*", "m"), nore) -- Swap g* and *
  map("n", "#", srchrpt("viw#", "m"), nore)
  map("n", "g*", srchrpt "*", { desc = "Search cword whole" })
  map("n", "g#", srchrpt "#", { desc = "Search cword whole" })
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
  map("c", "<C-v>", "'<,'>")

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
  map("n", "+", "<C-a>", sile) -- recursive so we get dial.nvim
  map("n", "-", "<C-x>", sile)
  map("x", "+", "g<C-a>", sile)
  map("x", "-", "g<C-x>", sile)

  map("t", "<Esc>", [[<C-\><C-n>]], nore)
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
  if vim.fn.has "mac" == 1 then
    resize_prefix = "<M-"
  end
  map("n", resize_prefix .. "Up>", cmd "resize -2", sile)
  map("n", resize_prefix .. "Down>", cmd "resize +2", sile)
  map("n", resize_prefix .. "Left>", cmd "vertical resize -2", sile)
  map("n", resize_prefix .. "Right>", cmd "vertical resize +2", sile)

  -- Keep accidentally hitting J instead of j when first going visual mode
  map("x", "J", "j", nore)
  map("x", "gJ", "J", nore)

  -- better indenting
  -- FIXME: broken with autosession??
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufReadPost", "BufNewFile" }, {
    pattern = "*",
    callback = function()
      -- print "Setting up better indenting"
      mapl("n", ">", ">>", { nowait = true })
      mapl("n", "<", "<<", { nowait = true })
    end,
    -- group = vim.api.nvim_create_augroup("_better_indent", {}),
  })
  -- utils.augroup("_better_indent").FileType = function()
  --   mapl("n", ">", ">>", { nowait = true })
  --   mapl("n", "<", "<<", { nowait = true })
  -- end
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
  map("n", "<S-tab>", cmd "bnext", nore)

  -- Preserve register on pasting in visual mode
  -- TODO: use the correct register
  map("x", "p", "pgvy", nore)
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
    map(m, c, '"_' .. c, nore)
  end

  dont_clobber_if_meta("n", "d")
  dont_clobber_if_meta("n", "D")
  dont_clobber_if_meta("x", "r")
  dont_clobber_by_default("n", "c")
  dont_clobber_by_default("x", "c")
  dont_clobber_by_default("n", "C")
  dont_clobber_by_default("n", "x")
  dont_clobber_by_default("x", "x")

  -- Preserve cursor on yank in visual mode
  -- TODO: use register argument
  map("x", "y", "myy`y", nore)
  map("x", "Y", "myY`y", nore) -- copy linewise
  map("x", "<M-y>", "y", nore)

  map("n", "<M-p>", [[<cmd>call setreg('p', getreg('+'), 'c')<cr>"pp]], nore) -- charwise paste
  -- map("n", "<M-S-C-P>", [[<cmd>call setreg('p', getreg('+'), 'c')<cr>"pP]], nore) -- charwise paste
  -- map("n", "<M-S-p>", [[<cmd>call setreg('p', getreg('+'), 'l')<cr>"pp]], nore) -- linewise paste

  -- Charwise visual select line
  map("x", "v", "^og_", nore)
  map("x", "V", "0o$", nore)

  -- move along visual lines, not numbered ones
  -- without interferring with {count}<down|up>
  map("n", "<up>", "v:count == 0 ? 'gk' : '<up>'", norexpr)
  map("x", "<up>", "v:count == 0 ? 'gk' : '<up>'", norexpr)
  map("n", "<down>", "v:count == 0 ? 'gj' : '<down>'", norexpr)
  map("x", "<down>", "v:count == 0 ? 'gj' : '<down>'", norexpr)

  local pre_goto_next = O.treesitter.textobj_prefixes.goto_next
  local pre_goto_prev = O.treesitter.textobj_prefixes.goto_previous
  local pre_swap_next = O.treesitter.textobj_prefixes.swap_next
  local pre_swap_prev = O.treesitter.textobj_prefixes.swap_prev

  -- QuickFix
  -- local quickfix_looping =
  --   { cmd "try | cnext | catch | cfirst | catch | endtry", cmd "try | cprev | catch | clast | catch | endtry" }
  local quickfix_looping = {
    function()
      local ok, _ = pcall(vim.cmd.cafter)
      if ok then
        return
      end
      local ok, _ = pcall(vim.cmd.cnext)
      if ok then
        return
      end
      vim.cmd.cfirst()
    end,
    function()
      local ok, _ = pcall(vim.cmd.cbefore)
      if ok then
        return
      end
      local ok, _ = pcall(vim.cmd.cprev)
      if ok then
        return
      end
      vim.cmd.clast()
    end,
  }
  local loclist_looping = {
    function()
      local ok, _ = pcall(vim.cmd.lafter)
      if ok then
        return
      end
      local ok, _ = pcall(vim.cmd.lnext)
      if ok then
        return
      end
      vim.cmd.lfirst()
    end,
    function()
      local ok, _ = pcall(vim.cmd.lbefore)
      if ok then
        return
      end
      local ok, _ = pcall(vim.cmd.lprev)
      if ok then
        return
      end
      vim.cmd.llast()
    end,
  }
  local quickfix_nN = make_nN_pair(quickfix_looping)
  map("n", pre_goto_next .. "q", quickfix_nN[1], nore)
  map("n", pre_goto_prev .. "q", quickfix_nN[2], nore)
  local loclist_nN = make_nN_pair(loclist_looping)
  map("n", pre_goto_next .. "l", loclist_nN[1], nore)
  map("n", pre_goto_prev .. "l", loclist_nN[2], nore)

  -- Diagnostics jumps
  local diag_nN = make_nN_pair { lsputil.diag_next, lsputil.diag_prev }
  map("n", pre_goto_next .. "d", diag_nN[1], nore)
  map("n", pre_goto_prev .. "d", diag_nN[2], nore)
  local error_nN = make_nN_pair { lsputil.error_next, lsputil.error_prev }
  map("n", pre_goto_next .. "e", error_nN[1], nore)
  map("n", pre_goto_prev .. "e", error_nN[2], nore)

  -- local usage_nN = make_nN_pair {
  --   require("nvim-treesitter-refactor.navigation").goto_next_usage,
  --   require("nvim-treesitter-refactor.navigation").goto_previous_usage,
  -- }
  -- map("n", pre_goto_next .. "u", usage_nN[1], nore)
  -- map("n", pre_goto_prev .. "u", usage_nN[2], nore)

  local para_nN = make_nN_pair { "}", "{" }
  map("n", pre_goto_next .. "p", para_nN[1], nore)
  map("n", pre_goto_prev .. "p", para_nN[2], nore)

  local jumps = {
    d = "Diagnostics",
    e = "Errors",
    q = "QuickFix",
    l = "Loc List",
    g = "Git Hunk",
    u = "Usage",
    p = "Paragraph",
  }
  wk.register({
    ["]"] = jumps,
    ["["] = jumps,
  }, M.wkopts)

  local function undotree(body)
    require "hydra" {
      name = "undotree",
      body = body,
      on_enter = function()
        vim.cmd.UndotreeShow()
      end,
      on_exit = function()
        vim.cmd.UndotreeHide()
      end,
      config = { invoke_on_body = true },
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
  map("n", "gq", "<C-w>q", nore)
  map("n", "<c-q>", "<C-w>q", nore)
  map("n", "<c-s-q>", ":wqa", nore)
  map("n", "<c-w>d", cmd "bdelete!", nore)

  map("n", "zz", "za", nore)
  map("n", "==", "zz", { desc = "Center this Line" })
  map("n", "=_", "zb", { desc = "Bottom this Line" })
  map("n", "=^", "zt", { desc = "Top this Line" })

  -- Search for the current selection
  map("x", "*", srchrpt '"zy/<C-R>z<cr>', nore) -- Search for the current selection
  map("n", "<leader>*", operatorfunc_keys("searchbwd_for", "*"), { desc = "Search (op)" }) -- Search textobject
  map("x", "#", srchrpt '"zy?<C-R>z<cr>', nore) -- Backwards
  map("n", "<leader>#", operatorfunc_keys("search_for", "#"), { desc = "^Search (op)" })

  -- Search for the current yank register
  map("n", "+", [[/<C-R>+<cr>]], {})
  sel_map("+", "`[o`]")

  -- Search for last edited text
  map("n", 'g"', [[/\V<C-r>"<CR>]], { desc = "Search for last cdy" })
  -- map("x", 'g"', [[:keepjumps normal! /\V<C-r>"<CR>gn]])
  map("x", 'g"', '<ESC>g"gn', { remap = true, desc = "Search for last cdy" })

  -- Start search and replace from search
  map("c", "<M-r>", [[<cr>:%s/<C-R>///g<Left><Left>]], {})

  -- Continue the search and keep selecting (equivalent ish to doing `gn` in normal)
  map("x", "n", "<esc>ngn", nore)
  map("x", "N", "<esc>NgN", nore)
  -- Select the current/next search match
  map("x", "gn", "<esc>gn", nore)
  map("x", "gN", "<esc>NNgN", nore) -- current/prev

  -- Double Escape key clears search and spelling highlights
  map("n", "<ESC>", function()
    vim.cmd "nohls"
    vim.o.spell = false
    require("notify").dismiss { silent = true }
  end, sile)

  -- Map `cp` to `xp` (transpose two adjacent chars)
  -- as a **repeatable action** with `.`
  -- (since the `@=` trick doesn't work
  -- nmap cp @='xp'<cr>
  -- http://vimcasts.org/transcripts/61/en/
  map("n", "<Plug>TransposeCharacters", [[xp<cmd>call repeat#set("\<Plug>TransposeCharacters")<cr>]], nore)
  map("n", "cp", "<Plug>TransposeCharacters", {})
  -- Make xp repeatable
  -- map("n", "xp", "<Plug>TransposeCharacters", {})

  -- Go Back
  if false then
    require "hydra" {
      name = "Jumplist",
      body = "g",
      mode = "n",
      -- FIXME: glitchy because it doesn't redraw
      config = {
        on_key = function()
          -- Preserve animation
          vim.wait(200, function()
            vim.cmd "redraw!"
          end, 30, false)
        end,
      },
      heads = {
        {
          "b",
          function()
            feedkeys("<c-o>", "n")
            -- vim.cmd.normal { "<c-o>", bang = true }
            -- vim.cmd.redraw { bang = true }
          end,
          { desc = "Go Back" },
        },
        {
          "f",
          function()
            feedkeys("<c-i>", "n")
            -- vim.cmd.normal { "<c-i>", bang = true }
            -- vim.cmd.redraw { bang = true }
          end,
          { desc = "Go Forward" },
        },
        { "q", nil, { exit = true } },
        { "<ESC>", nil, { exit = true } },
      },
    }
  else
    map("n", "gb", "<c-o>", nore)
  end
  -- map("n", "<c-o>", "<c-o>", nore)
  -- map("n", "<c-i>", "<c-i>", nore)

  -- -- Commenting helpers
  -- map("n", "gcO", "O-<esc>gccA<BS>", sile)
  -- map("n", "gco", "o-<esc>gccA<BS>", sile)

  -- Select last pasted
  map("n", "gp", "`[v`]", { desc = "Select Last Paste" })
  map("x", "gp", "<esc>gp", { desc = "Select Last Paste" })
  map("n", "gP", "`[V`]", { desc = "SelLine Last Paste" })
  map("x", "gP", "<esc>gP", { desc = "SelLine Last Paste" })
  map("n", "g<C-p>", "`[<C-v>`]", { desc = "SelBlock Last Paste" })
  map("x", "g<C-p>", "<esc>g<C-p>", { desc = "SelBlock Last Paste" })
  -- Use reselect as an operator
  op_from "gp"
  op_from "gP"
  op_from "g<C-p>"

  -- comment and copy
  -- map("x", "gy", '"z<M-y>gvgc`>"zp`[', sile)
  map("x", "gy", '"z<M-y>mz`<"zPgPgc`z', { desc = "copy and comment" })
  map("n", "gy", operatorfuncV_keys("comment_copy", "gy"), sile)
  -- map("n", "gyy", "Vgy", sile)

  -- Swap the mark jump keys
  map("n", "'", "`", nore)
  map("n", "`", "'", nore)

  -- Spell checking
  -- map("i", "<C-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u", nore)

  map("i", "<M-a>", cmd "normal! A", nore)
  map("i", "<M-i>", cmd "normal! I", nore)

  -- Slightly easier commands
  map("n", ";", ":", {})
  map("x", ";", ":", {})
  -- map('c', ';', "<cr>", sile)

  -- Add semicolon
  -- map("i", ";;", "<esc>mzA;`z", nore)
  map("i", ";;", "<esc>A;", nore)

  -- lsp keys
  local telescope_cursor = function(name)
    return function()
      return telescope_fn[name](require("telescope.themes").get_cursor())
    end
  end
  local goto_defn = telescope_cursor "lsp_definitions"
  map("n", "gd", goto_defn, { desc = "Goto Definition" })
  map("n", "gD", lspbuf.declaration, { desc = "Goto Declaration" })
  map("n", "gK", vim.lsp.codelens.run, { desc = "Codelens" })
  -- Preview variants
  map("n", "gpd", lsputil.preview_location_at "definition", sile)
  map("n", "gpD", lsputil.preview_location_at "declaration", sile)
  map("n", "gpr", lsputil.preview_location_at "references", sile)
  map("n", "gpi", lsputil.preview_location_at "implementation", sile)
  map("n", "gpe", lsputil.diag_line, sile)
  local on_list_next = {
    reuse_win = true,
    on_list = function(options)
      vim.fn.setqflist({}, " ", options)
      utils.dump(options)
      if #options.items > 1 then
        register_nN_repeat(quickfix_looping)
      end
      -- vim.cmd.cfirst()
      quickfix_looping[1]()
    end,
  }
  local on_list_prev = {
    reuse_win = true,
    on_list = function(options)
      vim.fn.setqflist({}, " ", options)
      utils.dump(options)
      if #options.items > 1 then
        register_nN_repeat(quickfix_looping)
      end
      -- vim.cmd.clast()
      quickfix_looping[2]()
    end,
  }
  map("n", pre_goto_next .. "u", function()
    vim.lsp.buf.references(nil, on_list_next)
  end, { desc = "Reference" })
  map("n", pre_goto_prev .. "u", function()
    vim.lsp.buf.references(nil, on_list_prev)
  end, { desc = "Reference" })
  map("n", "]i", function()
    vim.lsp.buf.implementation(on_list_next)
  end, { desc = "Next Implementation" })
  map("n", "[i", function()
    vim.lsp.buf.implementation(on_list_prev)
  end, { desc = "Prev Implementation" })
  map("n", "gd", function()
    vim.lsp.buf.definition(on_list_next)
  end, { desc = "Definition" })
  map("n", "gtd", function()
    vim.lsp.buf.definition(on_list_next)
  end, { desc = "Type Definition" })
  -- Hover
  -- map("n", "K", lspbuf.hover, sile)
  map("n", "gh", lspbuf.hover, { desc = "LSP Hover" })
  local do_code_action = telescope_fn.code_actions_previewed
  map("n", "K", do_code_action, { desc = "Do Code Action" })
  map("x", "K", do_code_action, { desc = "Do Code Action" })

  -- Formatting keymaps
  map("n", "gq", lsputil.format_range_operator, { desc = "Format Range" })
  map("x", "gq", lsputil.format, { desc = "Format Range" })
  map("n", "gf", function()
    lsputil.format { async = true }
  end, { desc = "Format Async" })

  -- TODO: Use more standard regex syntax
  -- map("n", "/", "/\v", nore)

  -- Open a new line in normal mode
  map("n", "<M-cr>", "o<esc>", nore)
  map("n", "<M-S-cr>", "O<esc>", nore)

  -- Split line
  map("n", "go", "i<cr><ESC>k<cmd>sil! keepp s/\v +$//<cr><cmd>noh<cr>j^", { desc = "Split Line" })

  -- Quick activate macro
  map("n", "Q", "@q", nore)
  map("x", "Q", "@q", nore)
  -- Run macro on each line
  map("x", "<M-q>", ":normal @q<CR>", nore)
  map("x", ".", ":normal .<CR>", nore)

  -- Reselect visual linewise
  map("n", "gV", "'<V'>", nore)
  map("x", "gV", "<esc>gV", sile)
  -- Reselect visual block wise
  map("n", "g<C-v>", "'<C-v>'>", nore)
  map("x", "g<C-v>", "<esc>g<C-v>", sile)

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
  map("x", "I", "<Plug>(VM-Visual-Add)i", { remap = true })
  map("x", "A", "<Plug>(VM-Visual-Add)a", { remap = true })
  map("s", "I", "<ESC>I", {})
  map("s", "A", "<ESC>A", {})

  -- Select all matching regex search
  -- map("n", "<M-S-/>", "<M-/><M-a>", {remap=true})

  -- Multi select object
  map("n", "<M-v>", operatorfunc_keys("multiselect", "<M-n>"), sile)
  -- Multi select all
  map("n", "<M-S-v>", operatorfunc_keys("multiselect_all", "<M-S-a>"), sile)

  -- Keymaps for easier access to 'ci' and 'di'
  local function quick_inside(key, no_v)
    map("o", key, "i" .. key, { remap = true })
    map("o", "<M-" .. key .. ">", "a" .. key, { remap = true })
    if not no_v then
      -- TODO: weirdly buggy with mini.surround
      -- map("x", key, "i" .. key, { remap = true })
      -- map("x", "<M-" .. key .. ">", "a" .. key, { remap = true })
    end
    -- map("n", "<M-" .. key .. ">", "vi" .. key, {remap=true})
    -- map("n", "<C-M-" .. key .. ">", "va" .. key, {remap=true})
  end

  local function quick_around(key)
    map("o", key, "a" .. key, { remap = true })
    map("n", "<M-" .. key .. ">", "va" .. key, { remap = true })
  end

  quick_inside "w"
  quick_inside("p", true)
  quick_inside "W"
  quick_inside "b"
  quick_inside "B"
  quick_inside "["
  quick_around "]"
  quick_inside "("
  quick_around ")"
  quick_inside "{"
  quick_around "}"
  quick_inside '"'
  quick_inside "'"
  quick_inside "q"
  -- map("n", "r", '"_ci', {})
  -- map("n", "x", '"_d', {})
  -- map("n", "X", "x", nore)
  map("n", "<BS>", "X", nore)
  map("n", "<M-BS>", "x", nore)

  -- "better" end and beginning of line
  map("o", "H", "^", { remap = true })
  map("o", "L", "$", { remap = true })
  map("x", "H", "^", { remap = true })
  map("x", "L", "g_", { remap = true })
  map("n", "H", [[col('.') == match(getline('.'),'\S')+1 ? '0' : '^']], norexpr)
  map("n", "L", "$", { remap = true })

  -- map("n", "m-/", "")

  -- Select whole file
  map("o", "iG", "<cmd>normal! mzggVG<cr>`z", nore)
  sel_map("iG", "gg0oG$", nore)

  -- Operator for current line
  -- sel_map("il", "g_o^")
  -- sel_map("al", "$o0")

  -- Make change line (cc) preserve indentation
  map("n", "cc", "^cg_", sile)

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

  local ldr_goto_next = "j"
  local ldr_goto_prev = "k"
  local ldr_swap_next = "a"
  local ldr_swap_prev = "A"
  -- Leader shortcut for ][ jumping and )( swapping
  map("n", "<leader>" .. ldr_goto_next, pre_goto_next, { remap = true })
  map("n", "<leader>" .. ldr_goto_prev, pre_goto_prev, { remap = true })
  map("n", "<leader>" .. ldr_swap_next, pre_swap_next, { remap = true })
  map("n", "<leader>" .. ldr_swap_prev, pre_swap_prev, { remap = true })

  map("n", "<leader><leader>", "<localleader>", { remap = true })
  map("x", "<leader><leader>", "<localleader>", { remap = true })

  -- Open new line with a count
  map("n", "o", function()
    local count = vim.v.count
    feedkeys("o", "n")
    for _ = 1, count do
      feedkeys "<CR>"
    end
  end, nore)

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

  -- TODO: create entire treesitter section

  -- TODO: support vim-sandwich in the which-key menus
  local leaderMappings = {
    [";"] = { telescope_fn.commands, "Srch Commands" },
    [" "] = { name = "<localleader>" },
    -- [";"] = { cmd "Dashboard", "Dashboard" },
    ["/"] = { telescope_fn.live_grep, "Global search" },
    ["?"] = { telescope_fn.live_grep_all, "Global search" },
    -- f = { telescope_fn.find_files, "Smart Open File" },
    f = { telescope_fn.smart_open, "Smart Open File" },
    F = { telescope_fn.find_all_files, "Find all Files" },
    [ldr_goto_next] = "Jump next (])",
    [ldr_goto_prev] = "Jump prev ([)",
    [ldr_swap_next] = "Swap next ())",
    [ldr_swap_prev] = "Swap prev (()",
    w = {
      function()
        if vim.api.nvim_buf_get_name(0) == "" then
          vim.notify("No filename yet, complete in cmdline", vim.log.levels.WARN)
          feedkeys ":w "
          -- vim.ui.input({ prompt = "filename:" }, function(f)
          --   vim.cmd("w " .. f)
          -- end)
        else
          vim.cmd "w"
        end
      end,
      "Write",
    }, -- w = { cmd "up", "Write" },
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
    Q = { "<C-W>q", "Quit" },
    o = {
      name = "Open window",
      -- s = { focus_fn.split_nicely, "Nice split" },
      o = { cmd "SidebarNvimToggle", "Sidebar.nvim" },
      e = { focus_fn.focus_max_or_equal, "Max/Equal splits" },
      f = { cmd "NvimTreeToggle", "File Sidebar" },
      u = { cmd "UndotreeToggle", "Undo tree" },
      r = { cmd "Oil", "File Browser" },
      q = { utils.quickfix_toggle, "Quick fixes" },
      E = { cmd "!open '%:p:h'", "Open File Explorer" },
      v = { cmd "Vista nvim_lsp", "Vista" },
      -- ["v"] = {cmd "Vista", "Vista"},
      M = { vim.g.goneovim and cmd "GonvimMiniMap" or cmd "MinimapToggle", "Minimap" },
      d = { cmd "DiffviewOpen", "Diffview" },
      h = { cmd "DiffviewFileHistory", "File History" },
      m = { cmd "!smerge '%:p:h'", "Sublime Merge" },
    },
    t = { name = "Terminals" },
    x = { name = "Run" },
    p = { name = "Project (Tasks)" },
    v = { name = "Visualize" },
    T = {
      name = "Toggle Opts",
      w = { cmd "setlocal wrap!", "Wrap" },
      s = { cmd "setlocal spell!", "Spellcheck" },
      C = { cmd "setlocal cursorcolumn!", "Cursor column" },
      n = { cmd "setlocal number!", "Number column" },
      g = { cmd "setlocal signcolumn!", "Cursor column" },
      l = { cmd "setlocal cursorline!", "Cursor line" },
      h = { cmd "setlocal hlsearch", "hlsearch" },
      c = { utils.conceal_toggle, "Conceal" },
      f = { focus_fn.focus_toggle, "Focus.nvim" },
      -- TODO: Toggle comment visibility
    },
    b = {
      name = "Buffers",
      s = { telescope_fn.curbuf, "Fuzzy Search" },
      w = { cmd "w", "Write" },
      W = { cmd "wa", "Write All" },
      c = { cmd "Bdelete!", "Close" },
      d = { cmd "bdelete!", "Close+Win" },
      f = { lsputil.format, "Format" },
      -- n = { cmd "tabnew", "New" },
      n = { cmd "enew", "New" },
      -- W = {cmd "BufferWipeout", "wipeout buffer"},
      -- e = {
      --     cmd "BufferCloseAllButCurrent",
      --     "close all but current buffer"
      -- },
      h = { cmd "BufferLineCloseLeft", "close all buffers to the left" },
      l = { cmd "BufferLineCloseRight", "close all BufferLines to the right" },
      D = { cmd "BufferLineSortByDirectory", "sort BufferLines automatically by directory" },
      L = { cmd "BufferLineSortByExtension", "sort BufferLines automatically by language" },
    },
    g = {
      name = "Git",
      L = { cmd "GitBlameToggle", "Blame Toggle" },
      l = { gitsigns_fn.blame_line, "Blame" },
      p = { gitsigns_fn.preview_hunk, "Preview Hunk" },
      r = { gitsigns_fn.reset_hunk, "Reset Hunk" },
      R = { gitsigns_fn.reset_buffer, "Reset Buffer" },
      s = { gitsigns_fn.stage_hunk, "Stage Hunk" },
      u = { gitsigns_fn.undo_stage_hunk, "Undo Stage Hunk" },
      o = { telescope_fn.git_status, "Open changed file" },
      b = { telescope_fn.git_branches, "Checkout branch" },
      c = { telescope_fn.git_commits, "Checkout commit" },
      C = { telescope_fn.git_bcommits, "Checkout commit(for current file)" },
      ["<CR>"] = { cmd "tab G", "Fugitive Status" },
      [" "] = { ":tab G ", "Fugitive ..." },
    },
    I = {
      name = "Info",
      L = { cmd "LspInfo", "LSP" },
      N = { cmd "NullLsInfo", "Null-ls" },
      I = { cmd "Mason", "LspInstall" },
      T = { cmd "TSConfigInfo", "Treesitter" },
      P = { cmd "Lazy", "Lazy plugins" },
    },
    l = {
      name = "LSP",
      h = { lspbuf.hover, "Hover (gh)" },
      a = { do_code_action, "Code Action (K)" },
      k = { vim.lsp.codelens.run, "Run Code Lens (gK)" },
      t = { lspbuf.type_definition, "Type Definition" },
      f = { lsputil.format, "Format" },
      r = { telescope_fn.lsp_references, "References" },
      i = { telescope_fn.lsp_implementations, "Implementations" },
      d = { telescope_fn.lsp_definitions, "Definitions of" },
      s = { lspbuf.signature_help, "Signature Help" },
      c = {
        name = "Calls",
        i = { lspbuf.incoming_calls, "Incoming" },
        o = { lspbuf.outgoing_calls, "Outgoing" },
      },
      z = {
        name = "View in Split",
        d = {
          lsputil.view_location_split("definition", "FocusSplitNicely"),
          "Split Definition",
        },
        D = {
          lsputil.view_location_split("declaration", "FocusSplitNicely"),
          "Split Declaration",
        },
        r = {
          lsputil.view_location_split("references", "FocusSplitNicely"),
          "Split References",
        },
        s = {
          lsputil.view_location_split("implementation", "FocusSplitNicely"),
          "Split Implementation",
        },
      },
    },
    s = {
      name = "Search",
      [" "] = { telescope_fn.resume, "Redo last" },
      -- n = { telescope_fn.notify.notify, "Notifications" },
      f = { telescope_fn.find_files, "Find File" },
      -- c = { telescope_fn.colorscheme, "Colorscheme" },
      s = { telescope_fn.lsp_document_symbols, "Document Symbols" },
      S = { telescope_fn.lsp_dynamic_workspace_symbols, "Workspace Symbols" },
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
      k = { telescope_fn.keymaps, "Keymappings" },
      c = { telescope_fn.commands, "Commands" },
      n = { telescope_fn.treesitter, "Treesitter Nodes" },
      o = { cmd "TodoTelescope", "TODOs search" },
      q = { telescope_fn.quickfix, "Quickfix" },
      ["*"] = { telescope_fn.grep_string, "Curr word" },
      ["/"] = { telescope_fn.grep_last_search, "Last Search" },
      -- ["."] = { [[:%s/<C-R>.//g<Left><Left>]], "Last insert" },
      p = { cmd "SearchSession", "Sessions" },
      m = { telescope_fn.marks, "Marks" },
      ["<CR>"] = { ":Telescope ", "Telescope ..." },
      B = { telescope_fn.builtin, "Telescopes" },
      ["+"] = { [[/<C-R>+<cr>]], "Last yank" },
      ["."] = { [[/<C-R>.<cr>]], "Last insert" },
    },
    r = {
      name = "Replace/Refactor",
      n = { lsputil.rename, "Rename" },
      t = "Rename TS",
      ["*"] = { [["zyiw:%s/<C-R>z//g<Left><Left>]], "Curr word" },
      ["/"] = { [[:%s/<C-R>///g<Left><Left>]], "Last search" },
      ["+"] = { [[:%s/<C-R>+//g<Left><Left>]], "Last yank" },
      ["."] = { [[:%s/<C-R>.//g<Left><Left>]], "Last insert" },
      s = { [[:%s///g<Left><Left><Left>]], "In File" },
    },
    n = {
      name = "Generate",
      n = { cmd "Neogen", "Gen Doc" },
      f = { cmd "Neogen func", "Func Doc" },
      F = { cmd "Neogen file", "File Doc" },
      t = { cmd "Neogen type", "type Doc" },
      c = { cmd "Neogen class", "Class Doc" },
    },
    d = {
      name = "Diagnostics",
      T = { lsputil.toggle_diagnostics, "Toggle Diags" },
      l = { lsputil.diag_line, "Line Diagnostics" },
      v = {
        -- TODO: make this not move the cursor
        operatorfunc_scaffold("show_diagnostics", lsputil.range_diagnostics),
        "Range Diagnostics",
      },
    },
    P = {
      name = "Projects",
    },
    m = "Move",
    -- c = {
    --   operatorfunc_keys("change_all", "<leader>c"),
    --   "Change all",
    -- },
  }

  M.whichkey {
    [O.treesitter.textobj_prefixes.swap_prev] = {
      name = "Swap Prev",
      [O.treesitter.textobj_prefixes.swap_prev] = { cmd "ISwap", "Interactive" },
      [ldr_swap_prev] = { cmd "ISwap", "Interactive" },
      [O.treesitter.textobj_prefixes.swap_next] = { cmd "ISwapWith", "I. With" },
    },
    [O.treesitter.textobj_prefixes.swap_next] = {
      name = "Swap Next",
      [O.treesitter.textobj_prefixes.swap_next] = { cmd "ISwap", "Interactive" },
      [O.treesitter.textobj_prefixes.swap_prev] = { cmd "ISwapWith", "I. With" },
      [ldr_swap_next] = { cmd "ISwapWith", "I. With" },
      [ldr_swap_prev] = { cmd "ISwap", "I. With" },
      n = { cmd "ISwapNodeWith", "I. With" },
    },
  }

  local vLeaderMappings = {
    -- ["/"] = { cmd "CommentToggle", "Comment" },
    l = {
      d = { lsputil.range_diagnostics, "Range Diagnostics" },
      a = { telescope_fn.code_actions_previewed, "Code Actions" },
    },
    r = {
      name = "Replace/Refactor",
      S = { ":s///g<Left><Left><Left>", "In Selection" },
      s = { '"zy:<C-u>s/<C-R>z//g<Left><Left>', "Selection" },
      ["/"] = { [[:s/<C-R>///g<Left><Left>]], "Last search" },
      ["+"] = { [[:s/<C-R>+//g<Left><Left>]], "Last yank" },
      ["."] = { [[:s/<C-R>.//g<Left><Left>]], "Last insert" },
    },
    -- c = {
    --   [["z<M-y>:%s/<C-r>z//g<Left><Left>]],
    --   "Change all",
    -- },
    s = { 'ygvc<CR><C-r>"<CR><ESC>', "Add newlines around" },
    D = {
      name = "Debug",
      v = {
        function()
          require("dapui").eval()
        end,
        "Eval",
      },
    },
  }

  -- TODO: move these to different modules?
  wk.register(leaderMappings, leaderOpts)
  wk.register(vLeaderMappings, vLeaderOpts)

  -- TODO: move to plugin config files?
  if O.plugin.surround then
    local ops = { mode = "o" }
    wk.register({ ["s"] = "Surround", ["S"] = "Surround Rest", ["ss"] = "Line" }, ops)
  end
  if O.plugin.lightspeed then
    local ops = { mode = "o" }
    wk.register({ ["z"] = "Light speed", ["Z"] = "Light speed bwd" }, ops)
  end

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

  -- Tab management keybindings
  local tab_mgmt = {
    t = {
      function()
        if #vim.api.nvim_list_tabpages() == 1 then
          vim.cmd "tabnew"
        else
          vim.cmd "tabnext"
        end
      end,
      "Next",
    },
    -- ["<C-t>"] = { cmd "tabnext", "which_key_ignore" },
    n = { cmd "tabnew", "New" },
    q = { cmd "tabclose", "Close" },
    p = { cmd "tabprev", "Prev" },
    l = { cmd "Telescope telescope-tabs list_tabs", "List tabs" },
    o = { cmd "tabonly", "Close others" },
    ["1"] = { cmd "tabfirst", "First tab" },
    ["0"] = { cmd "tablast", "Last tab" },
  }
  wk.register(tab_mgmt, {
    mode = "n",
    prefix = "<C-t>",
    noremap = true,
    silent = true,
  })
  for key, value in pairs(tab_mgmt) do
    -- local lhs = "<C-t><C-" .. key .. ">"
    -- map("n", lhs, value[1], { noremap = true, silent = true })
    local lhs = "<C-" .. key .. ">"
    wk.register({ [lhs] = { value[1], "which_key_ignore" } }, {
      mode = "n",
      prefix = "<C-t>",
      noremap = true,
      silent = true,
    })
  end

  require("keymappings.nav").setup()

  -- FIXME: duplicate entries for some of the operators
end

local mincount = 5
function M.wrapjk()
  map("n", "j", [[v:count ? (v:count > ]] .. mincount .. [[ ? "m'" . v:count : '') . 'j' : 'gj']], norexpr)
  map("n", "k", [[v:count ? (v:count > ]] .. mincount .. [[ ? "m'" . v:count : '') . 'k' : 'gk']], norexpr)
  map("x", "j", [[v:count ? (v:count > ]] .. mincount .. [[ ? "m'" . v:count : '') . 'j' : 'gj']], norexpr)
  map("x", "k", [[v:count ? (v:count > ]] .. mincount .. [[ ? "m'" . v:count : '') . 'k' : 'gk']], norexpr)
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
  if opts == nil then
    opts = {}
  end
  require("which-key").register(maps, vim.tbl_extend("keep", opts, M.wkopts))
end

function M.localleader(maps, opts)
  if opts == nil then
    opts = {}
  end
  M.whichkey(
    maps,
    vim.tbl_extend("keep", opts, {
      prefix = "<localleader>",
      buffer = 0,
    })
  )
end

function M.ftleader(maps, opts)
  if opts == nil then
    opts = {}
  end
  M.whichkey(
    maps,
    vim.tbl_extend("keep", opts, {
      prefix = "<leader>",
      buffer = 0,
    })
  )
end

function M.vlocalleader(maps, opts)
  if opts == nil then
    opts = {}
  end
  M.localleader(maps, vim.tbl_extend("keep", opts, { mode = "v" }))
end

return setmetatable(M, {
  __call = function(tbl, ...)
    return map(unpack(...))
  end,
})
