local M = {}
M.hydra = function(bufnr)
  local hint = [[
 _]_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
 _[_: prev hunk   _u_: undo last stage   _p_: preview hunk   _B_: blame show full 
 _o_: open file   _S_: stage buffer      ^ ^                 _/_: show base file
 ^
 ^ ^              _g_: Neogit          _q_: exit
]]
  local Hydra = require "hydra"
  local gitsigns = require "gitsigns"
  Hydra {
    name = "Git",
    hint = hint,
    config = {
      buffer = bufnr,
      color = "pink",
      invoke_on_body = true,
      hint = {
        float_opts = { border = "rounded" },
      },
      on_key = function() vim.wait(50) end,
      on_enter = function()
        vim.cmd "mkview"
        vim.cmd "silent! %foldopen!"
        gitsigns.toggle_signs(true)
        gitsigns.toggle_linehl(true)
      end,
      on_exit = function()
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd "loadview"
        vim.api.nvim_win_set_cursor(0, cursor_pos)
        vim.cmd "normal! zv"
        gitsigns.toggle_signs(false)
        gitsigns.toggle_linehl(false)
        gitsigns.toggle_deleted(false)
      end,
    },
    mode = { "n", "x" },
    body = "<leader>g",
    heads = {
      {
        "]",
        function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gitsigns.next_hunk() end)
          return "<Ignore>"
        end,
        { expr = true, desc = "next hunk" },
      },
      {
        "[",
        function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gitsigns.prev_hunk() end)
          return "<Ignore>"
        end,
        { expr = true, desc = "prev hunk" },
      },
      {
        "s",
        function()
          local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
          if mode == "V" then -- visual-line mode
            local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
            vim.api.nvim_feedkeys(esc, "x", false) -- exit visual mode
            vim.cmd "'<,'>Gitsigns stage_hunk"
          else
            vim.cmd "Gitsigns stage_hunk"
          end
        end,
        { desc = "stage hunk" },
      },
      { "u", gitsigns.undo_stage_hunk, { desc = "undo last stage" } },
      { "S", gitsigns.stage_buffer, { desc = "stage buffer" } },
      { "p", gitsigns.preview_hunk, { desc = "preview hunk" } },
      { "d", gitsigns.toggle_deleted, { nowait = true, desc = "toggle deleted" } },
      { "b", gitsigns.blame_line, { desc = "blame" } },
      { "B", function() gitsigns.blame_line { full = true } end, { desc = "blame show full" } },
      { "/", gitsigns.show, { exit = true, desc = "show base file" } }, -- show the base of the file
      { "o", utils.telescope.git_status, { desc = "Open" } },
      { "g", function() vim.cmd "Neogit" end, { exit_before = true, desc = "Fugitive" } },
      -- { "<Space>", ":tab G ", { exit = true, desc = false } },
      { "q", nil, { exit = true, nowait = true, desc = "exit" } },
      { "<esc>", nil, { exit = true, nowait = true, desc = "exit" } },
    },
  }
  local repeatable = mappings.repeatable
  repeatable("g", "Git Hunk", { vim.schedule_wrap(gitsigns.next_hunk), vim.schedule_wrap(gitsigns.prev_hunk) }, {
    config = {
      on_key = function() vim.wait(50) end,
      on_enter = function()
        gitsigns.toggle_signs(true)
        gitsigns.toggle_linehl(true)
        gitsigns.toggle_deleted(true)
      end,
      on_exit = function()
        gitsigns.toggle_linehl(false)
        gitsigns.toggle_deleted(false)
      end,
    },
  })
