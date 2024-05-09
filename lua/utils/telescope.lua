local M = {}

function M.set_prompt_to_entry_value(prompt_bufnr)
  local entry = require("telescope.actions.state").get_selected_entry()
  if not entry or not type(entry) == "table" then return end

  require("telescope.actions.state").get_current_picker(prompt_bufnr):reset_prompt(entry.ordinal)
end

M.from_qf_items = function(items, opts)
  local opts = opts or {}
  local conf = require("telescope.config").values
  require("telescope.pickers")
    .new(opts, {
      prompt_title = "LSP References",
      finder = require("telescope.finders").new_table {
        results = items,
        entry_maker = opts.entry_maker or require("telescope.make_entry").gen_from_quickfix(opts),
      },
      previewer = conf.qflist_previewer(opts),
      sorter = conf.generic_sorter(opts),
      push_cursor_on_edit = true,
      push_tagstack_on_edit = true,
    })
    :find()
end

M.from_lsp_locations = function(items, opts, ctx) M.from_qf_items(vim.lsp.util.locations_to_items(result, oe), opts) end

M.smart_open = function()
  require("telescope").extensions.smart_open.smart_open {
    -- cwd_only = true,
  }
end

function M.edit_neovim()
  require("telescope.builtin").find_files {
    prompt_title = "< VimRC >",
    shorten_path = false,
    cwd = CONFIG_PATH,

    layout_strategy = "vertical",
    layout_config = {
      width = 0.9,
      height = 0.8,

      horizontal = {
        width = { padding = 0.15 },
      },
      vertical = {
        preview_height = 0.75,
      },
    },

    attach_mappings = function(_, map)
      map("i", "<c-y>", M.set_prompt_to_entry_value)
      return true
    end,
  }
end

function M.edit_dotfiles()
  require("telescope.builtin").find_files {
    prompt_title = "~ dotfiles ~",
    shorten_path = false,
    cwd = "~/dots",

    attach_mappings = function(_, map)
      map("i", "<c-y>", M.set_prompt_to_entry_value)
      return true
    end,
  }
end

function M.edit_fish()
  require("telescope.builtin").find_files {
    shorten_path = false,
    cwd = "~/.config/fish/",
    prompt = "~ fish ~",
    hidden = true,

    layout_strategy = "vertical",
    layout_config = {
      horizontal = {
        width = { padding = 0.15 },
      },
      vertical = {
        preview_height = 0.75,
      },
    },
  }
end

function M.git_branches()
  require("telescope.builtin").git_branches {
    attach_mappings = function(_, map)
      map("i", "<c-x>", require("telescope.actions").git_delete_branch)
      map("n", "<c-x>", require("telescope.actions").git_delete_branch)
      map("i", "<c-y>", M.set_prompt_to_entry_value)
      return true
    end,
  }
end

M.cursor_menu = function()
  return require("telescope.themes").get_cursor {
    -- previewer = true,
    shorten_path = false,
    border = true,
    layout_config = { height = 0.5, width = 0.75 },
  }
end
function M.lsp_code_actions()
  require("telescope.builtin").lsp_code_actions(vim.tbl_deep_extend("keep", {
    layout_config = {
      width = 0.3,
    },
  }, M.cursor_menu()))
end

function M.lsp_references() require("telescope.builtin").lsp_references(M.cursor_menu()) end

