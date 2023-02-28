-- TODO: ALL OF THIS IS TODO
return {
  -- https://github.com/anuvyklack/hydra.nvim/issues/3#issuecomment-1162988750
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

    keys = {
      -- TODO: hydra.nvim submode
      -- name = "Debug",
      -- {
      --   "<leader>DU",
      --   function()
      --     require("dapui").toggle()
      --   end,
      --   desc = "Toggle DAP-UI",
      -- },
      -- {
      --   "<leader>Dv",
      --   function()
      --     require("dapui").eval()
      --   end,
      --   desc = "Eval",
      -- },
      -- {
      --   "<leader>Dt",
      --   function()
      --     require("dap").toggle_breakpoint()
      --   end,
      --   desc = "Toggle Breakpoint",
      -- },
      -- {
      --   "<leader>Db",
      --   function()
      --     require("dap").step_back()
      --   end,
      --   desc = "Step Back",
      -- },
      -- {
      --   "<leader>Dc",
      --   function()
      --     require("dap").continue()
      --   end,
      --   desc = "Continue",
      -- },
      -- {
      --   "<leader>DC",
      --   function()
      --     require("dap").run_to_cursor()
      --   end,
      --   desc = "Run To Cursor",
      -- },
      -- {
      --   "<leader>Dd",
      --   function()
      --     require("dap").disconnect()
      --   end,
      --   desc = "Disconnect",
      -- },
      -- {
      --   "<leader>Dg",
      --   function()
      --     require("dap").session()
      --   end,
      --   desc = "Get Session",
      -- },
      -- {
      --   "<leader>Di",
      --   function()
      --     require("dap").step_into()
      --   end,
      --   desc = "Step Into",
      -- },
      -- {
      --   "<leader>Do",
      --   function()
      --     require("dap").step_over()
      --   end,
      --   desc = "Step Over",
      -- },
      -- {
      --   "<leader>Du",
      --   function()
      --     require("dap").step_out()
      --   end,
      --   desc = "Step Out",
      -- },
      -- {
      --   "<leader>Dp",
      --   function()
      --     require("dap").pause.toggle()
      --   end,
      --   desc = "Pause",
      -- },
      -- {
      --   "<leader>Dr",
      --   function()
      --     require("dap").repl.toggle()
      --   end,
      --   desc = "Toggle Repl",
      -- },
      -- {
      --   "<leader>Ds",
      --   function()
      --     require("dap").continue()
      --   end,
      --   desc = "Start",
      -- },
      -- {
      --   "<leader>Dq",
      --   function()
      --     require("dap").stop()
      --   end,
      --   desc = "Quit",
      -- },
    },
  },
}
