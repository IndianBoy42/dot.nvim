local cmt_op = "#" -- TODO: use yc (you comment?) + more
return {
  comment_operator = cmt_op,
  {
    "ggandor/leap-spooky.nvim",
    dev = true,
    config = function()
      require("leap-spooky").setup {
        affixes = {
          remote = { all_windows = "r" },
          magnetic = {},
        },
        text_objects = (function()
          local objs =
            { "w", "W", "s", "p", "[", "]", "(", ")", "b", ">", "<", "t", "{", "}", "B", '"', "'", "`", "a", "f", "q" }
          local tbl = {}
          for _, v in ipairs(objs) do
            for _, p in ipairs { "i", "a" } do
              tbl[#tbl + 1] = p .. v
            end
          end
          return tbl
        end)(),
        custom_actions = {
          require("leap-spooky").yank_paste,
          -- {
          --
          --   function(kwargs, mapping)
          --
          --               end,
          -- },
        },
      }
    end,
    event = "VeryLazy",
  },
  { -- mizlan/iswap.nvim
    "IndianBoy42/iswap.nvim",
    dev = true,
    opts = {
      autoswap = true,
      move_cursor = true,
      only_current_line = false,
      debug = true,
      flash_style = "simultaneous",
    },
    cmd = {
      "ISwap",
      "ISwapWith",
      "ISwapWithLeft",
      "ISwapWithRight",
      "IMove",
      "IMoveWith",
      "ISwapNode",
      "ISwapNodeWith",
    },
    keys = {
      { "<leader>ei", desc = "ISwapIncr" },
      { "<leader>ea", "<cmd>ISwapWith<cr>", desc = "ISwap", mode = { "n" } },
      { "yx", "<cmd>ISwapWith<cr>", desc = "ISwap", mode = { "n" } },
      { "<leader>ea", "<cmd>ISwap<cr>", desc = "ISwap", mode = { "x" } },
      { "<leader>eA", "<cmd>ISwapWith<cr>", desc = "ISwap", mode = { "x" } },
      { "<leader>es", F 'require("iswap").iswap_node({ autoswap = false })', desc = "ISwapNode", mode = { "n", "x" } },
      { "yp", F 'require("iswap").iswap_node({ autoswap = false })', desc = "ISwapNode", mode = { "n" } },
      { "mm", "<cmd>IMoveWith<cr>", desc = "IMove", mode = { "n" } },
      { O.swap_prev, "<cmd>ISwapWithLeft<cr>", desc = "ISwap Left", mode = "n" },
      { O.swap_next, "<cmd>ISwapWithRight<cr>", desc = "ISwap Right", mode = "n" },
    },
    config = function(_, opts)
      require("iswap").setup(opts)
      require "hydra" {
        name = "ISwapIncr",
        hint = "",
        config = {
          color = "pink",
          invoke_on_body = true,
          hint = {
            border = "rounded",
            offset = -1,
          },
        },
        mode = "n",
        body = "<leader>ei",
        heads = {
          { "h", "<cmd>ISwapWithLeft<cr>", { desc = "Left" } },
          { "j", "<cmd>ISwapWithRight<cr>", { desc = "Right" } },
          { "k", "<cmd>ISwapWithLeft<cr>", { desc = "Left" } },
          { "l", "<cmd>ISwapWithRight<cr>", { desc = "Right" } },
          { "<esc>", "<esc>", { desc = "Exit", exit = true } },
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
      { "<C-s>", function() require("treesj").toggle() end, desc = "SplitJoin", mode = { "n", "i" } },
      { "<leader>eJ", function() require("treesj").split() end, desc = "Split" },
      { "<leader>ej", function() require("treesj").join() end, desc = "Join" },
    },
  },
  {
    "echasnovski/mini.align",
    opts = {},
    main = "mini.align",
    keys = { { "ga" } },
  },
  {
    "echasnovski/mini.move",
    main = "mini.move",
    keys = function()
      local keys = { "<M-h>", "<M-j>", "<M-k>", "<M-l>", "<C-M-h>", "<C-M-j>", "<C-M-k>", "<C-M-l>" }
      keys = { "<Left>", "<Down>", "<Up>", "<Right>", "<Left>", "<Down>", "<Up>", "<Right>" }
      return {
        { keys[1], mode = "x" },
        { keys[2], mode = "x" },
        { keys[3], mode = "x" },
        { keys[4], mode = "x" },
        { keys[5], mode = "n" },
        { keys[6], mode = "n" },
        { keys[7], mode = "n" },
        { keys[8], mode = "n" },
        { "m", mode = { "n", "x" } },
      }
    end,
    opts = {
      mappings = {
        left = "<Left>",
        right = "<Right>",
        down = "<Down>",
        up = "<Up>",
        line_left = "<Left>",
        line_right = "<Right>",
        line_down = "<Down>",
        line_up = "<Up>",
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
        body = "m",
        heads = {
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
        body = "m",
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
      vim.keymap.set("v", "<C-a>", m.inc_visual() .. "gv", { desc = "inc" })
      vim.keymap.set("v", "<C-x>", m.dec_visual() .. "gv", { desc = "dec" })
      vim.keymap.set("v", "g<C-a>", m.inc_gvisual() .. "gv", { desc = "inc" })
      vim.keymap.set("v", "g<C-x>", m.dec_gvisual() .. "gv", { desc = "dec" })
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
        comment = cmt_op,
        comment_line = cmt_op .. cmt_op:sub(-1),
        textobject = "i" .. cmt_op,
      },

      -- Hook functions to be executed at certain stage of commenting
      -- hooks = {
      --   pre = function() require("ts_context_commentstring.internal").update_commentstring {} end,
      -- },
    },
    config = function(_, opts)
      require("mini.comment").setup(opts)

      vim.keymap.set(
        "x",
        "<leader>" .. cmt_op,
        '"zy'
          .. "mz" -- Remember the original position
          .. "`<" -- Go back to the original position
          .. '"zP' -- Duplicate above
          .. "`[V`]" -- reselect original
          .. ":<C-u>lua MiniComment.operator('visual')<CR>" -- Comment it
          .. "`z", -- Go back to the original position
        { desc = "copy and comment" }
      )
    end,
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
            head("U", op, "to_upper_case", "UPPERCASE"),
            head("u", op, "to_lower_case", "lowercase"),
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
          body = "cu",
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
    keys = { { "cu", desc = "Change case" }, { "<leader>rc", desc = "Rename case", mode = { "x", "n" } } },
  },
}
