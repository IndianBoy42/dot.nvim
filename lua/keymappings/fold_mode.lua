local outer_start = function()
  local c = vim.api.nvim_win_get_cursor(0)
  vim.cmd "norm! [z"
  local nc = vim.api.nvim_win_get_cursor(0)
  if c[1] == nc[1] and c[2] == nc[2] then vim.cmd "norm! zk[z" end
end
return {
  setup = function()
    mappings.repeatable("z", "Fold", {
      "<cmd>norm zj<cr>",
      "<cmd>norm zk<cr>",
    })

    local hydra = require "hydra" {
      name = "Folds",
      hint = "z, o, c, O, C",
      config = {
        color = "pink",
        invoke_on_body = false,
        hint = {
          float_opts = { border = "rounded" },
          offset = -1,
        },
      },
      mode = "n",
      body = "z",
      heads = {
        { "<ESC>", nil, { exit = true, nowait = true, desc = "exit" } },
        {
          "#",
          function() vim.lsp.foldclose "comment" end,
          { desc = "Toggle Comments" },
        },
        {
          "i",
          function() vim.lsp.foldclose "region" end,
          { desc = "Toggle Inactive" },
        },
        {
          "I",
          function() vim.lsp.foldclose "imports" end,
          { desc = "Toggle Imports" },
        },
        { "z", "za", { desc = "Toggle", nowait = true } },
        { "a", "za", { desc = "Toggle" } },
        { "A", "zA", { desc = "Toggle All" } },
        { "o", "zo", { desc = "Open" } },
        { "c", "zc", { desc = "Close" } },
        { "l", "zo", { desc = "Open" } },
        { "h", "zc", { desc = "Close" } },
        { "O", "zO", { desc = "Open all" } },
        { "C", "zC", { desc = "Close all" } },
        { "j", "zj", { desc = "Next" } },
        { "k", "zk", { desc = "Prev" } },
        { O.goto_next, "zj", { desc = "Next" } },
        { O.goto_previous, "zk", { desc = "Prev" } },
        -- { "j", "<cmd>norm zj<cr>", { desc = "Next", private = true } },
        { O.goto_next_outer, "[z", { desc = "Outer End" } },
        -- { "k", "<cmd>norm zk<cr>", { desc = "Prev" } },
        -- { "k", outer_start, { desc = "Prev", private = true } },
        { O.goto_prev_outer, outer_start, { desc = "Outer Start" } },
        { "m", "zm", { desc = "Close More" } },
        { "r", "zr", { desc = "Open More" } },
        { "M", "zM", { desc = "Close All" } },
        { "R", "zR", { desc = "Open All" } },
        { -- TODO:
          "p",
          function()
            local winid = require("ufo").peekFoldedLinesUnderCursor()
            if winid then
              local bufnr = vim.api.nvim_win_get_buf(winid)
              local keys = { "a", "i", "o", "A", "I", "O", "gd", "gr" }
              for _, k in ipairs(keys) do
                -- Add a prefix key to fire `trace` action,
                map("n", k, O.localleader .. k, { noremap = false, buffer = bufnr })
              end
            else
              -- nvimlsp
              vim.lsp.buf.hover()
            end
          end,
        },
      },
    }
    require("keymappings.jump_mode").repeatable("z", "Folds", {
      "<cmd>norm zj<cr>",
      "<cmd>norm zk<cr>",
      "<cmd>norm ]z<cr>",
      "<cmd>norm [z<cr>",
    }, {})
  end,
}
