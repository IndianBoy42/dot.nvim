return {
  {
    "phaazon/hop.nvim",
    dependencies = { "IndianBoy42/hop-extensions" },
    event = "VeryLazy",
    opts = {
      keys = O.hint_labels,
    },
    keys = function()
      -- local exts = require "hop-extensions"
      -- local hop_pattern = {
      --   "<M-h>", -- "<M-CR>",
      --   "<CR><CMD>lua require'hop'.hint_patterns({}, vim.fn.getreg('/'))<CR>",
      --   mode = { "c" },
      -- }
      -- local hops = {
      --   -- ["/"] = { prefix .. "hint_patterns({}, vim.fn.getreg('/'))<cr>", "Last Search" },
      --   -- g = { exts.hint_localsgd, "Go to Definition of" },
      --   ["/"] = {
      --     function()
      --       exts.hint_patterns({}, vim.fn.getreg "/")
      --     end,
      --     desc = "Last Search",
      --   },
      --   w = { exts.hint_words, desc = "Words" },
      --   L = { exts.hint_lines_skip_whitespace, desc = "Lines" },
      --   l = { exts.hint_vertical, desc = "Lines Column" },
      --   ["*"] = { exts.hint_cword, desc = "cword" },
      --   W = { exts.hint_cWORD, desc = "cWORD" },
      --   h = { exts.hint_locals, desc = "Locals" },
      --   d = { exts.hint_definitions, desc = "Definitions" },
      --   r = { exts.hint_references, desc = "References" },
      --   u = {
      --     function()
      --       exts.hint_references "<cword>"
      --     end,
      --     desc = "Usages",
      --   },
      --   s = { exts.hint_scopes, desc = "Scopes" },
      --   t = { exts.hint_textobjects, desc = "Textobjects" },
      --   b = { require("hop-extensions.lsp").hint_symbols, desc = "LSP Symbols" },
      --   g = { require("hop-extensions.lsp").hint_diagnostics, desc = "LSP Diagnostics" },
      --   -- f = { prefix .. "hint_textobjects{query='function'}<cr>", "Functions" },
      --   -- a = { prefix .. "hint_textobjects{query='parameter'}<cr>", "parameter" },
      -- }
      -- for k, v in pairs(O.treesitter.textobj_suffixes) do
      --   -- hops[v[1]] = hops[v[1]] or { prefix .. "hint_textobjects{query='" .. k .. "'}<cr>", "@" .. k }
      --   hops[v[1]] = hops[v[1]]
      --       or {
      --         function()
      --           exts.hint_textobjects { query = k }
      --         end,
      --         "@" .. k,
      --       }
      -- end
      -- local keys = { hop_pattern }
      -- for key, rhs in pairs(keys) do
      --   table.insert(keys, { key, rhs })
      -- end
      -- return keys
    end,
  },
  {
    "ggandor/leap.nvim",
    keys = {
      { "s",  mode = { "n", "x", "o" }, desc = "Leap forward to" },
      { "S",  mode = { "n", "x", "o" }, desc = "Leap backward to" },
      { "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
    },
    config = function()
      require("leap").set_default_keymaps()
      -- Bidirectional leap
      vim.keymap.set("n", "s", function()
        local current_window = vim.fn.win_getid()
        require("leap").leap { target_windows = { current_window } }
      end)
    end,
  },
  { "ggandor/leap-spooky.nvim", event = "VeryLazy" },
  {
    "ggandor/leap-ast.nvim",
    keys = {
      {
        "<M-s>",
        function()
          require("leap-ast").leap()
        end,
      },
    },
  },
  {
    "ggandor/flit.nvim",
    keys = function()
      local ret = {}
      for _, key in ipairs { "f", "F", "t", "T" } do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
      end
      return ret
    end,
    opts = { labeled_modes = "nx" },
  },
  {
    "mg979/vim-visual-multi",
    init = function()
      vim.g.VM_maps = nil
      vim.g.VM_maps = {
        ["Find Under"] = "<M-n>",
        ["Select All"] = "<M-a>",
        ["Find Subword Under"] = "<M-n>",
        ["Add Cursor Down"] = "<M-j>",
        ["Add Cursor Up"] = "<M-k>",
        ["Select Cursor Down"] = "<M-S-j>",
        ["Select Cursor Up"] = "<M-S-k>",
        ["Skip Region"] = "n",
        ["Remove Region"] = "N",
        ["Visual Cursors"] = "<M-c>",
        ["Visual Add"] = "<M-a>",
        ["Visual All"] = "<M-S-a>",
        ["Start Regex Search"] = "<M-/>",
        ["Visual Regex"] = "/",
        ["Add Cursor At Pos"] = "<M-S-n>", -- TODO: better keymap for this?
        -- FIXME: Which key(?) is conflicting and making this not work, unless i type fast
        ["Find Operator"] = "m",
        ["Visual Find"] = "<M-f>",
        ["Undo"] = "u",
        ["Redo"] = "<C-r>",
      }
      vim.g.VM_leader = [[<leader>m]]
      -- vim.g.VM_leader = [[\]]
      vim.g.VM_theme = "neon"

      require("which-key").register({ [vim.g.VM_leader] = "which_key_ignore" }, { mode = "n" })
    end,
    event = { "BufReadPost", "BufNewFile" },
  },
  require "plugins.navedit.selectease",
  {
    "mfussenegger/nvim-ts-hint-textobject",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local labels = {}
      O.hint_labels:gsub(".", function(c)
        vim.list_extend(labels, { c })
      end)
      require("tsht").config.hint_keys =
          labels -- Requires https://github.com/mfussenegger/nvim-ts-hint-textobject/pull/2
    end,
    -- module = "tsht",
  },
  { -- sibling-swap.nvim
    "mizlan/iswap.nvim",
    opts = {
      autoswap = true,
    },
    cmd = { "ISwap", "ISwapWith" },
  },
  {
    "gbprod/substitute.nvim",
    opts = {},
    keys = function()
      local substitute = function(fn, opts)
        return function()
          local substitute = require "substitute"
          substitute[fn](opts)
        end
      end
      local substitute_range = function(fn, opts)
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
        {
          "rr",
          substitute "line",
          mode = "n",
          desc = "Replace Line",
        },
        {
          "R",
          substitute "eol",
          mode = "n",
          desc = "Replace EOL",
        },
        { "r", substitute "visual",   mode = "x", desc = "Replace" },
        {
          "<leader>c",
          substitute_range "operator",
          mode = "n",
          desc = "Replace all",
        },
        {
          "<leader>c",
          substitute_range "visual",
          mode = "x",
          desc = "Replace all",
        },
        {
          "<leader>cc",
          substitute_range "word",
          mode = "n",
          desc = "R all this word",
        },
        { "<leader>C", substitute_range("operator", { motion2 = "iG" }), mode = "n", desc = "R all all" },
        { "cx",        exchange "operator",                              mode = "n", desc = "Exchange" },
        { "cxx",       exchange "line",                                  mode = "n", desc = "Exchange Line" },
        { "X",         exchange "visual",                                mode = "x", desc = "Exchange" },
        { "cX",        exchange "cancel",                                mode = "n", desc = "Exchange Cancel" },
      }
    end,
  },
  {
    "bennypowers/splitjoin.nvim",
    keys = {
      {
        "J",
        function()
          require("splitjoin").join()
        end,
        desc = "Join the object under cursor",
      },
      {
        "gs",
        function()
          require("splitjoin").split()
        end,
        desc = "Split the object under cursor",
      },
    },
  },
  -- TODO: https://github.com/gbprod/yanky.nvim
  { -- TODO: mini.move
    "booperlv/nvim-gomove",
    opts = {
      -- whether or not to map default key bindings, (true/false)
      map_defaults = false,
      -- whether or not to reindent lines moved vertically (true/false)
      reindent = true,
      -- whether or not to undojoin same direction moves (true/false)
      undojoin = true,
      -- whether to not to move past end column when moving blocks horizontally, (true/false)
      move_past_end_col = true,
    },
    keys = {
      { "<C-M-h>",   "<Plug>GoNSMLeft",  mode = "n", desc = "Move Left" },
      { "<C-M-j>",   "<Plug>GoNSMDown",  mode = "n", desc = "Move Down" },
      { "<C-M-k>",   "<Plug>GoNSMUp",    mode = "n", desc = "Move Up" },
      { "<C-M-l>",   "<Plug>GoNSMRight", mode = "n", desc = "Move Right" },
      { "<M-h>",     "<Plug>GoVSMLeft",  mode = "x", desc = "Move Left" },
      { "<M-j>",     "<Plug>GoVSMDown",  mode = "x", desc = "Move Down" },
      { "<M-k>",     "<Plug>GoVSMUp",    mode = "x", desc = "Move Up" },
      { "<M-l>",     "<Plug>GoVSMRight", mode = "x", desc = "Move Right" },
      { "<C-M-S-h>", "<Plug>GoNSDLeft",  mode = "n", desc = "Dup Left" },
      { "<C-M-S-j>", "<Plug>GoNSDDown",  mode = "n", desc = "Dup Down" },
      { "<C-M-S-k>", "<Plug>GoNSDUp",    mode = "n", desc = "Dup Up" },
      { "<C-M-S-l>", "<Plug>GoNSDRight", mode = "n", desc = "Dup Right" },
      { "<M-S-h>",   "<Plug>GoVSDLeft",  mode = "x", desc = "Dup Left" },
      { "<M-S-j>",   "<Plug>GoVSDDown",  mode = "x", desc = "Dup Down" },
      { "<M-S-k>",   "<Plug>GoVSDUp",    mode = "x", desc = "Dup Up" },
      { "<M-S-l>",   "<Plug>GoVSDRight", mode = "x", desc = "Dup Right" },
    },
  },
}
