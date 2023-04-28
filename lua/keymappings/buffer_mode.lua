local cmd = utils.cmd
local go_to_buffer_abs = false
return {
  setup = function()
    local hydra_peek = require "hydra" {
      name = "Peek Buffers",
      body = "<leader>B",
      config = {
        color = "red",
        on_enter = function() vim.g.hydra_peek_buffer = vim.api.nvim_get_current_buf() end,
        on_exit = function() vim.api.nvim_set_current_buf(vim.g.hydra_peek_buffer) end,
      },
      heads = {
        { "1", function() require("bufferline").go_to(1, go_to_buffer_abs) end, { desc = "to 1" } },
        { "2", function() require("bufferline").go_to(2, go_to_buffer_abs) end, { desc = "to 2" } },
        { "3", function() require("bufferline").go_to(3, go_to_buffer_abs) end, { desc = "to 3" } },
        { "4", function() require("bufferline").go_to(4, go_to_buffer_abs) end, { desc = "to 4" } },
        { "5", function() require("bufferline").go_to(5, go_to_buffer_abs) end, { desc = "to 5" } },
        { "6", function() require("bufferline").go_to(6, go_to_buffer_abs) end, { desc = "to 6" } },
        { "7", function() require("bufferline").go_to(7, go_to_buffer_abs) end, { desc = "to 7" } },
        { "8", function() require("bufferline").go_to(8, go_to_buffer_abs) end, { desc = "to 8" } },
        { "9", function() require("bufferline").go_to(9, go_to_buffer_abs) end, { desc = "to 9" } },
        { "h", cmd "BufferLineCycleNext", { desc = "Next" } },
        { "l", cmd "BufferLineCyclePrev", { desc = "Prev" } },
      },
    }
    require "hydra" {
      name = "Buffers",
      config = {
        on_key = function()
          vim.wait(200, function()
            vim.cmd.redraw()
            return true
          end, 30, false)
        end,
        color = "red",
        hint = {
          border = "rounded",
          type = "window",
          position = "top",
          show_name = true,
        },
      },
      body = "<leader>b",
      heads = {
        { "c", cmd "Bdelete!", { desc = "Close" } },
        { "C", cmd "Bdelete!", { desc = "Close Win" } },
        { "p", cmd "BufferLineTogglePin", { desc = "Pin" } },
        { "P", function() hydra_peek:activate() end, { desc = "Peek", exit_before = true } },
        { "n", cmd "enew", { desc = "New" } },
        { "<tab>", "<tab>", { desc = "last" } },
        { "1", function() require("bufferline").go_to(1, go_to_buffer_abs) end, { desc = "to 1" } },
        { "2", function() require("bufferline").go_to(2, go_to_buffer_abs) end, { desc = "to 2" } },
        { "3", function() require("bufferline").go_to(3, go_to_buffer_abs) end, { desc = "to 3" } },
        { "4", function() require("bufferline").go_to(4, go_to_buffer_abs) end, { desc = "to 4" } },
        { "5", function() require("bufferline").go_to(5, go_to_buffer_abs) end, { desc = "to 5" } },
        { "6", function() require("bufferline").go_to(6, go_to_buffer_abs) end, { desc = "to 6" } },
        { "7", function() require("bufferline").go_to(7, go_to_buffer_abs) end, { desc = "to 7" } },
        { "8", function() require("bufferline").go_to(8, go_to_buffer_abs) end, { desc = "to 8" } },
        { "9", function() require("bufferline").go_to(9, go_to_buffer_abs) end, { desc = "to 9" } },
        { "<C-1>", function() require("bufferline").move_to(1) end, { desc = "to 1" } },
        { "<C-2>", function() require("bufferline").move_to(2) end, { desc = "to 2" } },
        { "<C-3>", function() require("bufferline").move_to(3) end, { desc = "to 3" } },
        { "<C-4>", function() require("bufferline").move_to(4) end, { desc = "to 4" } },
        { "<C-5>", function() require("bufferline").move_to(5) end, { desc = "to 5" } },
        { "<C-6>", function() require("bufferline").move_to(6) end, { desc = "to 6" } },
        { "<C-7>", function() require("bufferline").move_to(7) end, { desc = "to 7" } },
        { "<C-8>", function() require("bufferline").move_to(8) end, { desc = "to 8" } },
        { "<C-9>", function() require("bufferline").move_to(9) end, { desc = "to 9" } },
        { "l", cmd "BufferLineCycleNext", { desc = "Next" } },
        { "h", cmd "BufferLineCyclePrev", { desc = "Prev" } },
        { "j", cmd "BufferLineMoveNext", { desc = "Move Next" } },
        { "k", cmd "BufferLineMovePrev", { desc = "Move Prev" } },
        { "D", cmd "BufferLineSortByDirectory", { desc = "sort directory" } },
        { "E", cmd "BufferLineSortByExtension", { desc = "sort language" } },
        { "<C-h>", cmd "BufferLineCloseLeft", { desc = "close left" } },
        { "<C-l>", cmd "BufferLineCloseRight", { desc = "close right" } },
        { "<C-c>", (cmd "BufferLineCloseLeft") .. (cmd "BufferLineCloseRight"), { desc = "close others" } },
        { "<ESC>", nil, { exit = true, nowait = true, desc = "exit" } },
      },
    }

    -- Tab management keybindings
    -- TODO: make this a hydra
    local tab_mgmt = {
      t = {
        function()
          if #vim.api.nvim_list_tabpages() == 1 then
            vim.cmd "tabnew"
          else
            vim.cmd "tabnext"
          end
        end,
        "Next",
      },
      -- ["<C-t>"] = { cmd "tabnext", "which_key_ignore" },
      n = { cmd "tabnew", "New" },
      q = { cmd "tabclose", "Close" },
      p = { cmd "tabprev", "Prev" },
      l = { cmd "Telescope telescope-tabs list_tabs", "List tabs" },
      o = { cmd "tabonly", "Close others" },
      ["1"] = { cmd "tabfirst", "First tab" },
      ["0"] = { cmd "tablast", "Last tab" },
    }
    require("which-key").register(tab_mgmt, {
      mode = "n",
      prefix = "<leader>t",
      noremap = true,
      silent = true,
    })
  end,
}