-- M.codelens_actions = function(opts)
--   local results_lsp = vim.lsp.codelens.get(0)
--
--   if not results_lsp or vim.tbl_isempty(results_lsp) then
--     print "No executable codelens actions found at the current buffer"
--     return
--   end
--
--   local idx = 1
--   local results = {}
--   local widths = {
--     idx = 0,
--     command_title = 0,
--     client_name = 0,
--   }
--
--   for _, result in ipairs(results_lsp) do
--     if result.command then
--       local entry = {
--         idx = idx,
--         command_title = result.command.title:gsub("\r\n", "\\r\\n"):gsub("\n", "\\n"):gsub("▶︎ ", ""),
--         command = result.command,
--         client_name = result.command.command,
--       }
--
--       for key, value in pairs(widths) do
--         widths[key] = math.max(value, strings.strdisplaywidth(entry[key]))
--       end
--
--       table.insert(results, entry)
--       idx = idx + 1
--     end
--   end
--
--   if #results == 0 then
--     print "No codelens actions available"
--     return
--   end
--
--   local displayer = entry_display.create {
--     separator = " ",
--     items = {
--       { width = widths.idx + 1 }, -- +1 for ":" suffix
--       { width = widths.command_title },
--       { width = widths.client_name },
--     },
--   }
--
--   local function make_display(entry)
--     return displayer {
--       { entry.idx .. ":", "TelescopePromptPrefix" },
--       { entry.command_title },
--       { entry.client_name, "TelescopeResultsComment" },
--     }
--   end
--
--   local execute_action = opts.execute_action
--     or function(action)
--       if action.edit or type(action.command) == "table" then
--         if action.edit then
--           vim.lsp.util.apply_workspace_edit(action.edit)
--         end
--         if type(action.command) == "table" then
--           vim.lsp.buf.execute_command(action.command)
--         end
--       else
--         vim.lsp.buf.execute_command(action)
--       end
--     end
--
--   require "telescope.pickers".new(opts, {
--     prompt_title = "LSP CodeLens Actions",
--     finder = require "telescope.finders".new_table {
--       results = results,
--       entry_maker = function(line)
--         return {
--           valid = line ~= nil,
--           value = line.command,
--           ordinal = line.idx .. line.command_title,
--           command_title = line.command_title,
--           idx = line.idx,
--           client_name = line.client_name,
--           display = make_display,
--         }
--       end,
--     },
--     attach_mappings = function(prompt_bufnr)
--       require "telescope.actions".select_default:replace(function()
--         local selection = require "telescope.actions.state".get_selected_entry()
--         require "telescope.actions".close(prompt_bufnr)
--         local action = selection.value
--
--         execute_action(action)
--       end)
--
--       return true
--     end,
--     sorter = conf.generic_sorter(opts),
--   }):find()
-- end

--[[
function M.live_grep()
  require("telescope").extensions.fzf_writer.staged_grep {
    path_display = {"shorten_path"},
    previewer = false,
    fzf_separator = "|>",
  }
end
--]]
function M.grep_prompt()
  require("telescope.builtin").grep_string {
    path_display = { "shorten_path" },
    search = vim.fn.input "Grep String ❯ ",
  }
end

function M.grep_last_search(opts)
  opts = opts or {}

  -- \<getreg\>\C
  -- -> Subs out the search things
  -- TODO: properly escape this
  local register = vim.fn.getreg("/"):gsub("\\<", ""):gsub("\\>", ""):gsub("\\C", "")

  opts.path_display = { "shorten_path" }
  opts.word_match = "-w"
  opts.search = register

  require("telescope.builtin").grep_string(opts)
end

function M.installed_plugins()
  require("telescope.builtin").find_files {
    cwd = vim.fn.stdpath "data" .. "/site/pack/packer/",
  }
end

function M.project_search()
  require("telescope.builtin").find_files {
    previewer = false,
    layout_strategy = "vertical",
    cwd = require("nvim_lsp.util").root_pattern ".git"(vim.fn.expand "%:p"),
  }
end

