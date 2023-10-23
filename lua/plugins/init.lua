return {
  {
    "IndianBoy42/remember-me.nvim",
    dev = true,
    opts = {
      project_roots = { ".git", ".svn", ".venv" },
    },
    lazy = false,
  },
  { import = "langs", cond = not vim.g.kitty_scrollback },
  { import = "editor" },
  { import = "ui" },
  { "tpope/vim-repeat", lazy = false },
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function() vim.g.startuptime_tries = 10 end,
  },
  { "nvim-lua/plenary.nvim" },

  {
    "famiu/bufdelete.nvim",
    cmd = { "Bdelete", "Bwipeout" },
    init = function() vim.cmd.cnoreabbrev "bd Bdelete" end,
  },
  { "jghauser/mkdir.nvim", event = "BufWritePre" },
  { "lambdalisue/suda.vim", cmd = { "SudaWrite", "SudaRead" } },
  {
    "tpope/vim-eunuch",
    cmd = {
      "Delete",
      "Unlink",
      "Move",
      "Rename",
      "Chmod",
      "Mkdir",
      "Cfind",
      "Clocate",
      "Lfind",
      "Wall",
      "SudoWrite",
      "SudoEdit",
    },
  },

  {
    "nacro90/numb.nvim",
    event = "CmdLineEnter",
    opts = {
      show_numbers = true, -- Enable 'number' for the window while peeking
      show_cursorline = true, -- Enable 'cursorline' for the window while peeking
    },
  },
  {
    "EtiamNullam/deferred-clipboard.nvim",
    event = "LazyFile",
    opts = {
      lazy = true,
      fallback = O.clipboard,
    },
  },
  {
    "krady21/compiler-explorer.nvim",
    cmd = {
      "CECompile",
      "CECompileLive",
      "CEFormat",
      "CEAddLibrary",
      "CELoadExample",
      "CEOpenWebsite",
      "CEDeleteCache",
      "CEShowTooltip",
      "CEGotoLabel",
    },
    opts = {},
  },
  -- TODO: https://github.com/chrisgrieser/nvim-recorder
  {
    "mrshmllow/open-handlers.nvim",
    -- We modify builtin functions, so be careful lazy loading
    lazy = false,
    cond = vim.ui.open ~= nil,
    config = function()
      local oh = require "open-handlers"

      oh.setup {
        -- In order, each handler is tried.
        -- The first handler to successfully open will be used.
        handlers = {
          oh.issue, -- A builtin which handles github and gitlab issues
          oh.commit, -- A builtin which handles git commits
          oh.native, -- Default native handler. Should always be last
        },
      }
    end,
  },
  { "runiq/neovim-throttle-debounce" },
  {
    "axkirillov/hbac.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
