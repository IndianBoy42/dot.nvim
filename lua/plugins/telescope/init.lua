local function select_pick_window(prompt_bufnr)
  -- Use nvim-window-picker to choose the window by dynamically attaching a function
  local action_set = require "telescope.actions.set"
  local action_state = require "telescope.actions.state"

  local picker = action_state.get_current_picker(prompt_bufnr)
  picker.get_selection_window = function(picker, entry)
    local fallback = vim.api.nvim_get_current_win
    local picked_window_id = require("ui.win_pick").pick_or_create() or fallback()
    -- Unbind after using so next instance of the picker acts normally
    picker.get_selection_window = nil
    return picked_window_id
  end

  return action_set.edit(prompt_bufnr, "edit")
end
local telescope = {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    -- https://github.com/orgs/nvim-telescope/repositories
    {
      "danielfalk/smart-open.nvim",
      dependencies = { "kkharji/sqlite.lua" },
    },
    { "nvim-telescope/telescope-frecency.nvim", dependencies = {
      "kkharji/sqlite.lua",
    } },
    "nvim-telescope/telescope-hop.nvim",
    "nvim-telescope/telescope-media-files.nvim",
    "nvim-telescope/telescope-github.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      -- NOTE: If you are having trouble with this installation,
      --       refer to the README for telescope-fzf-native for more instructions.
      build = "make",
      cond = function() return vim.fn.executable "make" == 1 end,
    },
    "LukasPietzschmann/telescope-tabs",
    "benfowler/telescope-luasnip.nvim",
    "debugloop/telescope-undo.nvim",
  },
  cmd = "Telescope",
  opts = function()
    -- local actions = setmetatable({}, {
    --   __index = function(t, k)
    --     return function(...) return require("telescope.actions")[k](...) end
    --   end,
    -- })
    local actions = utils.lazy_require "telescope.actions"
    local action_layout = utils.lazy_require "telescope.actions.layout"

    local with_rg = require("utils.telescope").with_rg
    local rg = with_rg { ignore = true, hidden = true }
    -- M.shell_cmd.fd = vim.list_extend(vim.deepcopy(M.shell_cmd.rg), { "--files" })
    local fd = with_rg { ignore = true, hidden = true, files = true }

    return {
      defaults = {
        find_command = fd,
        vimgrep_arguments = rg,
        prompt_prefix = " ",
        selection_caret = " ",
        initial_mode = "insert",
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
            ["<C-p>"] = action_layout.toggle_preview,
            ["<Esc>"] = actions.close,

            ["<C-h>"] = function(...) return require("telescope").extensions.hop.hop(...) end,
            ["<C-x>"] = actions.delete_buffer,
            ["<C-s>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<CR>"] = actions.select_default,
            ["<C-up>"] = actions.preview_scrolling_up,
            ["<C-down>"] = actions.preview_scrolling_down,
            ["<M-q>"] = function(...)
              actions.send_to_qflist(...)
              actions.open_qflist(...)
            end,
            ["<C-q>"] = function(...)
              actions.send_selected_to_qflist(...)
              actions.open_qflist(...)
            end,
            -- ["<C-y>"] = functions.set_prompt_to_entry_value,
            ["<C-cr>"] = select_pick_window,
            ["<M-cr>"] = select_pick_window,
          },
          n = {
            -- ["<M-p>"] = action_layout.toggle_preview,
            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["<localleader>x"] = actions.delete_buffer,
            ["<localleader>s"] = actions.select_horizontal,
            ["<localleader>v"] = actions.select_vertical,
            ["<localleader>t"] = actions.select_tab,
            ["<CR>"] = actions.select_default,
            ["<C-up>"] = actions.preview_scrolling_up,
            ["<C-down>"] = actions.preview_scrolling_down,
            ["<localleader>q"] = function(...)
              actions.send_selected_to_qflist(...)
              actions.open_qflist(...)
            end,
            ["<C-c>"] = actions.close,
            ["<localleader>n"] = select_pick_window,
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
        hop = { keys = O.hint_labels_array },
        advanced_git_search = {
          -- fugitive or diffview
          diff_plugin = "diffview",
          -- customize git in previewer
          -- e.g. flags such as { "--no-pager" }, or { "-c", "delta.side-by-side=false" }
          git_flags = {},
          -- customize git diff in previewer
          -- e.g. flags such as { "--raw" }
          git_diff_flags = {},
        },
        undo = {},
      },
    }
  end,
  config = function(_, opts)
    local telescope = require "telescope"
    telescope.setup(opts)

    -- telescope.load_extension('fzy_native')
    telescope.load_extension "fzf"
    telescope.load_extension "hop"
    telescope.load_extension "smart_open"
    telescope.load_extension "frecency"
    telescope.load_extension "luasnip"
    -- telescope.load_extension "undo"
    -- telescope.load_extension('project')
  end,
}
local M = {
  telescope,
  "nvim-telescope/telescope-fzy-native.nvim",
}
return M
