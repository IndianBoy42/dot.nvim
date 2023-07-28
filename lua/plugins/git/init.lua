return {
  {
    "f-person/git-blame.nvim",
    cond = false,
    init = function() vim.g.gitblame_enabled = 0 end,
    cmd = "GitBlameToggle",
    -- keys = { "<leader>gL", "<cmd>GitBlameToggle<cr>", desc = "Blame Toggle" },
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
  { "pwntester/octo.nvim", cmd = "Octo", opts = {} },
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
      mappings = {
        status = {
          s = "",
          S = "",
          a = "Stage",
          A = "StageUnstaged",
          ["<C-a"] = "StageAll",
          C = "CherryPickPopup",
          h = "Toggle", l = "Toggle"
        },
      },
    },
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
      on_attach = function(bufnr) require("plugins.git.keys").hydra(bufnr) end,
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
