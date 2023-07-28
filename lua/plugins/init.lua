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
  { "seandewar/nvimesweeper", cmd = "Nvimesweeper" },
  {
    "EtiamNullam/deferred-clipboard.nvim",
    event = { "BufReadPost", "BufNewFile" },
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
    "rmagatti/gx-extended.nvim",
    keys = { "gx" },
    opts = {
      extensions = {
        {
          patterns = { "Cargo.toml" },
          match_to_url = function(line_string)
            local resource_name = string.match(line_string, "^([%S]+) =")
            local url = "https://lib.rs/crates/" .. resource_name

            return url
          end,
        },
      },
    },
  },
  { "runiq/neovim-throttle-debounce" },
  {
    "axkirillov/hbac.nvim",
    opts = {},
  },
}
