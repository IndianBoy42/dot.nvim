return {
  {
    "phaazon/hop.nvim",
    dependencies = { "IndianBoy42/hop-extensions" },
    event = "VeryLazy",
    opts = {
      keys = O.hint_labels,
    },
    keys = function()
      local hop_pattern = {
        "<M-h>", -- "<M-CR>",
        "<CR><CMD>lua require'hop'.hint_patterns({}, vim.fn.getreg('/'))<CR>",
        mode = { "c" },
      }
      local hops = require "plugins.navedit.hops"
      local keys = { hop_pattern }
      for _, rhs_ in ipairs(hops) do
        local lhs, rhs, desc = unpack(rhs_)
        table.insert(keys, { "<leader>h" .. lhs, rhs, desc = desc })
      end
      return keys
    end,
  },
  {
    "ggandor/leap.nvim",
    keys = {
      { "s", mode = "n", desc = "Leap" },
    },
    config = function()
      -- require("leap").set_default_keymaps()
      -- Bidirectional leap
      vim.keymap.set("n", "s", function()
        local current_window = vim.fn.win_getid()
        require("leap").leap { target_windows = { current_window } }
      end)
    end,
  },
  { "ggandor/leap-spooky.nvim", opts = {}, event = "VeryLazy" },
  {
    "ggandor/leap-ast.nvim",
    keys = {
      {
        "S",
        function()
          require("leap-ast").leap()
        end,
        mode = { "n", "x", "o" },
      },
    },
  },
  {
    "ggandor/flit.nvim",
    -- TODO:
    -- dependencies = {
    --   {
    --     "jinh0/eyeliner.nvim",
    --     config = function()
    --       require("eyeliner").setup {
    --         highlight_on_key = true,
    --       }
    --     end,
    --   },
    -- },
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
      local theme = "codedark"
      vim.g.VM_theme = theme

      require("which-key").register({ [vim.g.VM_leader] = "which_key_ignore" }, { mode = "n" })

      -- vim.cmd.VMTheme(theme)
      -- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufNewFile" }, { command = "VMTheme " .. theme })
    end,
    event = { "BufReadPost", "BufNewFile" },
  },
  require "plugins.navedit.selectease",
  {
    "mfussenegger/nvim-ts-hint-textobject",
    config = function()
      local labels = {}
      O.hint_labels:gsub(".", function(c)
        vim.list_extend(labels, { c })
      end)
      require("tsht").config.hint_keys = labels -- Requires https://github.com/mfussenegger/nvim-ts-hint-textobject/pull/2
    end,
    -- event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "m", [[:<C-U>lua require('tsht').nodes()<CR>]], mode = "o" },
      { "m", [[:lua require('tsht').nodes()<CR>]], mode = "x" },
    },
    -- module = "tsht",
  },
  { -- sibling-swap.nvim
    "mizlan/iswap.nvim",
    opts = {
      autoswap = true,
    },
    cmd = { "ISwap", "ISwapWith", "ISwapNode", "ISwapNodeWith" },
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
        { "r", substitute "visual", mode = "x", desc = "Replace" },
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
        { "cx", exchange "operator", mode = "n", desc = "Exchange" },
        { "cxx", exchange "line", mode = "n", desc = "Exchange Line" },
        { "X", exchange "visual", mode = "x", desc = "Exchange" },
        { "cX", exchange "cancel", mode = "n", desc = "Exchange Cancel" },
      }
    end,
  },
  {
    "bennypowers/splitjoin.nvim",
    keys = {
      {
        "gJ",
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
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      return {
        n_lines = 500,
        custom_textobjects = require("plugins.navedit.ai").custom_textobjects(require "mini.ai"),
        search_method = "cover",
      }
    end,
    config = function(_, opts)
      local ai = require "mini.ai"
      ai.setup(opts)
      local make_nN_pair = mappings.make_nN_pair
      local map = function(prefix, textobj_id, side, name, ia, desc)
        local lp, rp = prefix, prefix
        if type(prefix) == "table" then
          lp, rp = unpack(prefix)
        else
        end
        local ln, rn = name, name
        if type(name) == "table" then
          ln, rn = unpack(name)
        end
        ia = ia or "a"
        name = name or textobj_id
        for _, mode in ipairs { "n", "x", "o" } do
          local lf = function()
            ai.move_cursor(side, ia, textobj_id, { search_method = "cover_or_prev" })
          end
          local rf = function()
            ai.move_cursor(side, ia, textobj_id, { search_method = "cover_or_next" })
          end
          local nf, pf = unpack(make_nN_pair { rf, lf })
          vim.keymap.set(mode, lp .. ln, pf, { desc = desc })
          vim.keymap.set(mode, rp .. rn, nf, { desc = desc })
        end
      end

      require("plugins.navedit.ai").jumps(map)

      local i = require("plugins.navedit.ai").legend

      local a = vim.deepcopy(i)
      for k, v in pairs(a) do
        a[k] = v:gsub(" including.*", "")
      end

      local ic = vim.deepcopy(i)
      local ac = vim.deepcopy(a)
      for key, name in pairs { n = "Next", l = "Last" } do
        i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
        a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
      end
      require("which-key").register {
        mode = { "o", "x" },
        i = i,
        a = a,
      }
    end,
  },
  {
    "echasnovski/mini.align",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      require("mini.align").setup(opts)
    end,
  },
  {
    "echasnovski/mini.move",
    keys = {
      { "<M-h>", mode = "x" },
      { "<M-j>", mode = "x" },
      { "<M-k>", mode = "x" },
      { "<M-l>", mode = "x" },
      { "<C-M-h>", mode = "n" },
      { "<C-M-j>", mode = "n" },
      { "<C-M-k>", mode = "n" },
      { "<C-M-l>", mode = "n" },
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
    end,
  },
  -- { -- TODO: mini.move
  --   "booperlv/nvim-gomove",
  --   opts = {
  --     -- whether or not to map default key bindings, (true/false)
  --     map_defaults = false,
  --     -- whether or not to reindent lines moved vertically (true/false)
  --     reindent = true,
  --     -- whether or not to undojoin same direction moves (true/false)
  --     undojoin = true,
  --     -- whether to not to move past end column when moving blocks horizontally, (true/false)
  --     move_past_end_col = true,
  --   },
  --   keys = {
  --     { "<C-M-h>", "<Plug>GoNSMLeft", mode = "n", desc = "Move Left" },
  --     { "<C-M-j>", "<Plug>GoNSMDown", mode = "n", desc = "Move Down" },
  --     { "<C-M-k>", "<Plug>GoNSMUp", mode = "n", desc = "Move Up" },
  --     { "<C-M-l>", "<Plug>GoNSMRight", mode = "n", desc = "Move Right" },
  --     { "<M-h>", "<Plug>GoVSMLeft", mode = "x", desc = "Move Left" },
  --     { "<M-j>", "<Plug>GoVSMDown", mode = "x", desc = "Move Down" },
  --     { "<M-k>", "<Plug>GoVSMUp", mode = "x", desc = "Move Up" },
  --     { "<M-l>", "<Plug>GoVSMRight", mode = "x", desc = "Move Right" },
  --     { "<C-M-S-h>", "<Plug>GoNSDLeft", mode = "n", desc = "Dup Left" },
  --     { "<C-M-S-j>", "<Plug>GoNSDDown", mode = "n", desc = "Dup Down" },
  --     { "<C-M-S-k>", "<Plug>GoNSDUp", mode = "n", desc = "Dup Up" },
  --     { "<C-M-S-l>", "<Plug>GoNSDRight", mode = "n", desc = "Dup Right" },
  --     { "<M-S-h>", "<Plug>GoVSDLeft", mode = "x", desc = "Dup Left" },
  --     { "<M-S-j>", "<Plug>GoVSDDown", mode = "x", desc = "Dup Down" },
  --     { "<M-S-k>", "<Plug>GoVSDUp", mode = "x", desc = "Dup Up" },
  --     { "<M-S-l>", "<Plug>GoVSDRight", mode = "x", desc = "Dup Right" },
  --   },
  -- },
  {
    "cbochs/portal.nvim",
    dependencies = {
      -- "cbochs/grapple.nvim", -- Optional: provides the "grapple" query item
      -- "ThePrimeagen/harpoon", -- Optional: provides the "harpoon" query item
    },
    opts = {
      portal = {
        title = {
          border = "none",
        },
        body = {
          border = "none",
        },
      },
    },
    keys = {
      {
        "<C-o>",
        function()
          require("portal").jump_forward()
        end,
        desc = "portal fwd",
      },
      {
        "<C-i>",
        function()
          require("portal").jump_backward()
        end,
        desc = "portal bwd",
      },
    },
  },
  {
    "cshuaimin/ssr.nvim",
    -- Calling setup is optional.
    opts = {
      border = "rounded",
      min_width = 50,
      min_height = 5,
      max_width = 120,
      max_height = 25,
      keymaps = {
        close = "q",
        next_match = "n",
        prev_match = "N",
        replace_confirm = "<cr>",
        replace_all = "<localleader><cr>",
      },
    },
    keys = {
      {
        "<leader>rr",
        function()
          require("ssr").open()
        end,
        mode = { "n", "v" },
      },
    },
  },
}
