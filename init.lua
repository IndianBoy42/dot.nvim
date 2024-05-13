local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- TODO:
-- -- If opening from inside neovim terminal then do not load all the other plugins
-- if os.getenv "NVIM" ~= nil then
--   require("lazy").setup {
--     require "plugins.flatten",
--   }
--   return
-- end

-- Make CTRL-i work separate to <TAB>
if false and vim.env.TERM == "xterm-kitty" then
  vim.cmd [[autocmd UIEnter * if v:event.chan ==# 0 | call chansend(v:stderr, "\x1b[>1u") | endif]]
  vim.cmd [[autocmd UILeave * if v:event.chan ==# 0 | call chansend(v:stderr, "\x1b[<1u") | endif]]
end

F = loadstring
_G.utils = require "utils"
-- _G.O = utils.setproxy(require "config") -- TODO: Phase this out, intercept accesses and log it
_G.O = require "config" -- TODO: Phase this out, intercept accesses and log it
_G.mappings = require "keymappings"
require "settings"()
_G.Au = require "autocmds"
Au.defaults()

-- require("lazy").setup("plugins", require "plugins.configs.lazynvim")
require("lazy").setup("plugins", require "plugins.configs.lazynvim")
