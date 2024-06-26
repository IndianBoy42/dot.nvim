return function(actions)
  return {
    disable_defaults = false, -- Disable the default keymaps
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
      { "n", "[x", actions.prev_conflict, { desc = "previous conflict" } },
      { "n", "]x", actions.next_conflict, { desc = "next conflict" } },
      { "n", "<localleader>co", actions.conflict_choose "ours", { desc = "OURS version" } },
      { "n", "<localleader>ct", actions.conflict_choose "theirs", { desc = "THEIRS version" } },
      { "n", "<localleader>cb", actions.conflict_choose "base", { desc = "BASE version" } },
      { "n", "<localleader>ca", actions.conflict_choose "all", { desc = "ALL versions" } },
      { "n", "dx", actions.conflict_choose "none", { desc = "Delete the conflict region" } },
      { "n", "<localleader>cO", actions.conflict_choose_all "ours", { desc = "every OURS version" } },
      { "n", "<localleader>cT", actions.conflict_choose_all "theirs", { desc = "every THEIRS version" } },
      { "n", "<localleader>cB", actions.conflict_choose_all "base", { desc = "every BASE version" } },
      { "n", "<localleader>cA", actions.conflict_choose_all "all", { desc = "every ALL versions" } },
      { "n", "dX", actions.conflict_choose_all "none", { desc = "Delete all conflict regions" } },
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
      { { "n", "x" }, "2do", actions.diffget "ours", { desc = "OURS version" } },
      { { "n", "x" }, "3do", actions.diffget "theirs", { desc = "THEIRS version" } },
      { "n", "?", actions.help { "view", "diff3" }, { desc = "Open the help panel" } },
    },
    diff4 = {
      -- Mappings in 4-way diff layouts
      { { "n", "x" }, "1do", actions.diffget "base", { desc = "BASE version" } },
      { { "n", "x" }, "2do", actions.diffget "ours", { desc = "OURS version" } },
      { { "n", "x" }, "3do", actions.diffget "theirs", { desc = "THEIRS version" } },
      { "n", "?", actions.help { "view", "diff4" }, { desc = "Open the help panel" } },
    },
    file_panel = {
      { "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "<down>", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry." } },
      { "n", "<up>", actions.prev_entry, { desc = "Bring the cursor to the previous file entry." } },
      { "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "o", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "l", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "-", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry." } },
      { "n", "S", actions.stage_all, { desc = "Stage all entries." } },
      { "n", "U", actions.unstage_all, { desc = "Unstage all entries." } },
      { "n", "X", actions.restore_entry, { desc = "Restore entry to the state on the left side." } },
      { "n", "L", actions.open_commit_log, { desc = "Open the commit log panel." } },
      { "n", "<c-u>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
      { "n", "<c-d>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
      { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
      -- { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
      { "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
      { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open the file in a new split" } },
      { "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
      { "n", "i", actions.listing_style, { desc = "Toggle between 'list' and 'tree' views" } },
      { "n", "f", actions.toggle_flatten_dirs, { desc = "Flatten empty subdirs in tree listing style." } },
      { "n", "R", actions.refresh_files, { desc = "Update stats and entries in the file list." } },
      { "n", "<localleader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
      { "n", "<localleader>b", actions.toggle_files, { desc = "Toggle the file panel" } },
      { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle available layouts" } },
      { "n", "[x", actions.prev_conflict, { desc = "Go to the previous conflict" } },
      { "n", "]x", actions.next_conflict, { desc = "Go to the next conflict" } },
      { "n", "?", actions.help "file_panel", { desc = "Open the help panel" } },
      { "n", "<localleader>cO", actions.conflict_choose_all "ours", { desc = "every OURS version" } },
      { "n", "<localleader>cT", actions.conflict_choose_all "theirs", { desc = "every THEIRS version" } },
      { "n", "<localleader>cB", actions.conflict_choose_all "base", { desc = "every BASE version" } },
      { "n", "<localleader>cA", actions.conflict_choose_all "all", { desc = "every ALL versions" } },
      { "n", "dX", actions.conflict_choose_all "none", { desc = "Delete all conflict regions" } },
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
      { "n", "l", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "<c-u>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
      { "n", "<c-d>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
      { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
      -- { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
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
