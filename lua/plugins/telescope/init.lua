local telescope = {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    -- https://github.com/orgs/nvim-telescope/repositories
    {
      "danielfalk/smart-open.nvim",
      dependencies = { "kkharji/sqlite.lua" },
    },
    { "nvim-telescope/telescope-frecency.nvim" },
    "nvim-telescope/telescope-media-files.nvim",
    "nvim-telescope/telescope-github.nvim",
    "nvim-telescope/telescope-live-grep-args.nvim",
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
    local actions = require "telescope.actions"
    local lga_actions = require "telescope-live-grep-args.actions"
    local action_layout = require "telescope.actions.layout"
    local previewers = require "telescope.previewers"

    local with_rg = require("utils.telescope").with_rg
    local rg = with_rg { ignore = true, hidden = true }
    local fd = with_rg { ignore = true, hidden = true, files = true }

    local function pick_n(n)
      return function(prompt_bufnr)
        local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
        picker:set_selection(n)
        actions.select_default(prompt_bufnr)
      end
    end

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
        path_display = { "smart" },
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        mappings = {
          i = {
            ["<C-p>"] = action_layout.toggle_preview,
            ["<Esc>"] = actions.close,

            ["<C-h>"] = utils.telescope.flash,
            ["<C-x>"] = actions.delete_buffer,
            ["<C-s>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<CR>"] = actions.select_default,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-up>"] = actions.cycle_history_next,
            ["<C-down>"] = actions.cycle_history_prev,
            ["<C-S-q>"] = function(...)
              actions.send_to_qflist(...)
              actions.open_qflist(...)
              require("replacer").run()
            end,
            ["<C-q>"] = function(...)
              actions.send_to_qflist(...)
              actions.open_qflist(...)
            end,
            ["<C-l>"] = function(...) require("trouble.providers.telescope").open_with_trouble(...) end,
            -- ["<C-y>"] = functions.set_prompt_to_entry_value,
            ["<C-cr>"] = utils.telescope.select_pick_window,
            ["<M-cr>"] = utils.telescope.select_pick_window,
            -- ["<C-Space>"] = to fuzzy
            ["<tab>"] = function(prompt_bufnr)
              vim.api.nvim_buf_call(prompt_bufnr, function() vim.cmd "normal! A.*?" end)
            end,
            ["<C-0>"] = pick_n(0),
            ["<C-1>"] = pick_n(1),
            ["<C-2>"] = pick_n(2),
            ["<C-3>"] = pick_n(3),
            ["<C-4>"] = pick_n(4),
            ["<C-5>"] = pick_n(5),
            ["<C-6>"] = pick_n(6),
            ["<C-7>"] = pick_n(7),
            ["<C-8>"] = pick_n(8),
            ["<C-9>"] = pick_n(9),
          },
          n = {
            -- ["<M-p>"] = action_layout.toggle_preview,
            ["h"] = utils.telescope.flash,
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
            ["<localleader>n"] = utils.telescope.select_pick_window,
          },
        },
      },
      pickers = {
        live_grep = {
          on_input_filter_cb = function(prompt)
            -- AND operator for live_grep like how fzf handles spaces with wildcards in rg
            return { prompt = prompt:gsub("%s", ".*?") }
          end,
        },
        git_branches = {
          attach_mappings = function(_, map)
            map("i", "<c-x>", actions.git_delete_branch)
            map("n", "<c-x>", actions.git_delete_branch)
            map("i", "<c-y>", M.set_prompt_to_entry_value)
            return true
          end,
        },
      },
      extensions = {
        fzy_native = {
          override_generic_sorter = false,
          override_file_sorter = false,
        },
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          -- the default case_mode is "smart_case"
        },
        "cmake",
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
        smart_open = {
          match_algorithm = "fzf",
        },
        live_grep_args = {
          auto_quoting = true,
          mappings = {
            i = {
              ["<C-k>"] = lga_actions.quote_prompt(),
              ["<C-i>"] = lga_actions.quote_prompt { postfix = " --iglob " },
              ["<C-S-i>"] = lga_actions.quote_prompt { postfix = " --t " },
            },
          },
        },
        frecency = {
          db_safe_mode = false,
          auto_validate = true,
        },
      },
    }
  end,
  config = function(_, opts)
    local telescope = require "telescope"
    telescope.setup(opts)

    -- telescope.load_extension('fzy_native')
    telescope.load_extension "noice"
    telescope.load_extension "fzf"
    telescope.load_extension "smart_open"
    telescope.load_extension "frecency"
    telescope.load_extension "luasnip"
    telescope.load_extension "undo"
    telescope.load_extension "live_grep_args"
    -- telescope.load_extension('project')
  end,
}
local M = {
  telescope,
}
return M
