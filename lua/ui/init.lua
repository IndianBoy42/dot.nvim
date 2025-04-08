return {
  { -- "folke/which-key.nvim",
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      -- FIXME: hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ ", "<Plug>" }, -- hide mapping boilerplate
    },
    config = function(_, opts)
      require("which-key").setup(opts)
      mappings.setup()
    end,
    keys = {
      {
        "<leader>?",
        function() require("which-key").show { global = false } end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
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
  { -- "IndianBoy42/actions-preview.nvim",
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
      },
    },
    config = function(_, opts)
      require("live-command").setup(opts)
      -- Transforms ":5Reg a" into ":norm 5@a"
      local function get_command_string(cmd)
        local get_range_string = require("live-command").get_range_string
        local args = (cmd.count == -1 and "" or cmd.count) .. "@" .. cmd.args
        return get_range_string(cmd) .. "norm " .. args
      end

      vim.api.nvim_create_user_command("Reg", function(cmd) vim.cmd(get_command_string(cmd)) end, {
        nargs = "?",
        range = true,
        preview = function(cmd, preview_ns, preview_buf)
          local cmd_to_preview = get_command_string(cmd)
          return require("live-command").preview_callback(cmd_to_preview, preview_ns, preview_buf)
        end,
      })
    end,
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
      map("c", "<M-e>", function()
        require("cmdbuf").split_open(vim.o.cmdwinheight, { line = vim.fn.getcmdline(), column = vim.fn.getcmdpos() })
        vim.api.nvim_feedkeys(vim.keycode "<C-c>", "n", true)
      end, { desc = "Open in cmdwin" })

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
  {
    "joshuadanpeterson/typewriter",
    opts = {},
    cmd = { "TWCenter" },
    keys = { { "M", "<cmd>TWCenter<cr>" } },
  },
  -- TODO: https://github.com/altermo/nwm
  --  could be useful for showing zathura pdf inside nvim? but why?
}
