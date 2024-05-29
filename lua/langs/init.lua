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
  },
  _virtual_text = {
    -- TODO: this looks bad, has too much extra space
    spacing = 0,
    prefix = "",
    format = function() return "" end,
    suffix = "",
    hl_mode = "replace",
    virt_text_pos = "inline",
  },
  virtual_text_w_lines = {
    spacing = 4,
    prefix = "",
    format = function() return "" end,
    _format = function(diagnostic)
      local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
      local curr_line = diagnostic.end_lnum and (lnum >= diagnostic.lnum and lnum <= diagnostic.end_lnum)
        or (lnum == diagnostic.lnum)
      if curr_line then
        return ""
      else
        return diagnostic.message
      end
    end,
    severity = { max = vim.diagnostic.severity.WARN },
  },
  virtual_lines = {
    highlight_whole_line = false,
    severity = { min = vim.diagnostic.severity.ERROR },
    arrow_width = 0,
    current_line_opts = {
      severity = false,
    },
  },
  virtual_lines_all = {
    highlight_whole_line = false,
    arrow_width = 0,
    current_line_opts = {
      severity = false,
    },
  },
  signs = false,
  underline = {
    -- severity = {
    --   vim.diagnostic.severity.ERROR,
    --   vim.diagnostic.severity.INFO,
    --   vim.diagnostic.severity.HINT,
    -- },
  },
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
    virtual_text = diagnostic_config_all.virtual_text_w_lines,
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

local plugins = {
  -- TODO: https://github.com/lukas-reineke/lsp-format.nvim
  -- Languages
  { "kmonad/kmonad-vim", ft = "kmonad" },
  { "janet-lang/janet.vim", ft = "kmonad" },
  { "gennaro-tedesco/nvim-jqx", ft = "json" },
  { "Myzel394/jsonfly.nvim", ft = "json" },
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
