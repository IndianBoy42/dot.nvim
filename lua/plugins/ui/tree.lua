local M = {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeOpen", "NvimTreeFocus", "NvimTreeToggle" },
  dependencies = {
    "kyazdani42/nvim-web-devicons",
  },
}

function M.on_attach(bufnr)
  local api = require "nvim-tree.api"
  local opts = function(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  local maps = {
    ["c"] = { api.fs.rename_basename, "Rename: Basename" },
    ["r"] = { api.fs.rename, "Rename" },
    ["d"] = { api.fs.remove, "Delete" },
    ["D"] = { api.fs.trash, "Trash" },
    ["E"] = { api.tree.expand_all, "Expand All" },
    ["W"] = { api.tree.collapse_all, "Collapse All" },
    ["x"] = { api.fs.cut, "Cut" },
    ["y"] = { api.fs.copy.node, "Copy" },
    ["Y"] = { api.fs.copy.filename, "Copy Name" },
    ["gy"] = { api.fs.copy.relative_path, "Copy Relative Path" },
    ["gY"] = { api.fs.copy.absolute_path, "Copy Absolute Path" },
    ["q"] = { api.tree.close, "Close" },
    ["<esc>"] = { api.tree.close, "Close" },
    ["F"] = { api.live_filter.clear, "Clean Filter" },
    ["f"] = { api.live_filter.start, "Filter" },
    ["S"] = { api.tree.search_node, "Search" },
    ["a"] = { api.fs.create, "Create" },

    ["o"] = { api.node.open.edit, "Open" },
    ["O"] = { api.node.open.no_window_picker, "Open: No Window Picker" },

    ["<CR>"] = { api.node.open.edit, "Open" },
    ["l"] = { api.node.open.edit, "Open" },
    ["<Tab>"] = { api.node.open.preview, "Open Preview" },
    ["h"] = { api.node.navigate.parent_close, "Close Directory" },
    ["<BS>"] = { api.node.navigate.parent_close, "Close Directory" },

    ["bmv"] = { api.marks.bulk.move, "Move Bookmarked" },
    ["m"] = { api.marks.toggle, "Toggle Bookmark" },

    ["."] = { api.node.run.cmd, "Run Command" },
    ["s"] = { api.node.run.system, "Run System" },

    ["gh"] = { api.node.show_info_popup, "Info" },
    ["<C-r>"] = { api.fs.rename_sub, "Rename: Omit Filename" },
    ["<C-e>"] = { api.node.open.replace_tree_buffer, "Open: In Place" },
    ["<C-t>"] = { api.node.open.tab, "Open: New Tab" },
    ["<C-v>"] = { api.node.open.vertical, "Open: Vertical Split" },
    ["<C-x>"] = { api.node.open.horizontal, "Open: Horizontal Split" },
    ["<C-h>"] = { "<Nop>", "Nop" },
    ["<C-j>"] = { "<Nop>", "Nop" },
    ["<C-k>"] = { "<Nop>", "Nop" },
    ["J"] = { "<Nop>", "Nop" },
    ["K"] = { api.node.navigate.parent, "Parent Directory" },

    [")"] = { api.node.navigate.sibling.next, "Next Sibling", "js" },
    ["("] = { api.node.navigate.sibling.prev, "Previous Sibling", "ks" },
    ["}"] = { api.node.navigate.sibling.last, "Last Sibling", "jS" },
    ["{"] = { api.node.navigate.sibling.first, "First Sibling", "kS" },
    ["[c"] = { api.node.navigate.git.prev, "Prev Git", "jc" },
    ["]c"] = { api.node.navigate.git.next, "Next Git", "kc" },
    ["]e"] = { api.node.navigate.diagnostics.next, "Next Diagnostic", "je" },
    ["[e"] = { api.node.navigate.diagnostics.prev, "Prev Diagnostic", "ke" },

    ["B"] = { api.tree.toggle_no_buffer_filter, "Toggle No Buffer" },
    ["C"] = { api.tree.toggle_git_clean_filter, "Toggle Git Clean" },
    ["H"] = { api.tree.toggle_hidden_filter, "Toggle Dotfiles" },
    ["I"] = { api.tree.toggle_gitignore_filter, "Toggle Git Ignore" },

    ["R"] = { api.tree.reload, "Refresh" },
    ["p"] = { api.fs.paste, "Paste" },
    ["P"] = { "<Nop>", "Nop" },
    ["U"] = { api.tree.toggle_custom_filter, "Toggle Hidden" },

    ["<2-LeftMouse>"] = { api.node.open.edit, "Open" },
    ["<2-RightMouse>"] = { api.tree.change_root_to_node, "CD" },
    ["<C-]>"] = { api.tree.change_root_to_node, "CD" },
    ["-"] = { api.tree.change_root_to_parent, "Up" },
    ["?"] = { api.tree.toggle_help, "Help" },
  }

  local map = function(l, r, d, ll)
    vim.keymap.set("n", l, r, opts(d))
    -- vim.keymap.set("n", "<localleader>" .. (ll or l), r, opts(d))
  end
  for l, m in pairs(maps) do
    map(l, unpack(m))
  end

  ---
end
M.config = function()
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
    update_focused_file = { enable = true },
    on_attach = M.on_attach,
    view = {
      side = "left",
      width = 30,
    },
  }
end

return M
