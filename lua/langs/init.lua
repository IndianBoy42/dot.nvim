local diagnostic_config_all = {
  current_line = {
    auto = true,
    -- FIXME: only additive
    -- virtual_lines = false,
    -- virtual_text = { format = function() return "" end },
    -- signs = false,
    -- underline = false,
    virtual_lines = {
      severity = { max = vim.diagnostic.severity.WARN },
    },
  },
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
    _format = function() return "" end,
    format = function(diagnostic)
      local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
      local iswarn = diagnostic.severity == vim.diagnostic.severity.WARN
      if iswarn then return diagnostic.message end
      if diagnostic.severity == vim.diagnostic.severity.HINT then return "HINT" end
      if diagnostic.severity == vim.diagnostic.severity.INFO then return "INFO" end
      local curr_line = diagnostic.end_lnum and (lnum >= diagnostic.lnum and lnum <= diagnostic.end_lnum)
        or (lnum == diagnostic.lnum)
      return ""
    end,
    severity = { max = vim.diagnostic.severity.WARN },
  },
  virtual_lines = {
    -- severity = { max = vim.diagnostic.severity.WARN },
    severity = { min = vim.diagnostic.severity.ERROR },
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
  jump = {
    float = false,
  },
}
local diagnostic_config = vim.tbl_extend("keep", {
  virtual_text = diagnostic_config_all.virtual_lines and diagnostic_config_all.virtual_text_w_lines
    or diagnostic_config_all.virtual_text,
}, diagnostic_config_all)
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
  diagnostic_config = diagnostic_config,
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
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      -- { "folke/neoconf.nvim", cmd = "Neoconf",                                config = true },
      {
        "williamboman/mason.nvim",
        cmd = "Mason",
        opts = {
          ensure_installed = {},
          ui = {
            border = "rounded",
          },
          registries = {
            "lua:masonry",
            "github:mason-org/mason-registry",
          },
        },
        config = function(_, opts)
          require("mason").setup(opts)
          local mr = require "mason-registry"
          for _, tool in ipairs(opts.ensure_installed) do
            local p = mr.get_package(tool)
            if not p:is_installed() then p:install() end
          end
        end,
      },
      { "williamboman/mason-lspconfig.nvim", enabled = true },
    },
    opts = {
      -- LSP Server Settings
      ---@type lspconfig.options
      servers = {
        jsonls = {},
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        -- example to setup with typescript.nvim
        -- tsserver = function(_, opts)
        --   require("typescript").setup({ server = opts })
        --   return true
        -- end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
    config = function(_, opts)
      -- TODO: use vim.lsp.config for... whatever
      if vim.env.NVIM_LSP_LOG_DEBUG ~= nil and vim.env.NVIM_LSP_LOG_DEBUG ~= "" then
        -- vim.lsp.set_log_level(vim.log.levels.DEBUG)
        -- require("vim.lsp.log").set_format_func(vim.inspect)
      end

      require("lspconfig.ui.windows").default_options.border = "rounded"

      -- TODO: Refactor this to a loop and opts
      local signs = {
        { "LspDiagnosticsSignError", "" },
        { "LspDiagnosticsSignWarning", "" },
        { "LspDiagnosticsSignHint", "" },
        { "LspDiagnosticsSignInformation", "" },
      }
      local sign_define = vim.fn.sign_define
      for _, sign in ipairs(signs) do
        sign_define(sign[1], { texthl = sign[1], text = sign[2], numhl = sign[1] })
      end

      -- Handlers
      local lsp = vim.lsp
      local handlers = vim.lsp.handlers
      local lspwith = vim.lsp.with

      vim.diagnostic.config(diagnostic_config)
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = vim.api.nvim_create_augroup("diag_current_line", { clear = true }),
        callback = function()
          local currlineopts = vim.diagnostic.config().current_line
          if not currlineopts or not currlineopts.auto then return end
          utils.lsp.diag_vline()
        end,
      })

      do
        local current_definition_handler = vim.lsp.handlers["textDocument/definition"]
        vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, config)
          if not result then vim.notify "could not find definition" end
          current_definition_handler(err, result, ctx, config)
        end
      end

      -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua
      local servers = opts.servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      local lsp_sel_rng = require "lsp-selection-range"
      lsp_sel_rng.update_capabilities(capabilities)

      -- TODO: has limitations on linux apparently
      if true then
        vim.tbl_extend("force", capabilities, {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        })
      end

      -- utils.lsp.on_attach(function(client, bufnr) utils.lsp.document_highlight(client, bufnr) end)

      handlers["textDocument/codeLens"] = lspwith(vim.lsp.codelens.on_codelens, require("langs").codelens_config)
      utils.lsp.on_attach(function(client, bufnr)
        if false and client:supports_method "textDocument/codeLens" then
          vim.api.nvim_create_autocmd(
            { "CursorHold", "InsertLeave", "BufEnter" },
            { buffer = bufnr, callback = vim.lsp.codelens.refresh }
          )
        end

        if client:supports_method "textDocument/inlayHint" then
          vim.lsp.inlay_hint.enable(true)

          -- TODO:
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

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if false then
          -- TODO: multiplex all lsp servers
          server_opts.cmd = "ra-multiplex"
          -- TODO: server_opts.cmd = vim.lsp.rpc.connect("127.0.0.1", 27631)
          server_opts.init_options = {
            raMultiplex = {
              server = server_opts.cmd,
            },
          }
        end

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then return end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then return end
        end
        require("lspconfig")[server].setup(server_opts)
      end

      local mlsp = require "mason-lspconfig"
      local available = mlsp.get_available_servers()

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(available, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      require("mason-lspconfig").setup { ensure_installed = ensure_installed }
      require("mason-lspconfig").setup_handlers { setup }

      require("utils.lsp").format_on_save(true)
    end,
  },
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
