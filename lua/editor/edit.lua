return {
  {
    "ggandor/leap-spooky.nvim",
    opts = {
      affixes = {
        remote = { window = "r", cross_window = "R" },
        magnetic = { window = "<C-r>", cross_window = "<C-S-R>" },
      },
    },
    event = "VeryLazy",
  },
  { -- sibling-swap.nvim
    "mizlan/iswap.nvim",
    opts = {
      autoswap = true,
    },
    cmd = { "ISwap", "ISwapWith", "ISwapNode", "ISwapNodeWith" },
  },
  {
    -- "bennypowers/splitjoin.nvim",
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
    },
    keys = {
      { "gs", function() require("treesj").toggle() end, desc = "SplitJoin" },
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
      { "<leader>em" },
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
        comment = "<c-c>",
        comment_line = "<c-c><c-c>",
        textobject = "i/",
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

        local head = function(key, operator_name, desc)
          return {
            key,
            function() require("textcase").operator(operator_name) end,
            { desc = desc },
          }
        end

        hydra {
          config = {
            exit = true,
          },
          name = "Change case",
          mode = "n",
          body = "gyc",
          heads = {
            head("_", "to_snake_case", "snake_case"),
            head("-", "to_dash_case", "dash-case"),
            head("C", "to_constant_case", "CONSTANT_CASE"),
            head(".", "to_dot_case", "dot.case"),
            head("c", "to_camel_case", "camelCase"),
            head("t", "to_title_case", "Title Case"),
            head("/", "to_path_case", "path/case"),
            head("s", "to_phrase_case", "Sentence case"),
            head("m", "to_pascal_case", "MixedCase"),

            { "<Esc>", nil, { exit = true } },
          },
        }
      end
    end,
    keys = "gyc",
  },
}
