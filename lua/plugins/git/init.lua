return {
  {
    "f-person/git-blame.nvim",
    init = function()
      vim.g.gitblame_enabled = 0
    end,
    cmd = "GitBlameToggle",
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
    opts = function()
      local gitsigns_fn = require "gitsigns"
      local actions = require "diffview.actions"

      return {
        key_bindings = require("plugins.git.keys").hydra(actions),
      }
    end,
    ft = "diff",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  },
  require "plugins.git.fugitive",
  -- https://github.com/anuvyklack/hydra.nvim/wiki/Git
}
