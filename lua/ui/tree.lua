local M = {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeOpen", "NvimTreeFocus", "NvimTreeToggle" },
  dependencies = {
    { "antosha417/nvim-lsp-file-operations", opts = {} },
    "nvim-tree/nvim-web-devicons",
  },
}

local function on_attach(bufnr)
  local api = require "nvim-tree.api"
  local opts = function(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  local maps = {
    ["c"] = { api.fs.rename_basename, "Rename: Basename" },
    ["C"] = { api.fs.rename_sub, "Rename: Path" },
    ["r"] = { api.fs.rename, "Rename" },
    ["d"] = { api.fs.remove, "Delete" },
    ["D"] = { api.fs.trash, "Trash" },
    ["x"] = { api.fs.cut, "Cut" },
    ["p"] = { api.fs.paste, "Paste" },
    ["P"] = { "<Nop>", "Nop" },
    ["y"] = { api.fs.copy.node, "Copy" },
    ["Y"] = { api.fs.copy.filename, "Copy Name" },
    ["gy"] = { api.fs.copy.relative_path, "Copy Relative Path" },
    ["gY"] = { api.fs.copy.absolute_path, "Copy Absolute Path" },
    ["q"] = { api.tree.close, "Close" },
    ["<esc>"] = { api.tree.close, "Close" },
    ["F"] = { api.live_filter.clear, "Clean Filter" },
    ["f"] = { api.live_filter.start, "Filter" },
    ["S"] = { api.tree.search_node, "Search" },
    ["L"] = { api.tree.expand_all, "Expand All" },
    ["hh"] = { api.tree.collapse_all, "Collapse All" },
    ["J"] = { "<Nop>", "Nop" },
    ["K"] = { api.node.navigate.parent, "Parent Directory" },
    ["w"] = { api.node.navigate.sibling.next, "Next Sibling" },
    ["b"] = { api.node.navigate.sibling.prev, "Prev Sibling" },

    ["a"] = { api.fs.create, "Create" },
    ["A"] = { "<Nop>", "Nop" },
    ["i"] = { "<Nop>", "Nop" },
    ["I"] = { "<Nop>", "Nop" },
    ["o"] = { api.fs.create, "Nop" },
    ["O"] = { "<Nop>", "Nop" },

    ["<CR>"] = { api.node.open.no_window_picker, "Open" },
    ["l"] = { api.node.open.edit, "Open" },
    ["<Tab>"] = { api.node.open.preview, "Open Preview" },
    ["h"] = { api.node.navigate.parent_close, "Close Directory" },

    ["<localleader>P"] = { api.marks.bulk.move, "Move Bookmarked" },
    ["m"] = { api.marks.toggle, "Toggle Bookmark" },
    ["M"] = { api.marks.clear, "Clear Bookmark" },
    ["<localleader>m"] = { api.marks.list, "List Bookmarks" },

    ["."] = { api.node.run.cmd, "Run Command" },
    ["<C-CR>"] = { api.node.run.system, "Run System" },

    ["H"] = { api.node.show_info_popup, "Info" },
    ["<localleader>r"] = { api.fs.rename_sub, "Rename: Omit Filename" },
    ["<localleader>e"] = { api.node.open.replace_tree_buffer, "Open: In Place" },
    ["<localleader>t"] = { api.node.open.tab, "Open: New Tab" },
    ["<localleader>v"] = { api.node.open.vertical, "Open: Vertical Split" },
    ["<localleader>x"] = { api.node.open.horizontal, "Open: Horizontal Split" },

    ["}"] = { api.node.navigate.sibling.last, "Last Sibling", "jS" },
    ["{"] = { api.node.navigate.sibling.first, "First Sibling", "kS" },
    ["sc"] = { api.node.navigate.git.next, "Next Git", "kc" },
    ["sC"] = { api.node.navigate.git.prev, "Prev Git", "jc" },
    ["se"] = { api.node.navigate.diagnostics.next, "Next Diagnostic", "je" },
    ["sE"] = { api.node.navigate.diagnostics.prev, "Prev Diagnostic", "ke" },
    ["sm"] = { api.marks.navigate.next, "Next Diagnostic", "je" },
    ["sM"] = { api.marks.navigate.prev, "Prev Diagnostic", "ke" },

    ["<localleader>b"] = { api.tree.toggle_no_buffer_filter, "Toggle No Buffer" },
    ["<localleader>c"] = { api.tree.toggle_git_clean_filter, "Toggle Git Clean" },
    ["<localleader>h"] = { api.tree.toggle_hidden_filter, "Toggle Hidden(.)" },
    ["<localleader>i"] = { api.tree.toggle_gitignore_filter, "Toggle Git Ignore" },

    ["R"] = { api.tree.reload, "Refresh" },

    ["<2-LeftMouse>"] = { api.node.open.edit, "Open" },
    ["<2-RightMouse>"] = { api.tree.change_root_to_node, "CD" },
    ["<localleader><localleader>R"] = { api.tree.change_root_to_node, "Change root to" },
    ["<localleader>R"] = { api.tree.change_root_to_parent, "Change root to parent" },

    ["?"] = { api.tree.toggle_help, "Help" },
    ["<C-l>"] = { api.tree.close, "Help" },
    ["<C-h>"] = {
      function()
        api.tree.close()
        vim.cmd.vsplit()
      end,
      "Help",
    },
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
M.opts = {
  disable_netrw = true,
  hijack_netrw = true,
  update_focused_file = { enable = true },
  on_attach = on_attach,
  view = {
    side = "left",
    width = 30,
  },
  diagnostics = {
    enable = true,
  },
  actions = {
    open_file = {
      window_picker = {
        picker = function() return require("ui.win_pick").pick_or_create() end,
      },
      quit_on_open = true,
    },
  },
  -- renderer = { icons = { glyphs = require("circles").get_nvimtree_glyphs() } },
}
M.config = function(_, opts)
  -- This is to work around some jank in remember-me.nvim
  vim.g.NvimTreeSetup = 0
  vim.g.NvimTreeRequired = 0
  require("nvim-tree").setup(opts)
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function() vim.cmd.NvimTreeClose() end,
  })
end

return M
