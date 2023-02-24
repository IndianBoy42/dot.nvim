return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "jay-babu/mason-nvim-dap.nvim",
        opts = {
          automatic_installation = false,
        },
      },
    },
    config = function()
      local dap = require "dap"
      vim.fn.sign_define("DapBreakpoint", O.breakpoint_sign)
      dap.defaults.fallback.terminal_win_cmd = "50vsplit new"
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    config = true,
  },
}
