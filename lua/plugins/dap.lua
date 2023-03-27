-- TODO: ALL OF THIS IS TODO

local function dap_hydra_setup()
  local dap = require "dap"
  local dapui = require "dapui"
  local hint = [[
 _n_: step over   _s_: Cont/Start   _b_: Breakpoint   _K_: Eval
 _i_: step into   _x_: Quit         ^e^: Edit     _<M-k>_: Expr
 _o_: step out    _X_: Stop         ^o^: Open
 _c_: to cursor   _p_: Pause        _R_: Restart
 ^ ^              _C_: Close UI     ^ ^           _<ESC>_: exit
]]
  local partial = utils.partial
  require "hydra" {
    hint = hint,
    config = {
      color = "pink",
      invoke_on_body = true,
      hint = {
        position = "bottom",
        border = "rounded",
      },
    },
    name = "dap",
    mode = { "n", "x" },
    body = "<leader>D",
    heads = {
      { "n", dap.step_over, { silent = true } },
      { "i", dap.step_into, { silent = true } },
      { "o", dap.step_out, { silent = true } },
      { "c", dap.run_to_cursor, { silent = true } },
      { "s", dap.continue, { silent = true } },
      { "p", dap.pause, { silent = true } },
      { "R", dap.restart, { silent = true } },
      -- { "x", ":lua require'dap'.disconnect({ terminateDebuggee = false })<CR>", { exit = true, silent = true } },
      -- { "x", partial(dap.disconnect, { terminateDebuggee = false }), { exit = true, silent = true } },
      { "x", dap.terminate, { exit = true, silent = true } },
      { "X", dap.close, { silent = true } },
      { "C", "<cmd>lua require('dapui').close()<cr>:DapVirtualTextForceRefresh<CR>", { silent = true } },
      { "b", dap.toggle_breakpoint, { silent = true } },
      -- { "K", require("dap.ui.widgets").hover, { silent = true } },
      { "K", dapui.eval, { silent = true } },
      {
        "<M-k>",
        partial(vim.ui.input, { prompt = "Eval:" }, function(input)
          if #input > 0 then
            dapui.eval(input, {})
          else
            dapui.eval(nil, {})
          end
        end),
        { silent = true },
      },

      { "<ESC>", nil, { exit = true, nowait = true } },
    },
  }
end

local function dap_signs()
  -- local filled = ""
  -- local empty = ""
  -- vim.fn.sign_define("DapBreakpoint", { text = filled, texthl = "", linehl = "", numhl = "" })
  -- vim.fn.sign_define("DapBreakpointCondition", { text = filled, texthl = "", linehl = "", numhl = "" })
  -- vim.fn.sign_define("DapBreakpointRejected", { text = empty, texthl = "", linehl = "", numhl = "" })
  -- vim.fn.sign_define("DapLogPoint", { text = filled, texthl = "", linehl = "", numhl = "" })
  -- vim.fn.sign_define("DapStopped", { text = filled, texthl = "", linehl = "", numhl = "" })

  vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
  vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticInfo" })
  vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
  vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DiagnosticInfo" })
  vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn" })
end

return {
  -- https://github.com/anuvyklack/hydra.nvim/issues/3#issuecomment-1162988750
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "jay-babu/mason-nvim-dap.nvim",
        opts = {
          automatic_installation = false,
          automatic_setup = true,
        },
      },
      {
        "rcarriga/nvim-dap-ui",
        main = "dapui",
        opts = { floating = { border = "rounded" } },
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
          highlight_new_as_changed = true, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)

          -- virt_lines = true,
        },
      },
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"

      dap_signs()

      dap.defaults.fallback.terminal_win_cmd = "50vsplit new"

      dap.listeners.after.event_initialized.dapui_config = dapui.open
      dap.listeners.before.event_terminated.dapui_config = dapui.close
      dap.listeners.before.event_exited.dapui_config = dapui.close

      dap.listeners.after.event_initialized.virt_diags = function() utils.lsp.disable_diagnostic() end
      dap.listeners.before.event_terminated.virt_diags = function() utils.lsp.enable_diagnostic() end
      dap.listeners.before.event_exited.virt_diags = function() utils.lsp.enable_diagnostic() end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dap-repl",
        callback = function() require("dap.ext.autocompl").attach() end,
      })

      dap_hydra_setup()
    end,
    keys = {
      -- TODO: hydra.nvim submode
      -- name = "Debug",
      { "<leader>xd", function() require("dapui").toggle() end, desc = "Toggle DAP-UI" },
      { "<leader>D", desc = "Debugging" },
    },
  },
}
