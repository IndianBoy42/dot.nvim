local feedkeys = vim.api.nvim_feedkeys
local termcodes = vim.api.nvim_replace_termcodes
local function t(k) return termcodes(k, true, true, true) end

Au.grp("lazy_filetype", function(au)
  au("Filetype", {
    pattern = "lazy",
    callback = function() utils.lsp.toggle_diag_lines() end,
  })
end)

return {
  defaults = {
    lazy = true,
    config = true,
    -- TODO:
    -- cond = function(plugin)
    --   if os.getenv "NVIM" ~= nil then
    --     if plugin[1] ~= "willothy/flatten.nvim" then return false end
    --     return true
    --   end
    --   return true
    -- end,
  },
  install = {
    colorscheme = { "onedark", "torte" },
  },
  checker = {
    enabled = true,
  },
  change_detection = {
    enabled = false,
  },
  dev = {
    path = "~/plugins.nvim/",
    filter = { "IndianBoy42" },
  },
  ui = {
    border = "rounded",
    custom_keys = {
      ["<localleader>l"] = false,
      ["<localleader>t"] = function(plugin) require("kitty.current_win").new_os_window { open_cwd = plugin.dir } end,
      ["<localleader>g"] = function(plugin)
        require("kitty.current_win").new_os_window({ open_cwd = plugin.dir }, "gitui")
      end,
      ["<localleader>m"] = function(plugin)
        vim.cmd("!smerge " .. plugin.dir)
        -- require("kitty").new_os_window({ open_cwd = plugin.dir }, "gitui")
      end,
      ["<localleader>h"] = function(plugin)
        vim.cmd("!gh repo view --web " .. plugin[1])
        -- require("kitty").new_os_window({ open_cwd = plugin.dir }, "gitui")
      end,
      ["<localleader>n"] = function() feedkeys(t "/[○●]<CR>", "n", false) end,
      ["<localleader>p"] = function() feedkeys(t "?[○●]<CR>", "n", false) end,
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
