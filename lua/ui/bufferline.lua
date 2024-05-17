local M = {
  "akinsho/nvim-bufferline.lua",
  event = "VeryLazy",
  branch = "main",
}
function M.config()
  -- Buffer line setup
  require("bufferline").setup {
    options = {
      indicator = {
        style = "icon",
        icon = "▎",
      },
      -- close_icon = '',
      close_icon = "",
      show_tab_indicators = true,
      show_close_icon = false,
      -- close_command = function(bufnum) require("bufdelete").bufdelete(bufnum, true) end,
      -- right_mouse_command = function(bufnum) require("bufdelete").bufdelete(bufnum, true) end,
      hover = {
        enabled = true,
        delay = 200,
        reveal = { "close" },
      },
      diagnostics = "nvim_lsp",
      separator_style = "slant",
    },
  }
end

return M
