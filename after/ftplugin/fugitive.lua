vim.o.previewwindow = true
-- TODO: hydra.nvim submode?
require("plugins.git.keys").fugitive()
--   vim.cmd [[
-- augroup _fugitive
--   autocmd! * <buffer>
--   autocmd CursorHold,CursorHoldI <buffer> lua require'which-key'.show()
-- augroup END
-- ]]