end
M.diffview = function(actions)
  return {
    view = {
      -- The `view` bindings are active in the diff buffers, only when the current
      -- tabpage is a Diffview.
      { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
      { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
      { "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
      { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open the file in a new split" } },
      { "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
      { "n", "<localleader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
      { "n", "<localleader>b", actions.toggle_files, { desc = "Toggle the file panel." } },
      { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle through available layouts." } },
      { "n", "[x", actions.prev_conflict, { desc = "In the merge-tool: jump to the previous conflict" } },
      { "n", "]x", actions.next_conflict, { desc = "In the merge-tool: jump to the next conflict" } },
      { "n", "<localleader>co", actions.conflict_choose "ours", { desc = "Choose the OURS version of a conflict" } },
      {
        "n",
        "<localleader>ct",
        actions.conflict_choose "theirs",
        { desc = "Choose the THEIRS version of a conflict" },
      },
      { "n", "<localleader>cb", actions.conflict_choose "base", { desc = "Choose the BASE version of a conflict" } },
      { "n", "<localleader>ca", actions.conflict_choose "all", { desc = "Choose all the versions of a conflict" } },
      { "n", "dx", actions.conflict_choose "none", { desc = "Delete the conflict region" } },
    },
    diff1 = {
      -- Mappings in single window diff layouts
      { "n", "?", actions.help { "view", "diff1" }, { desc = "Open the help panel" } },
    },
    diff2 = {
      -- Mappings in 2-way diff layouts
      { "n", "?", actions.help { "view", "diff2" }, { desc = "Open the help panel" } },
    },
    diff3 = {
      -- Mappings in 3-way diff layouts
      {
        { "n", "x" },
        "2do",
        actions.diffget "ours",
        { desc = "Obtain the diff hunk from the OURS version of the file" },
      },
      {
        { "n", "x" },
        "3do",
        actions.diffget "theirs",
        { desc = "Obtain the diff hunk from the THEIRS version of the file" },
      },
      { "n", "?", actions.help { "view", "diff3" }, { desc = "Open the help panel" } },
    },
    diff4 = {
      -- Mappings in 4-way diff layouts
      {
        { "n", "x" },
        "1do",
        actions.diffget "base",
        { desc = "Obtain the diff hunk from the BASE version of the file" },
      },
      {
        { "n", "x" },
        "2do",
        actions.diffget "ours",
        { desc = "Obtain the diff hunk from the OURS version of the file" },
      },
      {
        { "n", "x" },
        "3do",
        actions.diffget "theirs",
        { desc = "Obtain the diff hunk from the THEIRS version of the file" },
      },
      { "n", "?", actions.help { "view", "diff4" }, { desc = "Open the help panel" } },
    },
    file_panel = {
      { "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "<down>", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry." } },
      { "n", "<up>", actions.prev_entry, { desc = "Bring the cursor to the previous file entry." } },
      { "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "o", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "-", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry." } },
      { "n", "S", actions.stage_all, { desc = "Stage all entries." } },
      { "n", "U", actions.unstage_all, { desc = "Unstage all entries." } },
      { "n", "X", actions.restore_entry, { desc = "Restore entry to the state on the left side." } },
      { "n", "L", actions.open_commit_log, { desc = "Open the commit log panel." } },
      { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
      { "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
      { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
      { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
      { "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
      { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open the file in a new split" } },
      { "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
      { "n", "i", actions.listing_style, { desc = "Toggle between 'list' and 'tree' views" } },
      { "n", "f", actions.toggle_flatten_dirs, { desc = "Flatten empty subdirectories in tree listing style." } },
      { "n", "R", actions.refresh_files, { desc = "Update stats and entries in the file list." } },
      { "n", "<localleader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
      { "n", "<localleader>b", actions.toggle_files, { desc = "Toggle the file panel" } },
      { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle available layouts" } },
      { "n", "[x", actions.prev_conflict, { desc = "Go to the previous conflict" } },
      { "n", "]x", actions.next_conflict, { desc = "Go to the next conflict" } },
      { "n", "?", actions.help "file_panel", { desc = "Open the help panel" } },
    },
    file_history_panel = {
      { "n", "g!", actions.options, { desc = "Open the option panel" } },
      { "n", "<C-M-d>", actions.open_in_diffview, { desc = "Open the entry under the cursor in a diffview" } },
      { "n", "y", actions.copy_hash, { desc = "Copy the commit hash of the entry under the cursor" } },
      { "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
      { "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
      { "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
      { "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "<down>", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry." } },
      { "n", "<up>", actions.prev_entry, { desc = "Bring the cursor to the previous file entry." } },
      { "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "o", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
      { "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
      { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
      { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
      { "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
      { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open the file in a new split" } },
      { "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
      { "n", "<localleader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
      { "n", "<localleader>b", actions.toggle_files, { desc = "Toggle the file panel" } },
      { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle available layouts" } },
      { "n", "?", actions.help "file_history_panel", { desc = "Open the help panel" } },
    },
    option_panel = {
      { "n", "<tab>", actions.select_entry, { desc = "Change the current option" } },
      { "n", "q", actions.close, { desc = "Close the panel" } },
      { "n", "?", actions.help "option_panel", { desc = "Open the help panel" } },
    },
    help_panel = {
      { "n", "q", actions.close, { desc = "Close help menu" } },
      { "n", "<esc>", actions.close, { desc = "Close help menu" } },
    },
  }
end
M.fugitive = function()
  local maps = {
    s = { "s", "Stage" },
    u = { "u", "Unstage" },
    ["-"] = { "-", "Toggle Stage" },
    U = { "U", "Unstage all" },
    X = { "X", "Discard" },
    [","] = { "=", "Toggle diff" },
    ["="] = { "=", "Toggle diff" },
    [">"] = { ">", "Show diff" },
    ["<"] = { "<", "Hide diff" },
    -- I = { "I", "Add Patch" },
    d = { name = "Diffs" },
    dd = { "dd", "Gdiffsplit" },
    dv = { "dv", "Gvdiffsplit" },
    ds = { "ds", "Ghdiffsplit" },
    dq = { "dq", "Close Diffs" },
    ["<CR>"] = { "<CR>", "Open" },
    o = { "gO", "Open vsplit" },
    gO = { "o", "Open split" },
    O = { "O", "Open tab" },
    P = { "1p", "Open preview" },
    p = { "<cmd>Git push<cr>", "Push" },
    C = { "C", "Open commit" },
    ["("] = { "(", "Jump prev" },
    [")"] = { ")", "Jump next" },
    i = { "i", "Next file (expand)" },
    ["*"] = { "*", "Find +/-" },
    I = { "1gi", "Open .gitignore" },
    gI = { "1gI", "Add to ignore" },
    c = { name = "Commits" },
    cc = { "cvc", "Create commit" },
    ca = { "cva", "Amend" },
    ce = { "ce", "Amend noedit" },
    cw = { "cw", "Reword" },
    -- cvc = { "cvc", "Commit -v" },
    -- cva = { "cva", "Amend -v" },
    cf = { "cf", "Fixup" },
    cF = { "cF", "Fixup+Rebase" },
    cs = { "cs", "Squash" },
    cS = { "cS", "Squash+Rebase" },
    cA = { "cA", "Squash+Edit" },
    ["c<space>"] = { "c<space>", ":Git commit ..." },
    cr = { name = "Revert" },
    crc = { "crc", "Revert" },
    crn = { "crn", "Revert (nocommit)" },
    ["cr<space>"] = { "cr<space>", ":Git revert ..." },
    ["cm<space>"] = { "cm<space>", ":Git merge ..." },
    co = { name = "Checkout" },
    coo = { "coo", "Checkout Commit" },
    ["cb<space>"] = { "cb<space>", ":Git branch ..." },
    ["co<space>"] = { "co<space>", ":Git checkout ..." },
    cz = { name = "Stashes" },
    czz = { "czz", "Push stash" },
    czZ = { "1czz", "Push stash untracked" },
    -- czA = { "2czz", "Push stash all" },
    czw = { "czw", "Push stash worktree" },
    czA = { "czA", "Apply stash" },
    cza = { "cza", "Apply stash preserve" },
    czP = { "czP", "Pop stash" },
    czp = { "czp", "Pop stash preserve" },
    ["cz<space>"] = { "co<space>", ":Git stash ..." },
    -- TODO: Rebase
    r = { name = "Rebase" },
    ri = { "ri", "Interactive" },
    rf = { "rf", "Interactive notodo" },
    ru = { "ru", "Against @{upstream}" },
    rp = { "rp", "Against @{push}" },
    rr = { "rr", "Continue" },
    rs = { "rs", "Skip" },
    ra = { "ra", "Abort" },
    re = { "re", "Edit todo" },
    rw = { "rw", "commit: reword" },
    rm = { "rm", "commit: edit" },
    rd = { "rd", "commit: drop" },
    ["r<Space>"] = { "r<Space>", ":Git rebase ... " },
    q = { "gq", "Close status" },
    kc = { "[c", "Prev hunk" },
    jc = { "]c", "Next hunk" },
    kf = { "[m", "Prev file" },
    jf = { "]m", "Next file" },
  }
  mappings.localleader(maps)
end
return M
