local M = {
  "kyazdani42/nvim-tree.lua",
  cmd = "NvimTreeToggle",
}
M.config = function()
  local tree_cb = require("nvim-tree.config").nvim_tree_callback

  local g = vim.g

  g.nvim_tree_ignore = { ".git", "node_modules", ".cache" }
  g.nvim_tree_quit_on_open = 0
  g.nvim_tree_indent_markers = 1
  g.nvim_tree_hide_dotfiles = 1
  g.nvim_tree_git_hl = 1
  g.nvim_tree_root_folder_modifier = ":t"
  g.nvim_tree_allow_resize = 1
  g.nvim_tree_disable_window_pickerq = 1

  g.nvim_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 1,
    folder_arrows = 1,
  }

  vim.g.nvim_tree_icons = {
    default = "",
    symlink = "",
    git = {
      unstaged = "",
      staged = "S",
      unmerged = "",
      renamed = "➜",
      deleted = "",
      untracked = "U",
      ignored = "◌",
    },
    folder = {
      default = "",
      open = "",
      empty = "",
      empty_open = "",
      symlink = "",
    },
  }

  -- require"utils".define_augroups {
  --     _nvimtree_statusline = {
  --         {
  --             "BufEnter,BufWinEnter,WinEnter,CmdwinEnter", "*",
  --             [[if bufname('%') == "NvimTree" | set laststatus=0 | else | set laststatus=2 | endif]]
  --         }
  --     }
  -- }

  require("nvim-tree").setup {
    disable_netrw = true,
    hijack_netrw = true,
    open_on_setup = true,
    auto_close = O.auto_close_tree,
    open_on_tab = false,
    ignore_ft_on_setup = { "startify", "dashboard" },
    lsp_diagnostics = true,
    update_focused_file = { enable = true },
    view = {
      side = "left",
      width = 30,
      mappings = {
        -- g.nvim_tree_bindings = {
        --     ["u"] = ":lua require'some_module'.some_function()<cr>",
        --     ["<CR>"] = tree_cb("edit"),
        --     ["l"] = tree_cb("edit"),
        --     ["o"] = tree_cb("edit"),
        --     ["h"] = tree_cb("close_node"),
        --     ["<2-LeftMouse>"] = tree_cb("edit"),
        --     ["<2-RightMouse>"] = tree_cb("cd"),
        --     ["<C-]>"] = tree_cb("cd"),
        --     ["<C-v>"] = tree_cb("vsplit"),
        --     ["v"] = tree_cb("vsplit"),
        --     ["<C-x>"] = tree_cb("split"),
        --     ["<C-t>"] = tree_cb("tabnew"),
        --     ["<"] = tree_cb("prev_sibling"),
        --     [">"] = tree_cb("next_sibling"),
        --     ["<BS>"] = tree_cb("close_node"),
        --     ["<S-CR>"] = tree_cb("close_node"),
        --     ["<Tab>"] = tree_cb("preview"),
        --     ["I"] = tree_cb("toggle_ignored"),
        --     ["H"] = tree_cb("toggle_dotfiles"),
        --     ["R"] = tree_cb("refresh"),
        --     ["a"] = tree_cb("create"),
        --     ["d"] = tree_cb("remove"),
        --     ["r"] = tree_cb("rename"),
        --     ["<C-r>"] = tree_cb("full_rename"),
        --     ["x"] = tree_cb("cut"),
        --     ["c"] = tree_cb("copy"),
        --     ["p"] = tree_cb("paste"),
        --     ["y"] = tree_cb("copy_name"),
        --     ["Y"] = tree_cb("copy_path"),
        --     ["gy"] = tree_cb("copy_absolute_path"),
        --     ["[c"] = tree_cb("prev_git_item"),
        --     ["]c"] = tree_cb("next_git_item"),
        --     ["-"] = tree_cb("dir_up"),
        --     ["q"] = tree_cb("close")
        -- }
        list = {
          { key = { "l", "<CR>", "o" }, cb = tree_cb "edit" },
          { key = "h", cb = tree_cb "close_node" },
          { key = "v", cb = tree_cb "vsplit" },
        },
      },
    },
  }
end

function M.toggle_tree()
  local view = require "nvim-tree.view"
  if view.win_open() then
    require("nvim-tree").close()
    if package.loaded["bufferline.state"] then
      require("bufferline.state").set_offset(0)
    end
  else
    if package.loaded["bufferline.state"] then
      -- require'bufferline.state'.set_offset(31, 'File Explorer')
      require("bufferline.state").set_offset(31, "")
    end
    require("nvim-tree").find_file(true)
  end
end

return M
