return {
  lazy = function(fn)
    vim.api.nvim_create_autocmd("ModeChanged", {
      group = vim.api.nvim_create_augroup("mini_ai_lazy", {}),
      pattern = "*",
      callback = function()
        local spec = require("mini.ai").gen_spec
        -- TODO: text objects for lua raw strings
        local to = fn(spec)
        local t = vim.b.miniai_config or {
          custom_textobjects = {},
        }
        for k, v in pairs(to) do
          t.custom_textobjects[k] = v
        end
        vim.b.miniai_config = t
      end,
    })
  end,
}
