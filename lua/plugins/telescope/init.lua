local telescope = {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "danielfalk/smart-open.nvim",
      config = function()
        require("plugins.telescope.functions").find_files = require("telescope").extensions.smart_open.smart_open
      end,
      dependencies = { "kkharji/sqlite.lua" },
    },
    { "nvim-telescope/telescope-frecency.nvim", dependencies = {
      "kkharji/sqlite.lua",
    } },
    "nvim-telescope/telescope-hop.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      -- NOTE: If you are having trouble with this installation,
      --       refer to the README for telescope-fzf-native for more instructions.
      build = "make",
      cond = function()
        return vim.fn.executable "make" == 1
      end,
    },
  },
  cmd = "Telescope",
  config = function()
    -- https://github.com/ibhagwan/nvim-lua/blob/main/lua/plugin/telescope.lua
    local sorters = require "telescope.sorters"
    local actions = require "telescope.actions"
    -- local action_layout = require "telescope.actions.layout"
    -- local functions = require "plugins.telescope.functions"
    -- Global remapping
    ------------------------------
    TelescopeMapArgs = TelescopeMapArgs or {}
    local map_ = vim.keymap.set
    local map_b = vim.keymap.setl
    local map_options = {
      noremap = true,
      silent = true,
    }
    local function map_tele(mode, key, f, options, buffer)
      -- local map_key = vim.api.nvim_replace_termcodes(key .. f, true, true, true)
      -- TelescopeMapArgs[map_key] = options or {}
      -- local rhs = string.format("<cmd>lua require('telescope')['%s'](TelescopeMapArgs['%s'])<CR>", f, map_key)
      local rhs = function()
        require("telescope")[f](options or {})
      end

      if not buffer then
        map_(mode, key, rhs, map_options)
      else
        map_b(mode, key, rhs, map_options)
      end
    end

    local function with_rg(ignore, hidden, files)
      return {
        "rg",
        "--color=never",
        "--no-config",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        ignore and "--ignore" or "--no-ignore",
        hidden and "--hidden" or "--no-hidden",
        files and "--files" or nil,
      }
    end

    local rg = with_rg(true, true, false)
    -- M.shell_cmd.fd = vim.list_extend(vim.deepcopy(M.shell_cmd.rg), { "--files" })
    local fd = with_rg(true, true, true)

    local telescope = require "telescope"
    telescope.setup {
      defaults = {
        find_command = fd,
        vimgrep_arguments = rg,
        prompt_prefix = " ",
        selection_caret = " ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "descending",
        layout_strategy = "flex",
        layout_config = {
          width = 0.75,
          prompt_position = "bottom",
          preview_cutoff = 120,
          horizontal = { mirror = false },
          vertical = {
            mirror = false,
            preview_cutoff = 2,
          },
          flex = {
            flip_columns = 150,
          },
        },
        -- file_sorter = sorters.get_fzy_sorter,
        -- generic_sorter = sorters.get_fzy_sorter,
        -- generic_sorter = sorters.get_generic_fuzzy_sorter,
        file_ignore_patterns = {},
        path_display = { "shorten_path" },
        winblend = 0,
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        use_less = true,
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
        mappings = {
          i = {
            -- ["<M-p>"] = action_layout.toggle_preview,
            ["<C-h>"] = telescope.extensions.hop.hop,
            ["<C-x>"] = actions.delete_buffer,
            ["<C-s>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            -- ["<C-t>"] = actions.select_tab,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<CR>"] = actions.select_default + actions.center,
            ["<C-up>"] = actions.preview_scrolling_up,
            ["<C-down>"] = actions.preview_scrolling_down,
            ["<M-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            -- ["<C-y>"] = functions.set_prompt_to_entry_value,
          },
          n = {
            -- ["<M-p>"] = action_layout.toggle_preview,
            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["<C-x>"] = actions.delete_buffer,
            ["<C-s>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            -- ["<C-t>"] = actions.select_tab,
            ["<S-up>"] = actions.preview_scrolling_up,
            ["<S-down>"] = actions.preview_scrolling_down,
            ["<C-up>"] = actions.preview_scrolling_up,
            ["<C-down>"] = actions.preview_scrolling_down,
            ["<C-q>"] = actions.send_to_qflist,
            ["<M-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<C-c>"] = actions.close,
          },
        },
      },
      extensions = {
        fzy_native = {
          override_generic_sorter = false,
          override_file_sorter = true,
        },
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = false, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          -- the default case_mode is "smart_case"
        },
        "cmake",
        extensions = {
          hop = {
            keys = { "a", "s", "d", "f", "h", "j", "k", "l" },
          },
        },
      },
    }

    -- telescope.setup {}
    -- telescope.load_extension('fzy_native')
    telescope.load_extension "fzf"
    telescope.load_extension "hop"
    telescope.load_extension "smart_open"
    telescope.load_extension "frecency"
    -- telescope.load_extension('project')
  end,
}
local M = {
  telescope,
  "nvim-telescope/telescope-fzy-native.nvim",
}
return M
