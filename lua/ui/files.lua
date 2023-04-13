local keymaps = function(table)
  local maps = {}
  for k, v in pairs(table) do
    if type(v) == "table" then
      for _, v2 in ipairs(v) do
        maps[v2] = k
      end
    else
      maps[v] = k
    end
  end
  return maps
end
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
    columns = { "icon", "permissions", "size", "mtime" },
    keymaps = keymaps {
      ["actions.show_help"] = "g?",
      ["actions.select"] = { "<CR>", "<localleader><localleader>", "<M-l>" },
      ["actions.select_vsplit"] = { "<C-s>", "<localleader>s" },
      ["actions.select_split"] = { "<C-h>", "<localleader>h" },
      ["actions.select_tab"] = { "<C-t>", "<localleader>t" },
      ["actions.preview"] = { "<C-p>", "<localleader>p" },
      ["actions.close"] = { "<C-c>", "<localleader>c" },
      ["actions.refresh"] = { "<C-r>", "<localleader>r" },
      ["actions.parent"] = { "-", "<localleader>-" },
      ["actions.open_cwd"] = { "_", "<localleader>." },
      ["actions.cd"] = { "`", "<localleader>d" },
      ["actions.tcd"] = { "~", "<localleader>~" },
      ["actions.toggle_hidden"] = "<localleader>H",
    },
    view_options = { show_hidden = true },
  },
  -- event = "BufEnter",
  -- cmd = "Oil",
  keys = {
    { "<leader>oe", function() require("oil").open() end, desc = "Open Parent Dir" },
  },
  init = function()
    if vim.fn.argc() == 1 then
      local stat = vim.loop.fs_stat(vim.fn.argv(0))
      if stat and stat.type == "directory" then require("lazy").load { plugins = { "oil.nvim" } } end
    end
    if not require("lazy.core.config").plugins["oil.nvim"]._.loaded then
      vim.api.nvim_create_autocmd("BufNew", {
        callback = function()
          if vim.fn.isdirectory(vim.fn.expand "<afile>") == 1 then
            require("lazy").load { plugins = { "oil.nvim" } }
            -- Once oil is loaded, we can delete this autocmd
            return true
          end
        end,
      })
    end
  end,
}
