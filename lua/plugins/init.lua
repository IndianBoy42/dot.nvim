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
      -- -- Toggle comments
      -- -- map("x", "gt", ":normal gcc<CR>", nore)
      -- -- map("x", "gt", ":normal :lua require'Comment'.toggle()<C-v><CR><CR>", nore)
      -- map("x", "gt", ":g/./lua require('Comment.api').toggle_current_linewise(cfg)<CR><cmd>nohls<CR>", nore)
      -- map("n", "gt", operatorfunc_keys("toggle_comment", "gt"), sile)

      require("mini.comment").setup(opts)
    end,
  },
  {
    "LudoPinelli/comment-box.nvim",
    keys = {
      { "<leader>nbl", "<cmd>CBlbox", desc = "Left Box" },
      { "<leader>nbc", "<cmd>CBcbox", desc = "Center Box" },
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
    end,
    keys = {
      {
        "<C-a>",
        function()
          require("dial.map").inc_normal()
        end,
        mode = { "n" },
      },
      {
        "<C-x>",
        function()
          require("dial.map").dec_normal()
        end,
        mode = { "n" },
      },
      {
        "<C-a>",
        function()
          require("dial.map").inc_visual()
        end,
        mode = { "v" },
      },
      {
        "<C-x>",
        function()
          require("dial.map").dec_visual()
        end,
        mode = { "v" },
      },
      {
        "g<C-a>",
        function()
          require("dial.map").inc_gvisual()
        end,
        mode = { "v" },
      },
      {
        "g<C-x>",
        function()
          require("dial.map").dec_gvisual()
        end,
        mode = { "v" },
      },
    },
  },
  -- TODO: "is0n/fm-nvim",
  {
    "tzachar/local-highlight.nvim",
    config = function()
      require("local-highlight").setup {}
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
  { "rmagatti/auto-session", event = "VeryLazy" },
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup(O.plugin.project_nvim)

      require("telescope").load_extension "projects"
    end,
    cmd = "ProjectRoot",
    keys = {
      { "<leader>pR", "<cmd>ProjectRoot<cr>",        desc = "Rooter" },
      { "<leader>pP", "<cmd>Telescope projects<cr>", desc = "T Projects" },
    },
  },
  { "jghauser/mkdir.nvim",  event = "BufWritePre" },
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
    "max397574/better-escape.nvim",
    opts = {
      mapping = { "jk", "kj" },
      keys = "<Esc>",
    },
    event = "InsertEnter",
  },
  -- "liangxianzhe/nap.nvim"
  -- { "zdcthomas/yop.nvim" }
  { "seandewar/nvimesweeper", cmd = "Nvimesweeper" },
  {
    "EtiamNullam/deferred-clipboard.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opt = { lazy = true, fallback = O.clipboard },
  },
  { "EricDriussi/remember-me.nvim", opts = {
    project_roots = { ".git", ".svn", ".venv" },
  } },
}
