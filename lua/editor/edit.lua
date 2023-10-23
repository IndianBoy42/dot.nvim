local cmt_op = O.commenting.op
local cmt_vi = O.commenting.vi
local cmt_li = O.commenting.line
local cmt_to = O.commenting.obj
return {
  { -- mizlan/iswap.nvim
    "IndianBoy42/iswap.nvim",
    branch = "wip",
    dev = true,
    opts = {
      keys = O.hint_labels .. O.hint_labels:upper(),
      autoswap = false,
      move_cursor = true,
      only_current_line = false,
      debug = true,
      flash_style = "simultaneous",
    },
    cmd = {
      "ISwap",
      "ISwapTwo",
      "ISwapLeft",
      "ISwapRight",
      "IMove",
      "IMoveTwo",
      "ISwapList",
      "ISwapListTwo",
    },
    keys = {
      { "mx", "<cmd>ISwap<cr>", desc = "ISwapNodeWith", mode = { "n" } },
      -- { "mx", "<Plug>(ISwap)", desc = "ISwapNodeWith", mode = { "n" } },
      { "X", "<cmd>ISwap<cr>", desc = "ISwapNodeWith", mode = { "x" } },
      { "M", "<cmd>IMove<cr>", desc = "IMoveNodeWith", mode = { "x" } },
      { "mX", "<cmd>ISwapTwo<cr>", desc = "ISwapNode", mode = { "n" } },
      -- { "mm", F 'require("iswap").imove_node({ autoswap = false })', desc = "IMoveNode", mode = { "n" } },
      { "mm", "<cmd>IMove<cr>", desc = "IMove", mode = { "n" } },
    },
  },
  {
    -- "bennypowers/splitjoin.nvim",
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
      max_join_length = 120,
    },
    keys = {
      { "<C-s>", function() require("treesj").toggle() end, desc = "SplitJoin", mode = { "n", "i", "x" } },
      {
        "<C-S-s>",
        function() require("treesj").nested_toggle "flash" end,
        desc = "SplitJoin Nested",
        mode = { "n", "i", "x" },
      },
      -- TODO: make this a hydra for repeatability
      { "<leader>eJ", function() require("treesj").split() end, desc = "Split" },
      { "<leader>ej", function() require("treesj").join() end, desc = "Join" },
    },
  },
  {
    "echasnovski/mini.align",
    opts = {},
    main = "mini.align",
    keys = { { "ga", mode = { "n", "x" } } },
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
    -- config = function(_, opts)
    --   require("mini.move").setup(opts)
    --
    --   -- TODO: moving hydra mode
    --   require "hydra" {
    --     name = "Move Item",
    --     hint = false,
    --     config = {},
    --     mode = { "n" },
    --     body = "m",
    --     heads = {
    --       { "h", utils.partial(MiniMove.move_line, "left"), {} },
    --       { "j", utils.partial(MiniMove.move_line, "down"), {} },
    --       { "k", utils.partial(MiniMove.move_line, "up"), {} },
    --       { "l", utils.partial(MiniMove.move_line, "right"), {} },
    --     },
    --   }
    --   require "hydra" {
    --     name = "Move Item",
    --     hint = false,
    --     config = {},
    --     mode = { "x" },
    --     body = "<leader>m",
    --     heads = {
    --       { "h", utils.partial(MiniMove.move_selection, "left"), {} },
    --       { "j", utils.partial(MiniMove.move_selection, "down"), {} },
    --       { "k", utils.partial(MiniMove.move_selection, "up"), {} },
    --       { "l", utils.partial(MiniMove.move_selection, "right"), {} },
    --     },
    --   }
    -- end,
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
        comment = cmt_vi and "" or cmt_op,
        comment_line = cmt_li,
        textobject = cmt_to,
      },

      -- Hook functions to be executed at certain stage of commenting
      -- hooks = {
      --   pre = function() require("ts_context_commentstring.internal").update_commentstring {} end,
      -- },
    },
    config = function(_, opts)
      require("mini.comment").setup(opts)

      local map = vim.keymap.set
      map(
        "x",
        O.commenting.copy.vi,
        '"zy'
          .. "mz" -- Remember the original position
          .. "`<" -- Go back to the original position
          .. '"zP' -- Duplicate above
          .. "`[V`]" -- reselect original
          .. ":<C-u>lua MiniComment.operator('visual')<CR>" -- Comment it
          .. "`z", -- Go back to the original position
        { desc = "copy and comment" }
      )
      map("n", O.commenting.copy.op, utils.operatorfuncV_keys("<leader>" .. cmt_op), { desc = "copy and comment op" })
      map(
        "n",
        O.commenting.copy.op .. O.commenting.copy.op:sub(-1),
        "V<leader>" .. cmt_op,
        { desc = "copy and comment line" }
      )

      if cmt_vi then
        vim.keymap.set("x", cmt_vi, ":<c-u>lua MiniComment.operator('visual')<cr>", { desc = "Comment selection" })
        vim.keymap.set("n", cmt_op, function() return MiniComment.operator() end, { expr = true, desc = "Comment" })
      end
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
  {
    "smjonas/duplicate.nvim",
    opts = { operator = { visual_mode = "D", normal_mode = "yd", line = "ydd" } },
    keys = { { "yd" }, { "ydd" }, { mode = "x", "D" } },
    -- TODO: use this to implemented comment duplicated
  },
  {
    "gbprod/yanky.nvim",
    opts = {},
    config = function(_, opts)
      require("yanky").setup(opts)
      require("telescope").load_extension "yank_history"
    end,
    keys = {
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" } },
      { "dy", F "require'yanky'.history.delete(1)", mode = "n", desc = "Drop last yank from history" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" } },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" } },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" } },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" } },
      { "<C-p>", "<Plug>(YankyCycleForward)", mode = { "n", "x" }, desc = "Cycle paste backward" },
      -- TODO: Cycle hydra for no modifiers?
      { "<C-S-p>", "<Plug>(YankyCycleBackward)", mode = { "n", "x" }, desc = "Cycle paste forward" },
      { "<leader>sp", "<cmd>Telescope yank_history<CR>", mode = { "n", "x" }, desc = "Search yank history" },
      { "<leader>p", "<Plug>(YankyPutIndentAfterLinewise)", mode = "n", desc = "Put after line" },
      { "<leader>P", "<Plug>(YankyPutIndentBeforeLinewise)", mode = "n", desc = "Put before line" },
      { "yp", "<Plug>(YankyPutIndentAfterCharwise)", mode = "n", desc = "Put after char" },
      { "yP", "<Plug>(YankyPutIndentBeforeCharwise)", mode = "n", desc = "Put before char" },
      { "cp", '"+p', mode = "n", desc = "Clipboard p" },
      { "cP", '"+P', mode = "n", desc = "Clipboard P" },
      { "cy", '"+y', mode = "n", desc = "Clipboard y" },
      { "cyy", '"+yy', mode = "n", desc = "Clipboard yy" },
      { "cY", '"+Y', mode = "n", desc = "Clipboard Y" },
      { "cd", '"+d', mode = "n", desc = "Clipboard d" },
      { "cdd", '"+dd', mode = "n", desc = "Clipboard dd" },
      { "cD", '"+D', mode = "n", desc = "Clipboard D" },
      -- TODO: hydra
    },
  },
  {
    "echasnovski/mini.operators",
    main = "mini.operators",
    opts = {
      -- Evaluate text and replace with output
      evaluate = { prefix = "<leader>=" },
      sort = { prefix = "gs" },
      exchange = { prefix = "" },
      multiply = { prefix = "" },
      replace = { prefix = "" },
      -- Sort text
    },
    keys = {
      { "gs", mode = { "n", "x" }, desc = "Sort" },
      { "gss", mode = { "n" }, desc = "Sort line" },
      { "<leader>=", mode = { "n", "x" }, desc = "Evaluate" },
      { "<leader>==", mode = { "n" }, desc = "Evaluate line" },
    },
  },
}
