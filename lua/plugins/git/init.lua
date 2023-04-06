return {
  {
    "f-person/git-blame.nvim",
    cond = false,
    init = function() vim.g.gitblame_enabled = 0 end,
    cmd = "GitBlameToggle",
    keys = { "<leader>gL", "<cmd>GitBlameToggle<cr>", desc = "Blame Toggle" },
  },
  {
    "ruifm/gitlinker.nvim",
    cmd = "Gitlink",
    opts = {
      opts = {
        -- Manual mode doesn't automatically change your root directory, so you have
        -- the option to manually do so using `:ProjectRoot` command.
        -- manual_mode = false,
        -- When set to false, you will get a message when project.nvim changes your
        -- directory.
        silent_chdir = false,
        -- Methods of detecting the root directory. **"lsp"** uses the native neovim
        -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
        -- order matters: if one is not detected, the other is used as fallback. You
        -- can also delete or rearangne the detection methods.
        -- detection_methods = { "lsp", "pattern" },
        -- All the patterns used to detect root dir, when **"pattern"** is in
        -- detection_methods
        -- patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
        -- Table of lsp clients to ignore by name
        -- eg: { "efm", ... }
        -- ignore_lsp = true,
      },
    },
  },
  { "pwntester/octo.nvim", cmd = "Octo" },
  {
    "sindrets/diffview.nvim",
    config = function(_, opts)
      local actions = require "diffview.actions"
      require("diffview").setup {
        key_bindings = require("plugins.git.keys").diffview(actions),
      }
    end,
    ft = "diff",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  },
  {
    "tpope/vim-fugitive",
    config = function() end,
    in_fugitive_menu = function()
      vim.o.previewwindow = true
      -- TODO: hydra.nvim submode?
      require("plugins.git.keys").fugitive()

      --   vim.cmd [[
      -- augroup _fugitive
      --   autocmd! * <buffer>
      --   autocmd CursorHold,CursorHoldI <buffer> lua require'which-key'.show()
      -- augroup END
      -- ]]
    end,
    cmd = { "G", "Git", "Gdiffsplit", "Gdiff" },
  },
  { "aaronhallaert/advanced-git-search.nvim" },
  -- TODO: https://github.com/anuvyklack/hydra.nvim/wiki/Git
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local hint = [[
 _J_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
 _K_: prev hunk   _u_: undo last stage   _p_: preview hunk   _B_: blame show full 
 _o_: open file   _S_: stage buffer      ^ ^                 _/_: show base file
 ^
 ^ ^              _<Enter>_: Fugitive          _q_: exit
]]
        local Hydra = require "hydra"
        local gitsigns = require "gitsigns"
        Hydra {
          name = "Git",
          hint = hint,
          config = {
            buffer = bufnr,
            color = "red",
            invoke_on_body = true,
            hint = {
              border = "rounded",
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
              vim.cmd "normal zv"
              gitsigns.toggle_signs(false)
              gitsigns.toggle_linehl(false)
              gitsigns.toggle_deleted(false)
            end,
          },
          mode = { "n", "x" },
          body = "<leader>g",
          heads = {
            {
              "J",
              function()
                if vim.wo.diff then return "]c" end
                vim.schedule(function() gitsigns.next_hunk() end)
                return "<Ignore>"
              end,
              { expr = true, desc = "next hunk" },
            },
            {
              "K",
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
            { "<Enter>", function() vim.cmd "tab G" end, { exit = true, desc = "Fugitive" } },
            { "<spc>", ":tab G ", { exit = true, desc = false } },
            { "q", nil, { exit = true, nowait = true, desc = "exit" } },
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
      end,
    },
    event = { "BufReadPre", "BufNewFile" },
    -- keys = function()
    --   local repeatable = mappings.repeatable
    --   local gs = utils.lazy_require "gitsigns"
    --   repeatable("g", "Git Hunk", { vim.schedule_wrap(gs.next_hunk), vim.schedule_wrap(gs.prev_hunk) }, {
    --   local p = utils.partial
    --   return {
    --     { "<leader>gl", gs.blame_line, "Blame" },
    --     { "<leader>gp", gs.preview_hunk, "Preview Hunk" },
    --     { "<leader>grh", gs.reset_hunk, "Reset Hunk" },
    --     { "<leader>grb", gs.reset_buffer, "Reset Buffer" },
    --     { "<leader>gS", gs.stage_buffer, "Stage Buffer" },
    --     { "<leader>gs", gs.stage_hunk, "Stage Hunk" },
    --     { "<leader>gd", gs.diffthis, "Diff Hunk" },
    --     { "<leader>gD", p(gs.diffthis, "~"), "Diff ~" },
    --     { "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk" },
    --     { "ig", ":<C-U>Gitsigns select_hunk<CR>", "Git Hunk", mode = { "o", "x" } },
    --   }
    -- end,
  },
}
