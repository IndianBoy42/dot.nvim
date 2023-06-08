local function imm(obj)
  obj.lazy = false
  return obj
end
local function p(obj)
  obj.event = "VeryLazy"
  return obj
end
return {
  {
    "EricDriussi/remember-me.nvim",
    opts = {
      project_roots = { ".git", ".svn", ".venv" },
    },
    lazy = false,
  },
  { import = "langs" },
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
    "ahmedkhalf/project.nvim",
    opts = {
      -- Manual mode doesn't automatically change your root directory, so you have
      -- the option to manually do so using `:ProjectRoot` command.
      manual_mode = true,
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
    config = function(_, opts)
      require("project_nvim").setup(opts)

      require("telescope").load_extension "projects"
    end,
    cmd = "ProjectRoot",
    keys = {
      { "<leader>pR", "<cmd>ProjectRoot<cr>", desc = "Rooter" },
      { "<leader>pP", "<cmd>Telescope projects<cr>", desc = "T Projects" },
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
}
