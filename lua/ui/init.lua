return {
  { -- "folke/which-key.nvim",
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        presets = {
          operators = true, -- adds help for operators like d, y,...
          motions = true, -- adds help for motions
          text_objects = true, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling and others prefixed with z
          g = true, -- bindings for prefixed with g
        },
      },
      operators = { ["yc"] = "Comments", r = "Replace", cx = "Exchange" },
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
      },
      window = {
        border = "rounded", -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 0, 0, 0, 0 }, -- extra window margin [top, right, bottom, left] padding = { 0, 0, 0, 0 }, -- extra window padding [top, right, bottom, left]
      },
      layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
      },
      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ ", "<Plug>" }, -- hide mapping boilerplate
      show_help = true, -- show help message on the command line when the popup is visible
    },
    config = function(_, opts)
      require("which-key").setup(opts)
      mappings.setup()
    end,
  },
  { -- "SmiteshP/nvim-navbuddy",
    "SmiteshP/nvim-navbuddy",
    dependencies = {
      "SmiteshP/nvim-navic",
    },
    opts = {
      lsp = { auto_attach = true },
    },
    lazy = false,
    cmd = { "Navbuddy" },
  },
  { -- "aznhe21/actions-preview.nvim",
    "aznhe21/actions-preview.nvim",
    config = function()
      require("actions-preview").setup {
        telescope = require("utils.telescope").cursor_menu(),
        highlight_command = {
          require("actions-preview.highlight").delta(),
          -- require("actions-preview.highlight").diff_so_fancy(),
          -- require("actions-preview.highlight").diff_highlight(),
        },
      }
    end,
    -- TODO: https://github.com/jan-xyz/lsp-preview.nvim/tree/main
  },
  -- TODO: dressing.nvim
  {
    "stevearc/dressing.nvim",
    opts = {
      select = { backend = "telescope" },
    },
  },
  {
    "smjonas/live-command.nvim",
    main = "live-command",
    event = "CmdlineEnter",
    opts = {
      commands = {
        Norm = { cmd = "norm" },
        Glive = { cmd = "g" },
        Dlive = { cmd = "d" },
        Qlive = {
          cmd = "norm",
          -- This will transform ":5Qlive a" into ":norm 5@a"
          args = function(opts)
            local reg = opts.fargs and opts.fargs[1] or "q"
            local count = opts.fargs and opts.fargs[2] or (opts.count == -1 and "" or opts.count)
            return count .. "@" .. reg
          end,
          range = "",
        },
      },
    },
  },
  { -- "kosayoda/nvim-lightbulb",
    "kosayoda/nvim-lightbulb",
    cond = false,
    config = function()
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        callback = function() require("nvim-lightbulb").update_lightbulb() end,
      })
    end,
    event = { "CursorHold", "CursorHoldI" },
  },
  { -- "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    "IndianBoy42/lsp_lines.nvim",
    config = function() require("lsp_lines").setup() end,
    event = "LazyFile",
    keys = {
      {
        "<leader>Tl",
        utils.lsp.toggle_diag_lines,
        desc = "Toggle lsp_lines",
      },
    },
  },
  { -- "nvim-treesitter/nvim-treesitter-context",
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = {},
  },
  { -- "haringsrob/nvim_context_vt",
    "haringsrob/nvim_context_vt",
    event = "LazyFile",
    opts = {
      prefix = "⤸",
      -- "󱞿",
      highlight = "DiagnosticVirtualTextInfo",
    },
  },
  { -- "echasnovski/mini.animate",
    "echasnovski/mini.animate",
    main = "mini.animate",
    cond = false and not vim.g.neovide,
    event = "VeryLazy",
    opts = function()
      -- don't use animate when scrolling with the mouse
      local mouse_scrolled = false
      for _, scroll in ipairs { "Up", "Down" } do
        local key = "<ScrollWheel" .. scroll .. ">"
        vim.keymap.set({ "", "i" }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      local animate = require "mini.animate"
      return {
        cursor = {
          timing = animate.gen_timing.linear { duration = 50, unit = "total" },
        },
        resize = {
          enable = false,
          -- timing = animate.gen_timing.linear { duration = 5, unit = "total" },
        },
        close = {
          timing = animate.gen_timing.linear { duration = 50, unit = "total" },
        },
        open = {
          timing = animate.gen_timing.linear { duration = 50, unit = "total" },
        },
        scroll = {
          timing = animate.gen_timing.linear { duration = 50, unit = "total" },
          subscroll = animate.gen_subscroll.equal {
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          },
        },
      }
    end,
  },
  -- {
  --   "karb94/neoscroll.nvim",
  --   opts = {
  --     -- All these keys will be mapped to their corresponding default scrolling animation
  --     mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
  --     hide_cursor = false, -- Hide cursor while scrolling
  --     stop_eof = false, -- Stop at <EOF> when scrolling downwards
  --     respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
  --     cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
  --     easing_function = "sine", -- Default easing function
  --   },
  --   cond = false,
  -- },

  { -- "ElPiloto/significant.nvim",
    "ElPiloto/significant.nvim",
  },
  -- TODO: https://github.com/DNLHC/glance.nvim
  -- TODO: https://github.com/stevearc/qf_helper.nvim
  -- TODO: https://github.com/shellRaining/hlchunk.nvim
  -- TODO: { "amrbashir/nvim-docs-view" },
  {
    "tzachar/highlight-undo.nvim",
    opts = {},
  },
  {
    "Grazfather/blinker.nvim",
    opts = {
      count = 1,
    },
    init = function()
      -- local lastwin = nil
      -- local f, t
      -- vim.api.nvim_create_autocmd({ "WinEnter", "FocusGained" }, {
      --   group = vim.api.nvim_create_augroup("blinker", {}),
      --   callback = function()
      --     if not f then
      --       f, t = require("throttle-debounce").throttle_trailing(
      --         function() require("blinker").blink_cursorline() end,
      --         1000,
      --         true
      --       )
      --     end
      --
      --     local win = vim.api.nvim_get_current_win()
      --     if lastwin ~= win then
      --       lastwin = win
      --       f()
      --     end
      --   end,
      -- })
    end,
  },
  -- TODO: https://github.com/notomo/cmdbuf.nvim
  {
    "notomo/cmdbuf.nvim",
    config = function(_, opts)
      local cmdbuf = require "cmdbuf"
      local map = vim.keymap.set
      local split_open = function(h, opts)
        return function() cmdbuf.split_open(h or vim.o.cmdwinheight, opts) end
      end
      map("n", "q:", split_open(nil), { desc = "Cmdwin" })
      map("n", "q/", split_open(nil, { type = "vim/search/forward" }), { desc = "Cmdwin Search Forward" })
      map("n", "q?", split_open(nil, { type = "vim/search/backward" }), { desc = "Cmdwin Search Backward" })
      map("n", "ql", split_open(nil, { type = "lua/cmd" }), { desc = "Cmdwin Lua" })
      map("c", "<c-f>", function()
        require("cmdbuf").split_open(vim.o.cmdwinheight, { line = vim.fn.getcmdline(), column = vim.fn.getcmdpos() })
        vim.api.nvim_feedkeys(vim.keycode "<C-c>", "n", true)
      end)

      -- Custom buffer mappings
      vim.api.nvim_create_autocmd({ "User" }, {
        group = vim.api.nvim_create_augroup("cmdbuf_setting", {}),
        pattern = { "CmdbufNew" },
        callback = function(args)
          vim.bo.bufhidden = "wipe" -- if you don't need previous opened buffer state
          map("n", "q", [[<Cmd>quit<CR>]], { nowait = true, buffer = true })
          map("n", "dd", [[<Cmd>lua require('cmdbuf').delete()<CR>]], { buffer = true })

          -- you can filter buffer lines
          local lines = vim.tbl_filter(
            function(line) return line ~= "q" end,
            vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
          )
          vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
        end,
      })

      -- open lua command-line window
      -- q/, q? alternative
    end,
    keys = { "q:", "q/", "q?", "ql", { "<C-f>", mode = "c" } },
  },
  {
    "Aasim-A/scrollEOF.nvim",
    opts = {},
  },
  {
    "winston0410/range-highlight.nvim",
    event = "CmdlineEnter",
    dependencies = { "winston0410/cmd-parser.nvim" },
    opts = {},
  },
  { "seandewar/nvimesweeper", cmd = "Nvimesweeper" },
  -- TODO: https://github.com/altermo/nwm
  --  could be useful for showing zathura pdf inside nvim? but why?
}
