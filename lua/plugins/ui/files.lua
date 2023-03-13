return {
  "stevearc/oil.nvim",
  lazy = false, -- So that i can do `nvim .` or `nvim <some_directory>`
  -- init = function()
  --   vim.api.nvim_create_autocmd("BufEnter", {
  --     callback = function()
  --       print "hello world"
  --       if vim.fn.isdirectory(vim.fn.expand "%:p") ~= 0 then
  --         print "hello oil"
  --         vim.cmd "cd %:p"
  --         require("oil").open()
  --         -- require("lazy").load { plugins = { "oil" } }
  --       end
  --     end,
  --   })
  -- end,
  opts = {
    columns = {
      "icon",
      "permissions",
      "size",
      "mtime",
    },
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-s>"] = "actions.select_vsplit",
      ["<C-h>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["g."] = "actions.toggle_hidden",
      ["<localleader><localleader>"] = "actions.select",
      ["<localleader>s"] = "actions.select_vsplit",
      ["<localleader>h"] = "actions.select_split",
      ["<localleader>t"] = "actions.select_tab",
      ["<localleader>p"] = "actions.preview",
      ["<localleader>c"] = "actions.close",
      ["<localleader>l"] = "actions.refresh",
      ["<localleader>P"] = "actions.parent",
      ["<localleader>."] = "actions.open_cwd",
      ["<localleader>cd"] = "actions.cd",
      ["<localleader>~"] = "actions.tcd",
      ["<localleader>H"] = "actions.toggle_hidden",
    },
  },
  -- event = "BufEnter",
  -- cmd = "Oil",
  keys = {
    {
      "-",
      function()
        require("oil").open()
      end,
      desc = "Open Parent Dir",
    },
  },
}
