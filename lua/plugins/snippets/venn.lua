return {
  "jbyuki/venn.nvim",
  config = function()
    local hint = [[
 Arrow^^^^^^   Select region with <C-v>
 ^ ^ _K_ ^ ^   _f_: surround it with box
 _H_ ^ ^ _L_
 ^ ^ _J_ ^ ^                      _<Esc>_
]]

    local Hydra = require "hydra"
    local venn_hydra = Hydra {
      name = "Draw Diagram",
      hint = hint,
      config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
          border = "rounded",
        },
        on_enter = function() vim.o.virtualedit = "all" end,
      },
      mode = "n",
      heads = {
        { "H", "<C-v>h:VBox<CR>" },
        { "J", "<C-v>j:VBox<CR>" },
        { "K", "<C-v>k:VBox<CR>" },
        { "L", "<C-v>l:VBox<CR>" },
        { "f", ":VBox<CR>", { mode = "v" } },
        { "<Esc>", nil, { exit = true } },
      },
    }
    vim.api.nvim_create_user_command("Venn", function() venn_hydra:activate() end, {})
  end,
  cmd = { "Venn" },
}
