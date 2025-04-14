local cmt_op = O.commenting.op
local cmt_vi = O.commenting.vi
local cmt_li = O.commenting.line
local cmt_to = O.commenting.obj
return {
  { -- mizlan/iswap.nvim
    "IndianBoy42/iswap.nvim",
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
    "IndianBoy42/treesj",
    dependencies = { "nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
      max_join_length = 120,
    },
    keys = {
      {
        "<C-s>",
        function() require("treesj").toggle() end,
        desc = "SplitJoin",
        mode = { "n", "i", "x" },
      },
      {
        "<leader>es",
        function() require("treesj").toggle() end,
        desc = "SplitJoin",
        mode = { "n", "x" },
      },
      {
        "<leader>ej",
        function() require("treesj").nested_toggle "flash" end,
        desc = "SplitJoin Nested",
        mode = { "n", "x" },
      },
      -- TODO: make this a hydra for repeatability
      -- { "<leader>eJ", function() require("treesj").split() end, desc = "Split" },
      -- { "<leader>ej", function() require("treesj").join() end, desc = "Join" },
    },
  },
  {
    "echasnovski/mini.align",
    opts = {},
    main = "mini.align",
    keys = { { "ga", mode = { "n", "x" }, desc = "Align" } },
  },
  {
    "echasnovski/mini.move",
    main = "mini.move",
    keys = function()
      local keys =
        { "<M-h>", "<M-j>", "<M-k>", "<M-l>", "<C-M-h>", "<C-M-j>", "<C-M-k>", "<C-M-l>" }
      keys = {
        "<S-Left>",
        "<S-Down>",
        "<S-Up>",
        "<S-Right>",
        "<S-Left>",
        "<S-Down>",
        "<S-Up>",
        "<S-Right>",
      }
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
        left = "<S-Left>",
        right = "<S-Right>",
        down = "<S-Down>",
        up = "<S-Up>",
        line_left = "<S-Left>",
        line_right = "<S-Right>",
        line_down = "<S-Down>",
        line_up = "<S-Up>",
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
          augend.constant.alias.bool, -- TODO: True, False
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
        comment_visual = cmt_vi,
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
        -- TODO: dot repeatable
        -- TODO: make it a function
        '"zy' -- Yank it
          .. "mz" -- Remember the original position
          .. "`<" -- Go back to the original position
          .. '"zP' -- Duplicate above
          .. "`[V`]" -- reselect original
          .. ":<C-u>lua MiniComment.operator('visual')<CR>" -- Comment it
          .. "`z",
        -- function()
        --   _G.__commenting_copy_opfunc = vim.schedule_wrap(function()
        --     local keys = '"zy' -- Yank it
        --       .. "mz" -- Remember the original position
        --       .. "`<" -- Go back to the original position
        --       .. '"zP' -- Duplicate above
        --       .. "`[V`]" -- reselect original
        --       .. ":<C-u>lua MiniComment.operator('visual')<CR>" -- Comment it
        --       .. "`z"
        --     vim.api.nvim_feedkeys(vim.keycode(keys), "n", false)
        --   end)
        --   vim.go.operatorfunc = "v:lua.__commenting_copy_opfunc"
        --   return "g@"
        -- end, -- Go back to the original position
        { desc = "copy and comment" }
      )
      map(
        "n",
        O.commenting.copy.op,
        -- TODO: dot repeatable
        utils.operatorfunc_Vkeys(O.commenting.copy.vi),
        { desc = "copy and comment op", expr = true }
      )
      map(
        "n",
        O.commenting.copy.line,
        "V" .. O.commenting.copy.vi,
        { remap = true, desc = "copy and comment line" }
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
        -- TODO: i need a better hint string
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
          -- TODO: the hint doesn't show properly
          config = { invoke_on_body = true },
          name = "Change case",
          mode = "n",
          body = "cu",
          heads = heads "quick_replace",
          color = "blue",
        }
        -- hydra {
        --   config = { invoke_on_body = true },
        --   name = "Change case LSP rename",
        --   mode = "n",
        --   body = "<leader>rc",
        --   heads = heads "lsp_rename",
        -- }
        hydra {
          config = { invoke_on_body = true },
          name = "Change case",
          mode = "x",
          body = "<leader>rc",
          heads = heads "visual",
          color = "blue",
        }
      end
    end,
    keys = {
      { "cu", desc = "Change case" },
      -- { "<leader>rc", desc = "Rename case", mode = { "x", "n" } },
    },
  },
  {
    "gbprod/yanky.nvim",
    opts = {
      system_clipboard = {
        clipboard_register = "+",
      },
      textobj = {
        enabled = true,
      },
    },
    config = function(_, opts) require("yanky").setup(opts) end,
    event = { "FocusLost", "FocusGained" }, -- To sync with clipboard
    keys = {
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" } },
      { "Y", '"+<Plug>(YankyYank)', mode = { "x" } },
      {
        "dy",
        F "require'yanky'.history.delete(1)",
        mode = "n",
        desc = "Drop last yank from history",
      },
      { "p", "<Plug>(YankyPutAfter)", mode = "n" },
      { "P", "<Plug>(YankyPutBefore)", mode = "n" },
      { "p", "<Plug>(YankyPutBefore)", mode = "x" },
      { "<leader>p", "<Plug>(YankyPutAfter)", mode = "x" },
      { "P", '"+<Plug>(YankyPutBefore)', mode = "x" },
      { "<leader>P", '"+<Plug>(YankyPutAfter)', mode = "x" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" } },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" } },
      { "<C-p>", "<Plug>(YankyCycleForward)", mode = { "n", "x" }, desc = "Cycle paste backward" },
      -- TODO: Cycle hydra for no modifiers?
      { "<M-p>", "<Plug>(YankyCycleBackward)", mode = { "n", "x" }, desc = "Cycle paste forward" },
      {
        "<leader>sp",
        "<cmd>Telescope yank_history<CR>",
        mode = { "n", "x" },
        desc = "Search yank history",
      },
      { "<leader>p", "<Plug>(YankyPutIndentAfterLinewise)", mode = "n", desc = "Put after line" },
      { "<leader>P", "<Plug>(YankyPutIndentBeforeLinewise)", mode = "n", desc = "Put before line" },
      { "yp", "<Plug>(YankyPutIndentAfterCharwise)", mode = "n", desc = "Put after char" },
      { "yP", "<Plug>(YankyPutIndentBeforeCharwise)", mode = "n", desc = "Put before char" },
      {
        "iy",
        function() require("yanky.textobj").last_put() end,
        mode = { "o", "x" },
        desc = "Last Put",
      },
      { "ay", "Viy", remap = true, mode = { "o", "x" }, desc = "Last VPut" },
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
    },
    config = function(_, opts)
      require("mini.operators").setup(opts)
      require("mini.operators").make_mappings(
        "multiply",
        { textobject = "yd", line = "ydd", selection = "D" }
      )
    end,
    keys = {
      { "gs", mode = { "n", "x" }, desc = "Sort" },
      { "gss", mode = { "n" }, desc = "Sort line" },
      { "<leader>=", mode = { "n", "x" }, desc = "Evaluate" },
      { "<leader>==", mode = { "n" }, desc = "Evaluate line" },
      { "yd", desc = "Duplicate" },
      { "ydd", desc = "Duplicate Line" },
      { "yD", "ydV", remap = true, desc = "Duplicate Linewise" },
      { mode = "x", "D", desc = "Duplicate" },
    },
  },
  {
    "gbprod/substitute.nvim",
    keys = function()
      -- Replace selection with register
      local substitute = function(fn, opts)
        return function()
          local substitute = require "substitute"
          substitute[fn](opts)
        end
      end
      -- Replace all in range
      local substitute_range = function(fn, opts)
        opts = vim.tbl_extend("keep", { group_substituted_text = true }, opts or {})
        return function()
          local range = require "substitute.range"
          range[fn](opts)
        end
      end
      local exchange = function(fn, opts)
        return function()
          local exchange = require "substitute.exchange"
          exchange[fn](opts)
        end
      end

      return {
        { "r", substitute "operator", mode = "n", desc = "Replace" },
        { "rr", substitute "line", mode = "n", desc = "Replace Line" },
        { "R", substitute "eol", mode = "n", desc = "Replace EOL" },

        { "cx", exchange "operator", mode = "n", desc = "Exchange" },
        { "cxx", exchange "line", mode = "n", desc = "Exchange Line" },
        { "x", exchange "visual", mode = "x", desc = "Exchange" },
        -- { "<leader>X", exchange "cancel", mode = "n", desc = "Cancel Exchange" },

        -- TODO: fuck these, just use vim-visual-multi?
        {
          "<leader>rI",
          substitute_range "operator",
          mode = "n",
          desc = "Replace all (motion1) in (motion2)",
        },
        {
          "<leader>rA",
          substitute_range("operator", { range = "%" }),
          mode = "n",
          desc = "Replace all (motion) in file",
        },
        {
          "<leader>ro",
          substitute_range "word",
          mode = "n",
          desc = "Replace all iw in (motion)",
        },
        {
          "<leader>rO",
          substitute_range("word", { range = "%" }),
          mode = "n",
          desc = "Replace all iw in file",
        },
        {
          "<leader>ro",
          substitute_range("visual", {}),
          mode = "x",
          desc = "Replace all (sel) in (motion)",
        },
        {
          "<leader>rO",
          substitute_range("visual", { range = "%" }),
          mode = "x",
          desc = "Replace all (sel) in file",
        },
      }
    end,
    config = function()
      local opts = {
        on_substitute = require("yanky.integration").substitute(),
        yank_substituted_text = true, -- TODO: a separate keymap for false
      }
      require("substitute").setup(opts)
    end,
  },
}
