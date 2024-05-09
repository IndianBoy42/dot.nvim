local prev_fold = function()
  local c = vim.api.nvim_win_get_cursor(0)
  vim.cmd "norm [z"
  local nc = vim.api.nvim_win_get_cursor(0)
  if c[1] == nc[1] and c[2] == nc[2] then vim.cmd "norm zk[z" end
end
return {
  setup = function()
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
        { "z", "za", { desc = "Toggle" } },
        { "o", "zo", { desc = "Open" } },
        { "c", "zc", { desc = "Close" } },
        { "O", "zO", { desc = "Open all" } },
        { "C", "zC", { desc = "Close all" } },
        { O.goto_next, "<cmd>norm zj<cr>", { desc = "Next" } },
        { O.goto_previous, "<cmd>norm zk<cr>", { desc = "Prev" } },
        { "j", "<cmd>norm zj<cr>", { desc = "Next", private = true } },
        { "]", "<cmd>norm zj<cr>", { desc = "Next" } },
        -- { "k", "<cmd>norm zk<cr>", { desc = "Prev" } },
        { "k", prev_fold, { desc = "Prev", private = true } },
        { "[", prev_fold, { desc = "Prev" } },
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
