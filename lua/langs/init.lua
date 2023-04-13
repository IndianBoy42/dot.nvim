local diagnostic_config_all = {
  _virtual_text = function(ns, bufnr)
    local highest = utils.lsp.get_highest_diag(ns, bufnr)
    return {
      spacing = 4,
      prefix = "",
      severity = { min = highest },
    }
  end,
  virtual_text = {
    spacing = 4,
    prefix = "",
    severity_limit = "Warning",
  },
  virtual_lines = true,
  signs = true,
  underline = { severity = "Error" },
  severity_sort = true,
  update_in_insert = true,
}
local configs = {
  inlay_hints = {
    auto = true,
    by_tools = false,
    -- Only show inlay hints for the current line
    only_current_line = false,
    -- Event which triggers a refersh of the inlay hints.
    -- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
    -- not that this may cause  higher CPU usage.
    -- This option is only respected when only_current_line and
    -- autoSetHints both are true.
    -- only_current_line_autocmd = "CursorHold",

    show_parameter_hints = true,
    parameter_hints = { prefix = "« " },
    type_hints = { prefix = "∈ " },
    max_len_align = true,
    max_len_align_padding = 1,

    highlight = "DiagnosticVirtualTextInfo",
  },
  mason_ensure_installed = function(app)
    return {
      "williamboman/mason.nvim",
      opts = function(_, opts) vim.list_extend(opts.ensure_installed, app) end,
    }
  end,
  diagnostic_config = vim.tbl_extend("keep", {
    virtual_text = false,
    signs = false,
  }, diagnostic_config_all),
  diagnostic_config_all = diagnostic_config_all,
  codelens_config = {
    virtual_text = { spacing = 0, prefix = "" },
    signs = true,
    underline = true,
    severity_sort = true,
  },
}
configs.inlay_hints.parameter_hints_prefix = configs.inlay_hints.parameter_hints.prefix
configs.inlay_hints.other_hints_prefix = configs.inlay_hints.type_hints.prefix

local plugins = {
  -- TODO: https://github.com/lukas-reineke/lsp-format.nvim
  -- Languages
  { "kmonad/kmonad-vim", ft = "kmonad" },
  { "janet-lang/janet.vim", ft = "kmonad" },
  { "gennaro-tedesco/nvim-jqx", ft = "json" },
  {
    "Kasama/nvim-custom-diagnostic-highlight",
    opts = {},
  },
  {
    "LhKipp/nvim-nu",
    build = ":TSInstall nu",
    main = "nu",
    opts = {},
  },
  -- TODO: https://github.com/codethread/qmk.nvim
  {
    "lvimuser/lsp-inlayhints.nvim",
    cond = not configs.inlay_hints.by_tools,
    config = function()
      require("lsp-inlayhints").setup {
        inlay_hints = configs.inlay_hints,
        enabled_at_startup = not configs.inlay_hints.by_tools,
      }
      vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
      vim.api.nvim_create_autocmd("LspAttach", {
        group = "LspAttach_inlayhints",
        callback = function(args)
          if not (args.data and args.data.client_id) then return end

          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          require("lsp-inlayhints").on_attach(client, bufnr)
        end,
      })
    end,
  },
}

for k, v in pairs(configs) do
  plugins[k] = v
end

return plugins
