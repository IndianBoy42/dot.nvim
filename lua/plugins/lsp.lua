-- LSP extras
return {
  {
    "Kasama/nvim-custom-diagnostic-highlight",
    opts = {},
  },
  {
    "yioneko/nvim-type-fmt",
    event = "LazyFile",
  },
  {
    "hrsh7th/nvim-linkedit",
    opts = {
      sources = {
        {
          name = "lsp_linked_editing_range",
          on = { "insert", "operator" },
        },
      },
    },
  },
  {
    "joechrisellis/lsp-format-modifications.nvim",
    lazy = true,
    init = function()
      utils.lsp.on_attach(function(client, bufnr)
        if client.supports_method "textDocument/rangeFormatting" then
          vim.api.nvim_buf_create_user_command(bufnr, "FormatModifications", function()
            local lsp_format_modifications = require "lsp-format-modifications"
            lsp_format_modifications.format_modifications(client, bufnr)
          end, {})

          local cwd = vim.fn.getcwd()
          for dir in vim.fs.parents(cwd) do
            if vim.tbl_contains(O.format_on_save_mod, dir) then
              vim.b[bufnr].Format_on_save_mode = vim.g.Format_on_save_mode == true and "mod"
              break
            end
          end
        end
      end)
    end,
  },
  -- TODO: https://github.com/roobert/hoversplit.nvim
  -- TODO:  {"jmbuhr/otter.nvim"}
}
