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
  virtual_lines = { highlight_whole_line = false },
  signs = true,
  underline = { severity = "Error" },
  severity_sort = true,
  update_in_insert = true,
  float = {
    header = false,
    border = "rounded",
    scope = "line",
  },
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
    parameter_hints = { prefix = "« ", show = true },
    type_hints = { prefix = "∈ ", show = true },
    max_len_align = true,
    max_len_align_padding = 1,

    highlight = "DiagnosticVirtualTextInfo",
    low_prio_highlight = "Comment",
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
  hover_config = {},
}
configs.inlay_hints.parameter_hints_prefix = configs.inlay_hints.parameter_hints.prefix
configs.inlay_hints.other_hints_prefix = configs.inlay_hints.type_hints.prefix

local inlay_hints = utils.lsp.inlay_hints
if inlay_hints then
  utils.lsp.on_attach(function(client, bufnr)
    if client.server_capabilities.inlayHintProvider then
      inlay_hints(bufnr, true)

      -- local modes = {
      --   true, -- Default
      --   -- n = true,
      --   -- i = false,
      -- }
      --
      -- if true then
      --   vim.api.nvim_create_autocmd("ModeChanged", {
      --     buffer = bufnr,
      --     group = "lsp_inlay_hints",
      --     callback = function(args)
      --       inlay_hint(bufnr, modes[vim.api.nvim_get_mode().mode] or modes[0])
      --     end,
      --   })
      -- end
    end
  end, "lsp_inlay_hints")
end

local plugins = {
  -- TODO: https://github.com/lukas-reineke/lsp-format.nvim
  -- Languages
  { "kmonad/kmonad-vim", ft = "kmonad" },
  { "janet-lang/janet.vim", ft = "kmonad" },
  { "gennaro-tedesco/nvim-jqx", ft = "json" },
  {
    "LhKipp/nvim-nu",
    build = ":TSInstall nu",
    main = "nu",
    opts = {},
  },
  -- TODO: https://github.com/codethread/qmk.nvim
}

for k, v in pairs(configs) do
  plugins[k] = v
end

return plugins
