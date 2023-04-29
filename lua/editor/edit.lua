return {
  {
    "ggandor/leap-spooky.nvim",
    opts = {
      affixes = {
        remote = { window = "R", cross_window = "r" },
        magnetic = { window = "<C-r>", cross_window = "<C-S-R>" },
      },
    },
    event = "VeryLazy",
  },
  { -- sibling-swap.nvim
    "mizlan/iswap.nvim",
    opts = {
      autoswap = true,
      move_cursor = true,
    },
    cmd = { "ISwap", "ISwapWith", "ISwapNode", "ISwapNodeWith", "ISwapWithLeft", "ISwapWithRight" },
    keys = {
      { "<leader>ei" },
      { "<leader>ea", "<cmd>ISwapWith<cr>", desc = "ISwap" },
    },
    config = function(_, opts)
      require("iswap").setup(opts)
      require "hydra" {
        name = "ISwap",
        hint = "",
        config = {
          color = "red",
          invoke_on_body = false,
          hint = {
            border = "rounded",
            offset = -1,
          },
        },
        mode = "n",
        body = "<leader>ei",
        heads = {
          { "j", "<cmd>ISwapWithRight<cr>", { desc = "Right" } },
          { "k", "<cmd>ISwapWithLeft<cr>", { desc = "Left" } },
        },
      }
    end,
  },
  {
    -- "bennypowers/splitjoin.nvim",
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
      max_join_length = 9999999,
    },
    keys = {
      { "gs", function() require("treesj").toggle() end, desc = "SplitJoin" },
      { "<C-s>", function() require("treesj").toggle() end, desc = "SplitJoin", mode = "i" },
      { "<leader>es", function() require("treesj").split() end, desc = "Split" },
      { "<leader>ej", function() require("treesj").join() end, desc = "Join" },
    },
  },
  {
    "echasnovski/mini.align",
    event = "VeryLazy",
    opts = {},
    main = "mini.align",
  },
  {
    "echasnovski/mini.move",
    main = "mini.move",
    keys = {
      { "<M-h>", mode = "x" },
      { "<M-j>", mode = "x" },
      { "<M-k>", mode = "x" },
      { "<M-l>", mode = "x" },
      { "<C-M-h>", mode = "n" },
      { "<C-M-j>", mode = "n" },
      { "<C-M-k>", mode = "n" },
      { "<C-M-l>", mode = "n" },
      { "<leader>em", mode = { "n", "x" } },
    },
    opts = {
      mappings = {
        line_left = "<C-M-h>",
        line_right = "<C-M-l>",
        line_down = "<C-M-j>",
        line_up = "<C-M-k>",
      },
    },
    config = function(_, opts)
      require("mini.move").setup(opts)

      -- TODO: moving hydra mode
      require "hydra" {
        name = "Move Item",
        hint = false,
        config = {},
        mode = { "n" },
        body = "<leader>em",
        heads = {
          { "h", utils.partial(MiniMove.move_selection, "left"), {} },
          { "j", utils.partial(MiniMove.move_selection, "down"), {} },
          { "k", utils.partial(MiniMove.move_selection, "up"), {} },
          { "l", utils.partial(MiniMove.move_selection, "right"), {} },
          { "h", utils.partial(MiniMove.move_line, "left"), {} },
          { "j", utils.partial(MiniMove.move_line, "down"), {} },
          { "k", utils.partial(MiniMove.move_line, "up"), {} },
          { "l", utils.partial(MiniMove.move_line, "right"), {} },
        },
      }
      require "hydra" {
        name = "Move Item",
        hint = false,
        config = {},
        mode = { "x" },
        body = "<leader>em",
        heads = {
          { "h", utils.partial(MiniMove.move_selection, "left"), {} },
          { "j", utils.partial(MiniMove.move_selection, "down"), {} },
          { "k", utils.partial(MiniMove.move_selection, "up"), {} },
          { "l", utils.partial(MiniMove.move_selection, "right"), {} },
        },
      }
    end,
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
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    main = "mini.comment",
    opts = {
      mappings = {
        comment = "#",
        comment_line = "##",
        textobject = "i#",
      },

      -- Hook functions to be executed at certain stage of commenting
      hooks = {
        pre = function() require("ts_context_commentstring.internal").update_commentstring {} end,
      },
    },
  },
  {
    "johmsalas/text-case.nvim",
    config = function()
      -- Do NOT run setup, otherwise it creates default keybindings
      if false then
        require("textcase").setup {}
      else
        local hydra = require "hydra"

        local head = function(key, func, operator_name, desc)
          return {
            key,
            function() require("textcase")[func](operator_name) end,
            { desc = desc },
          }
        end

        local heads = function(op)
          return {
            head("_", op, "to_snake_case", "snake_case"),
            head("-", op, "to_dash_case", "dash-case"),
            head("C", op, "to_constant_case", "CONSTANT_CASE"),
            head(".", op, "to_dot_case", "dot.case"),
            head("c", op, "to_camel_case", "camelCase"),
            head("t", op, "to_title_case", "Title Case"),
            head("/", op, "to_path_case", "path/case"),
            head("s", op, "to_phrase_case", "Sentence case"),
            head("m", op, "to_pascal_case", "MixedCase"),

            { "<Esc>", nil, { exit = true } },
          }
        end

        hydra {
          config = { invoke_on_body = true },
          name = "Change case",
          mode = "n",
          body = "<leader>ec",
          heads = heads "quick_replace",
        }
        hydra {
          config = { invoke_on_body = true },
          name = "Change case LSP rename",
          mode = "n",
          body = "<leader>rc",
          heads = heads "lsp_rename",
        }
        hydra {
          config = { invoke_on_body = true },
          name = "Change case",
          mode = "x",
          body = "<leader>rc",
          heads = heads "visual",
        }
      end
    end,
    keys = { { "<leader>ec" }, { "<leader>rc", mode = { "x", "n" } } },
  },
}
