local feedkeys = vim.api.nvim_feedkeys
local termcodes = vim.api.nvim_replace_termcodes
local function t(k)
  return termcodes(k, true, true, true)
end

return {
  defaults = { lazy = true, config = true },
  install = { colorscheme = { "nebulous", "torte" } },
  checker = { enabled = true },
  change_detection = { enabled = false },
  dev = { path = "~/plugins.nvim/", filter = { "IndianBoy42" } },
  ui = {
    border = "single",
    custom_keys = {
      ["<localleader>l"] = false,
      ["<localleader>t"] = function(plugin)
        require("kitty").new_os_window { open_cwd = plugin.dir }
      end,
      ["<localleader>g"] = function(plugin)
        require("kitty").new_os_window({ open_cwd = plugin.dir }, "gitui")
      end,
      ["<localleader>m"] = function(plugin)
        vim.cmd("!smerge " .. plugin.dir)
        -- require("kitty").new_os_window({ open_cwd = plugin.dir }, "gitui")
      end,
      ["<C-n>"] = function()
        feedkeys(t "/[○●]<CR>", "m", false)
      end,
      ["<C-p>"] = function()
        feedkeys(t "?[○●]<CR>", "m", false)
      end,
    },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "gzip",
        "zip",
        "zipPlugin",
        "tar",
        "tarPlugin",
        "getscript",
        "getscriptPlugin",
        "vimball",
        "vimballPlugin",
        "2html_plugin",
        "logipat",
        "rrhelper",
        "spellfile_plugin",
        "matchit",
      },
    },
  },
}
