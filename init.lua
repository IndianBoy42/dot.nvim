local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

_G.utils = require "utils"
-- _G.O = utils.setproxy(require "config") -- TODO: Phase this out, intercept accesses and log it
_G.O = require "config" -- TODO: Phase this out, intercept accesses and log it
_G.mappings = require "keymappings"
require "settings"()

require("lazy").setup("plugins", {
  defaults = { lazy = true, config = true },
  install = { colorscheme = { "nebulous", "torte" } },
  checker = { enabled = true },
  change_detection = { enabled = false },
  dev = { path = "~/plugins.nvim/", filter = { "IndianBoy42" } },
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
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    mappings.setup()

    vim.ui.select = require("telescopes").uiselect()
    vim.ui.input = function(opts, on_confirm)
      opts = opts or {}
      -- opts.completion
      -- opts.highlight

      require("plugins.ui.input").inline_text_input {
        prompt = opts.prompt,
        border = O.input_border,
        enter = on_confirm,
        initial = opts.default,
        at_begin = false,
        minwidth = 20,
        insert = true,
      }
    end
    -- require "commands"
  end,
})
