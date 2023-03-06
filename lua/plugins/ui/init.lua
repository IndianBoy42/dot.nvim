return {
  {
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
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
      },
      window = {
        border = "single", -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 0, 0, 0, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 0, 0, 0, 0 }, -- extra window padding [top, right, bottom, left]
      },
      layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
      },
      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
      show_help = true, -- show help message on the command line when the popup is visible
    },
    config = function(_, opts)
      require("which-key").setup(opts)
    end,
  },
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss { silent = true, pending = true }
        end,
        desc = "Delete all Notifications",
      },
    },
    opts = {
      timeout = 3000,
      stages = "fade_in_slide_out",
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
    init = function()
      -- when noice is not enabled, install notify on VeryLazy
      if utils.have_plugin "noice.nvim" then
        utils.on_very_lazy(function()
          vim.notify = require "notify"
        end)
      end
    end,
  },
  require "plugins.ui.tree",
  -- {
  --   "hood/popui.nvim",
  --   dependencies = "RishabhRD/popfix",
  -- },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {

      "onsails/lspkind-nvim",
    },
    opts = function(_, opts)
      vim.tbl_extend("force", opts, {
        formatting = {
          format = require("lspkind").cmp_format { mode = "symbol_text" },
        },
      })
    end,
  },
  {
    "onsails/lspkind-nvim",
    config = function()
      require("lspkind").init {
        mode = "symbol_text",
        -- symbol_map = {
        --   Text = "",
        --   Method = "",
        --   Function = "",
        --   Constructor = "",
        --   Field = "ﰠ",
        --   Variable = "",
        --   Class = "ﴯ",
        --   Interface = "",
        --   Module = "",
        --   Property = "ﰠ",
        --   Unit = "塞",
        --   Value = "",
        --   Enum = "",
        --   Keyword = "",
        --   Snippet = "",
        --   Color = "",
        --   File = "",
        --   Reference = "",
        --   Folder = "",
        --   EnumMember = "",
        --   Constant = "",
        --   Struct = "פּ",
        --   Event = "",
        --   Operator = "",
        --   TypeParameter = "",
        -- },
      }
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      numhl = false,
      linehl = false,
      keymaps = {
        -- Default keymap options
        noremap = true,
        buffer = true,
      },
      watch_gitdir = { interval = 1000 },
      sign_priority = 6,
      update_debounce = 200,
      status_formatter = nil, -- Use default
    },
    keys = function()
      local make_nN_pair = mappings.make_nN_pair

      local hunk_nN = make_nN_pair {
        function()
          require("gitsigns").next_hunk()
        end,
        function()
          require("gitsigns").prev_hunk()
        end,
      }
      local pre_goto_next = O.treesitter.textobj_prefixes.goto_next
      local pre_goto_prev = O.treesitter.textobj_prefixes.goto_previous
      return {
        { pre_goto_next .. "g", hunk_nN[1], desc = "Next Hunk" },
        { pre_goto_prev .. "g", hunk_nN[2], desc = "Prev Hunk" },
      }
    end,
  },
  require "plugins.ui.bufferline",
  require "plugins.ui.statusline",
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen" },
    keys = {
      { "<leader>os", "<cmd>AerialToggle<cr>", desc = "Aerial Outline" },
    },
    opts = {},
  },
  { --
    "simrat39/symbols-outline.nvim",
    opts = {
      highlight_hovered_item = true,
      show_guides = true,
      auto_preview = true,
      position = "right",
      keymaps = {
        close = "<Esc>",
        goto_location = "<Cr>",
        focus_location = "o",
        hover_symbol = "<localleader>h",
        rename_symbol = "<localleader>r",
        code_actions = "<localleader>a",
      },
      lsp_blacklist = {},
    },
    cmd = "SymbolsOutline",
    keys = {
      { "<leader>oS", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
    keys = {
      { "<leader>dS", "<cmd>TroubleToggle<cr>", desc = "Trouble Sidebar" },
      { "<leader>dd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document" },
      { "<leader>dD", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace" },
      { "<leader>dr", "<cmd>TroubleToggle lsp_references<cr>", desc = "References" },
      { "<leader>ds", "<cmd>TroubleToggle lsp_definitions<cr>", desc = "Definitions" },
      { "<leader>dq", "<cmd>TroubleToggle quickfix<cr>", desc = "Quick Fixes" },
      -- { "<leader>dL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List" },
      -- { "<leader>do", "<cmd>TroubleToggle todo<cr>", desc = "TODOs" },
    },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      position = "right",
      auto_preview = false,
      hover = "h",
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd(
        { "CursorMoved", "InsertLeave", "BufEnter", "BufWinEnter", "TabEnter", "BufWritePost" },
        { command = "TroubleRefresh" }
      )

      require("trouble").setup(opts)

      local trouble = require "trouble.providers.telescope"
      local telescope = require "telescope"
      telescope.setup {
        defaults = {
          mappings = {
            i = { ["<c-t>"] = trouble.open_with_trouble },
            n = { ["<c-t>"] = trouble.open_with_trouble },
          },
        },
      }
    end,
  },
  -- "ldelossa/litee-calltree.nvim"
  -- "stevearc/aerial.nvim/"
  { "liuchengxu/vista.vim", cmd = "Vista" },
  {
    "GustavoKatel/sidebar.nvim",
    opts = {
      open = false,
      sections = {
        "datetime",
        "git-status",
        "lsp-diagnostics",
        "todos",
      },
    },
    cmd = "SidebarNvimToggle",
  },
  require "plugins.ui.findreplace",
  -- TODO: try https://github.com/goolord/alpha-nvim (new dashboard plugin)
  -- TODO: noice.nvim
  require "plugins.ui.noice_gui",
  -- TODO: dressing.nvim
  { "j-hui/fidget.nvim", opts = {}, event = "VeryLazy" },
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    keys = {
      {
        "<leader>rn",
        function()
          require "inc_rename"
          return ":IncRename " .. vim.fn.expand "<cword>"
        end,
        expr = true,
        desc = "Rename",
      },
    },
    config = true,
  },
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   opts = {
  --     doc_lines = 2, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
  --     -- Apply indentation for wrapped lines
  --     floating_window = true, -- show hint in a floating window, set to false for virtual text only mode
  --     fix_pos = true, -- set to true, the floating window will not auto-close until finish all parameters
  --     hint_enable = true, -- virtual hint enable
  --     hint_prefix = "🐼 ", -- Panda for parameter
  --     max_height = 12, -- max height of signature floating_window, if content is more than max_height, you can scroll down
  --     max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
  --     bind = true,
  --     handler_opts = { border = "rounded" },
  --     hint_scheme = "String",
  --     hi_parameter = "Search",
  --     toggle_key = "<C-S-space>", -- TODO: Can I add this to C-Space as well?
  --     zindex = 1,
  --     check_client_handlers = false,
  --   },
  --   event = { "BufReadPost", "BufNewFile" },
  -- },
  {
    "kosayoda/nvim-lightbulb",
    config = function()
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        callback = function()
          require("nvim-lightbulb").update_lightbulb()
        end,
      })
    end,
    event = { "CursorHold", "CursorHoldI" },
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("lsp_lines").setup()

      vim.diagnostic.config {
        virtual_text = false,
        virtual_lines = true,
      }
    end,
    event = { "BufReadPost", "BufNewFile" },
    keys = function()
      local enabled = true
      return {
        {
          "<leader>dL",
          function()
            enabled = not enabled
            vim.diagnostic.config {
              virtual_text = not enabled,
              virtual_lines = enabled,
            }
          end,
          desc = "Toggle lsp_lines",
        },
      }
    end,
  },
  {
    "echasnovski/mini.animate",
    cond = not vim.g.neovide,
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
    config = function(_, opts)
      require("mini.animate").setup(opts)
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
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow" },
  },
  {
    "romgrk/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
  {
    "haringsrob/nvim_context_vt",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
  {
    "kevinhwang91/nvim-ufo",
    config = function()
      vim.o.foldcolumn = "1" -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      require("ufo").setup {
        provider_selector = function()
          return { "treesitter", "indent" }
        end,
      }
    end,
    dependencies = "kevinhwang91/promise-async",
    event = { "BufReadPost", "BufNewFile" },
  },
  { "ElPiloto/significant.nvim" },
  require "plugins.ui.files",
  require "plugins.ui.windowman",
  -- {
  --   "weilbith/nvim-code-action-menu",
  --   config = function()
  --     utils.augroup._lsputil_codeaction_list.Filetype["code-action-menu-menu"] = "nmap <buffer> K <CR>"
  --   end,
  --   cmd = "CodeActionMenu",
  -- },
  {
    "aznhe21/actions-preview.nvim",
    opts = {
      telescope = require("telescopes").cursor_menu(),
    },
  },
}
