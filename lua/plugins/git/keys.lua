local M = {}
M.hydra = function(bufnr)
  local hint = [[
 _]_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
 _[_: prev hunk   _u_: undo last stage   _p_: preview hunk   _B_: blame show full
 _o_: open file   _S_: stage buffer      ^ ^                 _/_: show base file
 ^ ^              _i_: GitUI             _m_: Sublime Merge
 _q_: exit        _g_: Neogit
]]
  local Hydra = require "hydra"
  local gitsigns = require "gitsigns"
  local conflict_hydra = Hydra {
    name = "Git Conflicts",
    config = {
      color = "pink",
      invoke_on_body = false,
    },
    heads = {
      { "o", "<Plug>(git-conflict-ours)", { desc = "ours" } },
      { "t", "<Plug>(git-conflict-theirs)", { desc = "theirs" } },
      { "b", "<Plug>(git-conflict-both)", { desc = "both" } },
      { "0", "<Plug>(git-conflict-none)", { desc = "none" } },
      { "[", "<Plug>(git-conflict-prev-conflict)", { desc = "prev conflict" } },
      { "]", "<Plug>(git-conflict-next-conflict)", { desc = "next conflict" } },
    },
  }
  local hydra = Hydra {
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
        pcall(vim.cmd.loadview)
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
      { "p", gitsigns.preview_hunk_inline, { desc = "preview hunk" } },
      { "d", gitsigns.toggle_deleted, { nowait = true, desc = "toggle deleted" } },
      { "b", gitsigns.blame_line, { desc = "blame" } },
      { "B", function() gitsigns.blame_line { full = true } end, { desc = "blame show full" } },
      { "/", gitsigns.show, { exit = true, desc = "show base file" } }, -- show the base of the file
      { "o", utils.telescope.git_status, { desc = "Open" } },
      { "g", function() vim.cmd "Neogit" end, { exit_before = true, desc = "Fugitive" } },
      { "m", function() vim.cmd "!smerge '%:p:h'" end, { exit_before = true, desc = "Subl merge" } },
      {
        "i",
        function() require("kitty.terms").use_os_window({}, "gitui", "gitui") end,
        { exit_before = true, desc = "GitUI" },
      },
      {
        "c",
        function() conflict_hydra:activate() end,
        { exit_before = true, desc = "Git Conflicts" },
      },
      -- { "<Space>", ":tab G ", { exit = true, desc = false } },
      { "q", nil, { exit = true, nowait = true, desc = "exit" } },
      { "<esc>", nil, { exit = true, nowait = true, desc = "exit" } },
    },
  }
  local repeatable = mappings.repeatable
  local hunks = repeatable(
    "g",
    "Git Hunk",
    { vim.schedule_wrap(gitsigns.next_hunk), vim.schedule_wrap(gitsigns.prev_hunk) },
    {
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
    }
  )
  return hydra, hunks
end
M.diffview = require "plugins.git.diffview"
return M
