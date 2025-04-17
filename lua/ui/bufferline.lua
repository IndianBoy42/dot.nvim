local M = {
  "akinsho/bufferline.nvim",
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
      show_close_icon = false,
      show_tab_indicators = true,
      close_command = function(bufnum) Snacks.bufdelete(bufnum) end,
      right_mouse_command = function(bufnum) Snacks.bufdelete(bufnum) end,
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
