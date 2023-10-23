return {
  {
    "Kasama/nvim-custom-diagnostic-highlight",
    opts = {},
  },
  {
    "yioneko/nvim-type-fmt",
    lazy = false,
  },
  {
    "joechrisellis/lsp-format-modifications.nvim",
    init = function()
      utils.lsp.on_attach(function(client, bufnr)
        local have = client.server_capabilities.documentRangeFormattingProvider
        if have and client.name == "null-ls" then
          local ft = vim.bo[bufnr].filetype
          have = #require("null-ls.sources").get_available(ft, "NULL_LS_RANGE_FORMATTING") > 0
        end
        if have then
          local lsp_format_modifications = require "lsp-format-modifications"
          lsp_format_modifications.attach(
            client,
            bufnr,
            { format_on_save = false, format_callback = utils.lsp.format, experimental_empty_line_handling = true }
          )
        end
      end)
    end,
  },
  -- TODO:  {"jmbuhr/otter.nvim"}
}
