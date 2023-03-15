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
      {
        "s",
        function()
          local current_window = vim.fn.win_getid()
          require("leap").leap { target_windows = { current_window } }
        end,
        mode = "n",
        desc = "Leap",
      },
      {
        "z",
        function()
          local current_window = vim.fn.win_getid()
          require("leap").leap { target_windows = { current_window } }
        end,
        mode = "x",
        desc = "Leap",
      },
      {
        "z",
        function()
          local current_window = vim.fn.win_getid()
          require("leap").leap { target_windows = { current_window } }
        end,
        mode = "o",
        desc = "Leap",
      },
    },
    config = function() end,
  },
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
      vim.g.VM_leader = "\\"
      vim.g.VM_maps = {
        ["Find Under"] = "<M-n>",
        ["Find Next"] = "<M-n>",
        ["Find Prev"] = "<M-S-n>",
        ["Select All"] = vim.g.VM_leader .. "a",
        ["Find Subword Under"] = "<M-n>",
        ["Add Cursor Down"] = "<M-j>",
        ["Add Cursor Up"] = "<M-k>",
        ["Select Cursor Down"] = "<M-S-j>",
        ["Select Cursor Up"] = "<M-S-k>",
        ["Skip Region"] = "n",
        ["Remove Region"] = "N",
        ["Visual Cursors"] = vim.g.VM_leader .. vim.g.VM_leader,
        ["Visual Add"] = vim.g.VM_leader .. "v",
        ["Visual All"] = vim.g.VM_leader .. "a",
        ["Visual Regex"] = "/",
        ["Add Cursor At Pos"] = "<M-S-n>", -- TODO: better keymap for this?
        -- FIXME: Which key(?) is conflicting and making this not work, unless i type fast
        ["Find Operator"] = "m",
        -- ["Visual Find"] = "<M-f>",
        ["Undo"] = "u",
        ["Redo"] = "<C-r>",
        ["Reselect Last"] = vim.g.VM_leader .. vim.g.VM_leader,
      }

      local theme = "codedark"
      vim.g.VM_theme = theme
      -- vim.g.VM_leader = [[<leader>m]]
    end,
    config = function()
      require("which-key").register(
        { [vim.g.VM_leader .. "g"] = "which_key_ignore", [vim.g.VM_leader] = "which_key_ignore" },
        { mode = "n" }
      )
      vim.cmd.VMTheme(vim.g.VM_theme)
      local map = vim.keymap.set
      local feedkeys_ = vim.api.nvim_feedkeys
      local termcode = vim.api.nvim_replace_termcodes
      local function feedkeys(keys, o)
        if o == nil then
          o = "m"
        end
        feedkeys_(termcode(keys, true, true, true), o, false)
      end
      local function wrap_vm(prefix, vm, affix)
        prefix = prefix or ""
        local first = prefix .. "<Plug>(VM-" .. vm .. ")"
        if affix == nil then
          return first
        end
        return function()
          feedkeys(first, "m")
          -- Defer to avoid `<Plug>(VM-Hls)`
          vim.defer_fn(function()
            if type(affix) == "function" then
              affix = affix()
            end
            feedkeys(affix, "m")
          end, 100)
        end
      end
      -- map("x", "I", wrap_vm(nil, "Visual-Add", "i"), { remap = true })
      map("x", "I", wrap_vm(nil, "Visual-Add", "i"), { remap = true })
      map("x", "A", wrap_vm(nil, "Visual-Add", "a"), { remap = true })
      local c_v = termcode("<C-v>", true, true, true)
      map("x", "c", function()
        if vim.api.nvim_get_mode().mode == c_v then
          wrap_vm(nil, "Visual-Add", "c")()
          return ""
        else
          return '"_c'
        end
      end, { expr = true, remap = false })

      map("x", "<C-v>", "<Plug>(VM-Visual-Add)")
      -- map("x", "<C-v>", function()      -- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufNewFile" }, { command = "VMTheme " .. theme })
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
    -- "bennypowers/splitjoin.nvim",
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter" },
    opts = {
      use_default_keymaps = true,
    },
    keys = {
      {
        "<leader>ej",
        function()
          require("treesj").toggle()
        end,
        desc = "SplitJoin",
      },
      {
        "<leader>es",
        function()
          require("treesj").split()
        end,
        desc = "Split",
      },
      {
        "<leader>eJ",
        function()
          require("treesj").join()
        end,
        desc = "Join",
      },
    },
  },
  require "plugins.navedit.tsnodeaction",
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
  {
    "cbochs/portal.nvim",
    dependencies = {
      -- "cbochs/grapple.nvim", -- Optional: provides the "grapple" query item
      -- "ThePrimeagen/harpoon", -- Optional: provides the "harpoon" query item
    },
    opts = {
      portal = {
        window_options = {
          border = "none",
        },
      },
    },
    cmd = "Portal",
    keys = {
      {
        "<C-i>",
        function()
          require("portal.builtin").jumplist.tunnel_forward()
        end,
        desc = "portal fwd",
      },
      {
        "<C-o>",
        function()
          require("portal.builtin").jumplist.tunnel_backward()
        end,
        desc = "portal bwd",
      },
      -- TODO: use other queries?
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
        desc = "Treesitter SSR",
      },
    },
  },
}
