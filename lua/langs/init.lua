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
    -- event = { "BufReadPost", "BufNewFile" },
    branch = "anticonceal",
    cond = not configs.inlay_hints.by_tools,
    config = function()
      require("lsp-inlayhints").setup {
        -- inlay_hints = configs.inlay_hints,
        inlay_hints = {
          highlight = configs.inlay_hints.highlight,
          low_prio_highlight = configs.inlay_hints.low_prio_highlight,
          virt_text_formatter = function(label, hint, opts, client_name)
            if client_name == "lua_ls" then
              hint.paddingLeft = false
              hint.paddingRight = false
              -- if hint.kind == 2 then
              --   hint.paddingLeft = false
              -- else
              --   hint.paddingRight = false
              -- end
            end

            local highlight = opts.highlight
            if client_name == "rust_analyzer" then
              if hint.kind == nil or hint.kind > 2 then highlight = opts.low_prio_highlight end
            end

            local vt = {}
            if hint.paddingLeft then vt[#vt + 1] = { " ", "None" } end
            vt[#vt + 1] = { label, highlight }
            if hint.paddingRight then vt[#vt + 1] = { " ", "None" } end

            return vt
          end,
        },
        enabled_at_startup = not configs.inlay_hints.by_tools,
        -- enabled_at_startup = false,
      }
    end,
    init = function()
      utils.lsp.cb_on_attach(function(client, bufnr)
        --
        require("lsp-inlayhints").on_attach(client, bufnr, false)
      end)
    end,
  },
  {
    "joechrisellis/lsp-format-modifications.nvim",
    init = function()
      utils.lsp.cb_on_attach(function(client, bufnr)
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
}

for k, v in pairs(configs) do
  plugins[k] = v
end

return plugins
