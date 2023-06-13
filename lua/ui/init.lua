local testb = false
local blah = {
  { 2, 1, 6 },
  { 3, 4, 6 },
  { 3, 4, 6 },
}
local function test(args, ns, buf)
  if not testb then -- First iter
    vim.notify "hello"
  end
  if ns then
    testb = true
  else
    testb = false
  end
  local n = tonumber(args.args)
  if n then
    -- vim.notify(vim.api.nvim_get_current_win() .. " " .. tonumber(args.args))
    if vim.fn.buflisted(vim.api.nvim_list_bufs()[n]) then
      vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), vim.api.nvim_list_bufs()[n])
    end
  end
  return 1
end
vim.api.nvim_create_user_command("Test", test, {
  nargs = "*",
  preview = test,
  complete = function(arglead, cmdline, cpos)
    local bufs = vim.api.nvim_list_bufs()
    bufs = vim.tbl_filter(function(bufnr) return vim.fn.buflisted(bufnr) end, bufs)
    bufs = vim.tbl_map(function(bufnr) return tostring(bufnr) end, bufs)
    return bufs
  end,
})

-- vim.api.nvim_create_autocmd("User", {
--   pattern = "VeryLazy",
--   callback = function()
--     -- TODO: https://github.com/stevearc/dressing.nvim
--     vim.ui.input = function(opts, on_confirm)
--       opts = opts or {}
--       -- opts.completion
--       -- opts.highlight
--
--       utils.ui.inline_text_input {
--         prompt = opts.prompt,
--         border = O.input_border,
--         enter = on_confirm,
--         initial = opts.default,
--         at_begin = false,
--         minwidth = 20,
--         insert = true,
--       }
--     end
--     -- require "commands"
--   end,
-- })

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
      operators = { ["#"] = "Comments" },
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
    config = function(_, opts)
      require("actions-preview").setup {
        telescope = require("utils.telescope").cursor_menu(),
      }
    end,
  },
  -- TODO: try https://github.com/goolord/alpha-nvim (new dashboard plugin)
  -- TODO: dressing.nvim
  {
    "smjonas/live-command.nvim",
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
    config = function()
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        callback = function() require("nvim-lightbulb").update_lightbulb() end,
      })
    end,
    event = { "CursorHold", "CursorHoldI" },
  },
  { -- "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function() require("lsp_lines").setup() end,
    event = { "BufReadPost", "BufNewFile" },
    keys = function()
      return {
        {
          "<leader>Tl",
          function()
            local enabled = vim.diagnostic.config().virtual_lines
            if enabled then
              vim.diagnostic.config {
                virtual_lines = false,
                virtual_text = require("langs").diagnostic_config_all.virtual_text,
              }
            else
              vim.diagnostic.config {
                virtual_lines = require("langs").diagnostic_config_all.virtual_lines,
                virtual_text = false,
              }
            end
          end,
          desc = "Toggle lsp_lines",
        },
      }
    end,
  },
  { -- "VidocqH/lsp-lens.nvim",
    "VidocqH/lsp-lens.nvim",
    cond = false,
    opts = {
      enable = true,
      include_declaration = true,
    },
    event = { "BufReadPost", "BufNewFile" },
  },
  { -- "romgrk/nvim-treesitter-context",
    "romgrk/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
  { -- "haringsrob/nvim_context_vt",
    "haringsrob/nvim_context_vt",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      prefix = "󱞿",
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
  { -- "mbbill/undotree",
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow" },
  },

  { -- "ElPiloto/significant.nvim",
    "ElPiloto/significant.nvim",
  },
  { --giusgad/pets.nvim
    "giusgad/pets.nvim",
    opts = {
      random = true,
      row = 2,
    },
    init = function()
      vim.api.nvim_create_user_command("LotsOPets", function()
        local names = "abcdefghijklmnopqrstuvwxyz"

        local chars = {}
        for c in names:gmatch "." do
          vim.cmd.PetsNew(c)
        end
      end, {})
    end,
    config = function(_, opts) require("pets").setup(opts) end,
    dependencies = { "MunifTanjim/nui.nvim", "edluffy/hologram.nvim" },
    cmd = {
      "PetsNew",
      "PetsNewCustom",
      "PetsList",
      "PetsKill",
      "PetsKillAll",
      "PetsPauseToggle",
      "PetsHideToggle",
      "PetsSleepToggle",
    },
  },
  { --tamton-aquib/duck.nvim
    "tamton-aquib/duck.nvim",
    keys = {
      -- {
      --   "gzD",
      --   function()
      --     -- 🦆 ඞ  🦀 🐈 🐎 🦖 🐤
      --     require("duck").hatch("🦆", "10")
      --   end,
      --   desc = "hatch a duck",
      -- },
    },
  },
  -- TODO: https://github.com/DNLHC/glance.nvim
  -- TODO: https://github.com/stevearc/qf_helper.nvim
  { --lukas-reineke/indent-blankline.nvim
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    -- opts = {
    --   setup = function()
    --     vim.cmd [[highlight IndentBlanklineIndent1 guibg=#000000 gui=nocombine]]
    --     vim.cmd [[highlight IndentBlanklineIndent2 guibg=#1a1a1a gui=nocombine]]
    --   end,
    --   char = "",
    --   char_highlight_list = {
    --     "IndentBlanklineIndent1",
    --     "IndentBlanklineIndent2",
    --   },
    --   space_char_highlight_list = {
    --     "IndentBlanklineIndent1",
    --     "IndentBlanklineIndent2",
    --   },
    --   show_trailing_blankline_indent = false,
    --   show_current_context = true,
    --   show_current_context_start = false,
    -- },
    opts = {
      setup = function()
        -- vim.cmd [[highlight IndentBlanklineIndent6 guifg=#000000 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent5 guifg=#000000 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent4 guifg=#000000 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent3 guifg=#000000 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent2 guifg=#000000 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent1 guifg=#000000 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent5 guifg=#E06C75 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent4 guifg=#E5C07B gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent3 guifg=#98C379 gui=nocombine]]
        -- -- vim.cmd [[highlight IndentBlanklineIndent2 guifg=#56B6C2 gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent2 guifg=#61AFEF gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent1 guifg=#C678DD gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent1 guibg=#1f1f1f gui=nocombine]]
        -- vim.cmd [[highlight IndentBlanklineIndent2 guibg=#1a1a1a gui=nocombine]]
      end,
      char = "▏",
      filetype_exclude = { "help", "terminal", "dashboard" },
      buftype_exclude = { "terminal", "nofile" },
      char_highlight = "LineNr",
      show_trailing_blankline_indent = false,
      -- show_first_indent_level = false,
      space_char_blankline = " ",
      show_current_context = true,
      show_current_context_start = false,
      char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
        "IndentBlanklineIndent3",
        "IndentBlanklineIndent4",
        "IndentBlanklineIndent5",
        "IndentBlanklineIndent6",
      },
      -- space_char_highlight_list = {
      --   "IndentBlanklineIndent1",
      --   "IndentBlanklineIndent2",
      -- },
    },
    config = function(_, opts)
      opts.setup()
      opts.setup = nil

      -- vim.opt.list = true
      -- vim.opt.listchars:append "space:⋅"
      -- vim.opt.listchars:append "eol:↴"

      require("indent_blankline").setup(opts)
    end,
  },
  -- TODO: https://github.com/shellRaining/hlchunk.nvim
  {
    "IndianBoy42/blockman.nvim",
    dev = true,
    lazy = false,
    dependencies = {
      "edluffy/hologram.nvim",
    },
    opts = {},
  },
  {
    "ray-x/lsp_signature.nvim",
    config = false,
    init = function()
      local opts = {
        bind = true,
        -- hint_inline = function() return true end,
        --     doc_lines = 2, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
        --     -- Apply indentation for wrapped lines
        --     floating_window = true, -- show hint in a floating window, set to false for virtual text only mode
        fix_pos = true, -- set to true, the floating window will not auto-close until finish all parameters
        --     hint_enable = true, -- virtual hint enable
        --     hint_prefix = "🐼 ", -- Panda for parameter
        --     max_height = 12, -- max height of signature floating_window, if content is more than max_height, you can scroll down
        --     max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
        handler_opts = { border = "rounded" },
        --     hint_scheme = "String",
        --     hi_parameter = "Search",
        toggle_key = "<C-S-space>", -- TODO: Can I add this to C-Space as well?
        timer_interval = 100,
        --     zindex = 1,
        --     check_client_handlers = false,
      }

      utils.lsp.on_attach(function(client, bufnr) require("lsp_signature").on_attach(opts, bufnr) end)
    end,
  },
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
}
