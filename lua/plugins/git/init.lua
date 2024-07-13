return {
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
  {
    "sindrets/diffview.nvim",
    config = function(_, opts)
      local actions = require "diffview.actions"
      require("diffview").setup {
        key_bindings = require("plugins.git.keys").diffview(actions),
        hooks = {
          view_opened = function() vim.cmd.WindowsDisableAutowidth() end,
          view_entered = function() vim.cmd.WindowsDisableAutowidth() end,
          view_closed = function() vim.cmd.WindowsEnableAutowidth() end,
          view_leave = function() vim.cmd.WindowsEnableAutowidth() end,
        },
      }
    end,
    ft = "diff",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  },
  -- TODO: neogit
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = "nvim-lua/plenary.nvim",
    opts = {
      use_telescope = true,
      telescope_sorter = function() return require("telescope").extensions.fzf.native_fzf_sorter() end,
      integrations = {
        diffview = true,
      },
      graph_style = "unicode",
      disable_commit_confirmation = true,
      disable_builtin_notifications = true,
      disable_insert_on_commit = "auto",
      mappings = {
        status = {
          s = false,
          S = false,
          a = "Stage",
          A = "StageUnstaged",
          ["<C-a>"] = "StageAll",
          h = "Toggle",
          l = "Toggle",
          ["<C-q>"] = "Close",
        },
        rebase_editor = {
          ["<C-q>"] = "Close",
        },
        commit_editor = {
          ["<C-q>"] = "Close",
        },
        popup = {
          A = false,
          C = "CherryPickPopup",
          L = "LogPopup",
        },
      },
    },
    config = function(_, opts)
      require("neogit").setup(opts)

      local group = vim.api.nvim_create_augroup("NeogitUserAucmds", {})
    end,
  },
  { "aaronhallaert/advanced-git-search.nvim" },
  -- TODO: https://github.com/anuvyklack/hydra.nvim/wiki/Git
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr) vim.b.gitsigns_attached = true end,
    },
    event = "LazyFile",
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
  {
    "FabijanZulj/blame.nvim",
    cmd = "BlameToggle",
    config = function(_, opts)
      require("blame").setup(opts)
      mappings.quick_toggle("<leader>T", "b", "<cmd>ToggleBlame virtual<cr>")
    end,
    keys = {
      { "<leader>Tb", desc = "ToggleBlame virtual" },
    },
  },
  {
    "akinsho/git-conflict.nvim",
    opts = {
      default_mappings = false,
    },
    config = function(_, opts)
      require("git-conflict").setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "GitConflictDetected",
        callback = function() vim.notify("Conflict detected in " .. vim.fn.expand "<afile>") end,
      })
    end,
    event = "LazyFile",
  },
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    opts = {
      mappings = {
        issue = {
          close_issue = { lhs = "<localleader>ic", desc = "close issue" },
          reopen_issue = { lhs = "<localleader>io", desc = "reopen issue" },
          list_issues = { lhs = "<localleader>il", desc = "list open issues on same repo" },
          reload = { lhs = "<C-r>", desc = "reload issue" },
          open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
          copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
          add_assignee = { lhs = "<localleader>aa", desc = "add assignee" },
          remove_assignee = { lhs = "<localleader>ad", desc = "remove assignee" },
          create_label = { lhs = "<localleader>lc", desc = "create label" },
          add_label = { lhs = "<localleader>la", desc = "add label" },
          remove_label = { lhs = "<localleader>ld", desc = "remove label" },
          goto_issue = { lhs = "<localleader>gi", desc = "navigate to a local repo issue" },
          add_comment = { lhs = "<localleader>ca", desc = "add comment" },
          delete_comment = { lhs = "<localleader>cd", desc = "delete comment" },
          next_comment = { lhs = "]c", desc = "go to next comment" },
          prev_comment = { lhs = "[c", desc = "go to previous comment" },
          react_hooray = { lhs = "<localleader>rp", desc = "add/remove 🎉 reaction" },
          react_heart = { lhs = "<localleader>rh", desc = "add/remove ❤️ reaction" },
          react_eyes = { lhs = "<localleader>re", desc = "add/remove 👀 reaction" },
          react_thumbs_up = { lhs = "<localleader>r+", desc = "add/remove 👍 reaction" },
          react_thumbs_down = { lhs = "<localleader>r-", desc = "add/remove 👎 reaction" },
          react_rocket = { lhs = "<localleader>rr", desc = "add/remove 🚀 reaction" },
          react_laugh = { lhs = "<localleader>rl", desc = "add/remove 😄 reaction" },
          react_confused = { lhs = "<localleader>rc", desc = "add/remove 😕 reaction" },
        },
        pull_request = {
          checkout_pr = { lhs = "<localleader>po", desc = "checkout PR" },
          merge_pr = { lhs = "<localleader>pm", desc = "merge commit PR" },
          squash_and_merge_pr = { lhs = "<localleader>psm", desc = "squash and merge PR" },
          list_commits = { lhs = "<localleader>pc", desc = "list PR commits" },
          list_changed_files = { lhs = "<localleader>pf", desc = "list PR changed files" },
          show_pr_diff = { lhs = "<localleader>pd", desc = "show PR diff" },
          add_reviewer = { lhs = "<localleader>va", desc = "add reviewer" },
          remove_reviewer = { lhs = "<localleader>vd", desc = "remove reviewer request" },
          close_issue = { lhs = "<localleader>ic", desc = "close PR" },
          reopen_issue = { lhs = "<localleader>io", desc = "reopen PR" },
          list_issues = { lhs = "<localleader>il", desc = "list open issues on same repo" },
          reload = { lhs = "<C-r>", desc = "reload PR" },
          open_in_browser = { lhs = "<C-b>", desc = "open PR in browser" },
          copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
          goto_file = { lhs = "gf", desc = "go to file" },
          add_assignee = { lhs = "<localleader>aa", desc = "add assignee" },
          remove_assignee = { lhs = "<localleader>ad", desc = "remove assignee" },
          create_label = { lhs = "<localleader>lc", desc = "create label" },
          add_label = { lhs = "<localleader>la", desc = "add label" },
          remove_label = { lhs = "<localleader>ld", desc = "remove label" },
          goto_issue = { lhs = "<localleader>gi", desc = "navigate to a local repo issue" },
          add_comment = { lhs = "<localleader>ca", desc = "add comment" },
          delete_comment = { lhs = "<localleader>cd", desc = "delete comment" },
          next_comment = { lhs = "]c", desc = "go to next comment" },
          prev_comment = { lhs = "[c", desc = "go to previous comment" },
          react_hooray = { lhs = "<localleader>rp", desc = "add/remove 🎉 reaction" },
          react_heart = { lhs = "<localleader>rh", desc = "add/remove ❤️ reaction" },
          react_eyes = { lhs = "<localleader>re", desc = "add/remove 👀 reaction" },
          react_thumbs_up = { lhs = "<localleader>r+", desc = "add/remove 👍 reaction" },
          react_thumbs_down = { lhs = "<localleader>r-", desc = "add/remove 👎 reaction" },
          react_rocket = { lhs = "<localleader>rr", desc = "add/remove 🚀 reaction" },
          react_laugh = { lhs = "<localleader>rl", desc = "add/remove 😄 reaction" },
          react_confused = { lhs = "<localleader>rc", desc = "add/remove 😕 reaction" },
        },
        review_thread = {
          goto_issue = { lhs = "<localleader>gi", desc = "navigate to a local repo issue" },
          add_comment = { lhs = "<localleader>ca", desc = "add comment" },
          add_suggestion = { lhs = "<localleader>sa", desc = "add suggestion" },
          delete_comment = { lhs = "<localleader>cd", desc = "delete comment" },
          next_comment = { lhs = "]c", desc = "go to next comment" },
          prev_comment = { lhs = "[c", desc = "go to previous comment" },
          select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
          select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
          close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
          react_hooray = { lhs = "<localleader>rp", desc = "add/remove 🎉 reaction" },
          react_heart = { lhs = "<localleader>rh", desc = "add/remove ❤️ reaction" },
          react_eyes = { lhs = "<localleader>re", desc = "add/remove 👀 reaction" },
          react_thumbs_up = { lhs = "<localleader>r+", desc = "add/remove 👍 reaction" },
          react_thumbs_down = { lhs = "<localleader>r-", desc = "add/remove 👎 reaction" },
          react_rocket = { lhs = "<localleader>rr", desc = "add/remove 🚀 reaction" },
          react_laugh = { lhs = "<localleader>rl", desc = "add/remove 😄 reaction" },
          react_confused = { lhs = "<localleader>rc", desc = "add/remove 😕 reaction" },
        },
        submit_win = {
          approve_review = { lhs = "<localleader>a", desc = "approve review" },
          comment_review = { lhs = "<localleader>m", desc = "comment review" },
          request_changes = { lhs = "<localleader>r", desc = "request changes review" },
          close_review_tab = { lhs = "<localleader>c", desc = "close review tab" },
        },
        review_diff = {
          add_review_comment = { lhs = "<localleader>ca", desc = "add a new review comment" },
          add_review_suggestion = { lhs = "<localleader>sa", desc = "add a new review suggestion" },
          focus_files = { lhs = "<leader>e", desc = "move focus to changed file panel" },
          toggle_files = { lhs = "<leader>b", desc = "hide/show changed files panel" },
          next_thread = { lhs = "]t", desc = "move to next thread" },
          prev_thread = { lhs = "[t", desc = "move to previous thread" },
          select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
          select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
          close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
          toggle_viewed = { lhs = "<leader><localleader>", desc = "toggle viewer viewed state" },
          goto_file = { lhs = "gf", desc = "go to file" },
        },
        file_panel = {
          next_entry = { lhs = "j", desc = "move to next changed file" },
          prev_entry = { lhs = "k", desc = "move to previous changed file" },
          select_entry = { lhs = "<cr>", desc = "show selected changed file diffs" },
          refresh_files = { lhs = "R", desc = "refresh changed files panel" },
          focus_files = { lhs = "<leader>e", desc = "move focus to changed file panel" },
          toggle_files = { lhs = "<leader>b", desc = "hide/show changed files panel" },
          select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
          select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
          close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
          toggle_viewed = { lhs = "<leader><localleader>", desc = "toggle viewer viewed state" },
        },
      },
    },
  },
}
