local function imm(obj)
  obj.lazy = false
  return obj
end
local function p(obj)
  obj.event = "VeryLazy"
  return obj
end
return {
  { import = "langs" },
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },
  { "nvim-lua/plenary.nvim" },

  -- {
  --   "numToStr/Comment.nvim",
  --   config = function()
  --     require("Comment").setup {
  --       mappings = {
  --         ---Includes `gcc`, `gcb`, `gc[count]{motion}` and `gb[count]{motion}`
  --         basic = true,
  --         ---Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
  --         extended = true,
  --         ---Includes gco, gcO, gcA
  --         extra = true,
  --       },
  --       toggler = { line = "gcc", block = "gCC" },
  --       opleader = { line = "gc", block = "gC" },
  --       -- pre_hook = function()
  --       --   return require("ts_context_commentstring.internal").calculate_commentstring()
  --       -- end,
  --     }
  --   end,
  --   keys = { "gc", "gC" },
  -- },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    opts = {
      hooks = {
        pre = function()
          require("ts_context_commentstring.internal").update_commentstring {}
        end,
      },
    },
    config = function(_, opts)
      require("mini.comment").setup(opts)
    end,
  },
  {
    "LudoPinelli/comment-box.nvim",
    keys = {
      { "<leader>nbl", "<cmd>CBlbox<r>", desc = "Left Box" },
      { "<leader>nbc", "<cmd>CBcbox<r>", desc = "Center Box" },
    },
  },
  {
    "famiu/bufdelete.nvim",
    cmd = { "Bdelete", "Bwipeout" },
    keys = {
      { "<leader>bc", "Bdelete!", desc = "Close" },
    },
  },
  {
    "monaqa/dial.nvim",
    config = function()
      -- local dial = require "dial"
      local dial_config = require "dial.config"
      local augend = require "dial.augend"

      -- table.insert(dial.config.searchlist.normal, "markup#markdown#header")

      dial_config.augends:register_group {
        default = {
          augend.integer.alias.decimal_int,
          augend.integer.alias.hex,
          augend.integer.alias.octal,
          augend.integer.alias.binary,
          augend.constant.alias.bool,
          augend.constant.alias.alpha,
          augend.constant.alias.Alpha,
          augend.semver.alias.semver,
          augend.date.alias["%Y/%m/%d"],
          augend.date.alias["%d/%m/%Y"],
          augend.date.alias["%Y-%m-%d"],
          augend.date.alias["%d-%m-%Y"],
        },
      }

      local m = require "dial.map"
      vim.keymap.set("n", "<C-a>", m.inc_normal(), { desc = "inc" })
      vim.keymap.set("n", "<C-x>", m.dec_normal(), { desc = "dec" })
      vim.keymap.set("v", "<C-a>", m.inc_visual(), { desc = "inc" })
      vim.keymap.set("v", "<C-x>", m.dec_visual(), { desc = "dec" })
      vim.keymap.set("v", "g<C-a>", m.inc_gvisual(), { desc = "inc" })
      vim.keymap.set("v", "g<C-x>", m.dec_gvisual(), { desc = "dec" })
    end,
    keys = {
      "<C-a>",
      "<C-x>",
      "<C-a>",
      "<C-x>",
      "g<C-a>",
      "g<C-x>",
    },
  },
  -- TODO: "is0n/fm-nvim",
  {
    "tzachar/local-highlight.nvim",
    opts = {},
    config = function(_, opts)
      require("local-highlight").setup(opts)
      -- vim.api.nvim_create_autocmd("BufRead", {
      --   pattern = { "*.*" },
      --   callback = function(data)
      --     require("local-highlight").attach(data.buf)
      --   end,
      -- })
    end,
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "nacro90/numb.nvim",
    event = "CmdLineEnter",
    opts = {
      show_numbers = true, -- Enable 'number' for the window while peeking
      show_cursorline = true, -- Enable 'cursorline' for the window while peeking
    },
  },
  { "rmagatti/auto-session", lazy = false },
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
  { "seandewar/nvimesweeper", cmd = "Nvimesweeper" },
  {
    "EtiamNullam/deferred-clipboard.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opt = { lazy = true, fallback = O.clipboard },
  },
  { "EricDriussi/remember-me.nvim", opts = {
    project_roots = { ".git", ".svn", ".venv" },
  } },
  { "johmsalas/text-case.nvim", opts = {} },
}