function M.curbuf()
  -- local opts = require'telescope.themes'.get_dropdown {
  local opts = {
    -- winblend = 10,
    previewer = false,
    shorten_path = false,
  }
  require("telescope.builtin").current_buffer_fuzzy_find(opts)
end

function M.help_tags()
  require("telescope.builtin").help_tags {
    show_version = true,
  }
end
function M.with_rg(opts)
  return {
    "rg",
    "--color=never",
    "--no-config",
    "--no-heading",
    "--with-filename",
    "--line-number",
    "--column",
    "--smart-case",
    "--trim",
    opts.ignore and "--ignore" or "--no-ignore",
    opts.hidden and "--hidden" or "--no-hidden",
    opts.files and "--files" or nil,
  }
end

function M.live_grep_all()
  require("telescope.builtin").live_grep {
    find_command = M.with_rg {},
  }
end
function M.live_grep_args()
  -- require("telescope.builtin").live_grep ()
  require("telescope").extensions.live_grep_args.live_grep_args()
end

function M.find_all_files()
  require("telescope.builtin").find_files {
    find_command = M.with_rg { files = true },
  }
end

-- TODO: replace with https://github.com/nvim-telescope/telescope-ui-select.nvim
function M.uiselect(picker_opts, sorter_opts)
  picker_opts = picker_opts or require("telescope.themes").get_cursor() -- get_dropdown
  local conf = require("telescope.config").values

  return function(items, opts, on_choice)
    opts = opts or {}
    local prompt_title = opts.prompt or ""
    local format_item = opts.format_item or tostring

    require("telescope.pickers")
      .new(picker_opts, {
        prompt_title = prompt_title,
        finder = require("telescope.finders").new_table {
          results = items, -- TODO:
          entry_maker = function(entry)
            local str = format_item(entry)
            -- local str = function(tbl)
            --   utils.dump(tbl)
            --   return format_item(tbl.value)
            -- end

            return {
              value = entry,
              display = str,
              ordinal = str,
            }
          end,
        },
        sorter = conf.generic_sorter(sorter_opts),
        attach_mappings = function(prompt_bufnr, map)
          require("telescope.actions").select_default:replace(function()
            require("telescope.actions").close(prompt_bufnr)
            local selection = require("telescope.actions.state").get_selected_entry()
            on_choice(selection.value, selection.index)
          end)
          return true
        end,
      })
      :find()
  end
end
vim.ui.select = function(...)
  vim.ui.select = require("utils.telescope").uiselect()
  return vim.ui.select(...)
end

function M.file_browser()
  local opts

  opts = {
    sorting_strategy = "ascending",
    scroll_strategy = "cycle",
    layout_config = {
      prompt_position = "top",
    },
    attach_mappings = function(prompt_bufnr, map)
      local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)

      local function modify_cwd(new_cwd)
        current_picker.cwd = new_cwd
        current_picker:refresh(opts.new_finder(new_cwd), { reset_prompt = true })
      end

      map("i", "-", function() modify_cwd(current_picker.cwd .. "/..") end)

      map("i", "~", function() modify_cwd(vim.fn.expand "~") end)

      local function modify_depth(mod)
        return function()
          opts.depth = opts.depth + mod

          local curr_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
          curr_picker:refresh(opts.new_finder(curr_picker.cwd), { reset_prompt = true })
        end
      end

      map("i", "<M-=>", modify_depth(1))
      map("i", "<M-+>", modify_depth(-1))

      map("n", "yy", function()
        local entry = require("telescope.actions.state").get_selected_entry()
        vim.fn.setreg("+", entry.value)
      end)

      return true
    end,
  }

  require("telescope.builtin").file_browser(opts)
end

function M.git_status()
  local opts = require("telescope.themes").get_dropdown {
    winblend = 10,
    border = true,
    previewer = false,
    shorten_path = false,
  }

  -- Can change the git icons using this.
  -- opts.git_icons = {
  --   changed = "M"
  -- }

  require("telescope.builtin").git_status(opts)
end

function M.git_commits()
  require("telescope.builtin").git_commits {
    winblend = 5,
  }
end

function M.projects() require("telescope").extensions.project.project {} end

function M.diagnostics(opts)
  require("telescope.builtin").diagnostics(vim.tbl_extend("keep", opts or {}, {
    bufnr = 0,
  }))
end
function M.workspace_diagnostics(opts) require("telescope.builtin").diagnostics(opts) end

function M.code_actions_previewed(...) require("actions-preview").code_actions(...) end

function M.side_split_theme(opts)
  opts = opts or {}

  -- TODO:
  local theme_opts = {
    theme = "side-split",

    sorting_strategy = "descending",

    layout_strategy = "right_pane", -- TODO:
    layout_config = {
      height = 25,
    },

    border = true,
    borderchars = {
      prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
      results = { " " },
      preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    },
  }
  if opts.layout_config and opts.layout_config.prompt_position == "bottom" then
    theme_opts.borderchars = {
      prompt = { " ", " ", "─", " ", " ", " ", "─", "─" },
      results = { "─", " ", " ", " ", "─", "─", " ", " " },
      preview = { "─", " ", "─", "│", "┬", "─", "─", "╰" },
    }
  end

  return vim.tbl_deep_extend("force", theme_opts, opts)
end

function M.select_pick_window(prompt_bufnr)
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

function M.flash(prompt_bufnr)
  require("flash").jump {
    pattern = "^",
    highlight = { label = { after = { 0, 0 } } },
    search = {
      mode = "search",
      exclude = {
        function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults" end,
      },
    },
    action = function(match)
      local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
      picker:set_selection(match.pos[1] - 1)
    end,
  }
end

return setmetatable(M, {
  __index = function(_, k)
    -- reloader()

    --     return function (...)
    --
    -- local builtin = require("telescope.builtin")[k]
    -- if builtin then
    --   return builtin(...)
    -- else
    --   return require("telescope").extensions[k](...)
    -- end
    --     end

    return function(...) return require("telescope.builtin")[k](...) end
    -- local builtin = require("telescope.builtin")[k]
    -- if builtin then
    --   return builtin
    -- else
    --   return require("telescope").extensions[k]
    -- end
  end,
})
