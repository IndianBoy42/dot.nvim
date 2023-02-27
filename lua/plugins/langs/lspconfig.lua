return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- { "folke/neoconf.nvim", cmd = "Neoconf",                                config = true },
    -- { "folke/neodev.nvim",  opts = { experimental = { pathStrict = true } } },
    {
      "williamboman/mason.nvim",
      cmd = "Mason",
      config = function(_, opts)
        require("mason").setup(opts)
        local mr = require "mason-registry"
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end,
    },
    "williamboman/mason-lspconfig.nvim",
    -- mason-null-ls
    -- mason-nvim-dap
  },
  opts = {
    -- options for vim.diagnostic.config()
    diagnostics = {
      virtual_text = { spacing = 4, prefix = "", severity_limit = "Warning" },
      -- virtual_text = false,
      signs = true,
      underline = true,
      severity_sort = true,
      update_in_insert = true,
    },
    border = "rounded",
    rename_border = "none",
    -- Automatically format on save
    autoformat = true,
    -- options for vim.lsp.buf.format
    -- `bufnr` and `filter` is handled by the LazyVim formatter,
    -- but can be also overridden when specified
    format = {
      formatting_options = nil,
      timeout_ms = nil,
    },
    codeLens = {
      virtual_text = { spacing = 0, prefix = "" },
      signs = true,
      underline = true,
      severity_sort = true,
    },
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
    -- TODO: Refactor this to a loop and opts
    local sign_define = vim.fn.sign_define
    sign_define(
      "LspDiagnosticsSignError",
      { texthl = "LspDiagnosticsSignError", text = "", numhl = "LspDiagnosticsSignError" }
    )
    sign_define(
      "LspDiagnosticsSignWarning",
      { texthl = "LspDiagnosticsSignWarning", text = "", numhl = "LspDiagnosticsSignWarning" }
    )
    sign_define(
      "LspDiagnosticsSignHint",
      { texthl = "LspDiagnosticsSignHint", text = "", numhl = "LspDiagnosticsSignHint" }
    )
    sign_define(
      "LspDiagnosticsSignInformation",
      { texthl = "LspDiagnosticsSignInformation", text = "", numhl = "LspDiagnosticsSignInformation" }
    )

    -- Handlers
    local lsp = vim.lsp
    local handlers = vim.lsp.handlers
    local lspwith = vim.lsp.with
    vim.diagnostic.config(opts.diagnostics)
    handlers["textDocument/codeLens"] = lspwith(vim.lsp.codelens.on_codelens, opts.codeLens)
    -- handlers["textDocument/hover"] = lspwith(handlers.hover, {
    --   border = opts.border,
    -- })
    -- handlers["textDocument/signatureHelp"] = lspwith(handlers.signature_help, {
    --   border = opts.border,
    --   focusable = false,
    -- })

    -- symbols for autocomplete
    lsp.protocol.CompletionItemKind = {
      "   (Text) ",
      "   (Method)",
      "   (Function)",
      "   (Constructor)",
      " ﴲ  (Field)",
      "[] (Variable)",
      "   (Class)",
      " ﰮ  (Interface)",
      "   (Module)",
      " 襁 (Property)",
      "   (Unit)",
      "   (Value)",
      " 練 (Enum)",
      "   (Keyword)",
      "   (Snippet)",
      "   (Color)",
      "   (File)",
      "   (Reference)",
      "   (Folder)",
      "   (EnumMember)",
      " ﲀ  (Constant)",
      " ﳤ  (Struct)",
      "   (Event)",
      "   (Operator)",
      "   (TypeParameter)",
    }

    -- Lsp autocommands
    require("utils").define_augroups {
      _general_lsp = {
        { "FileType", "lspinfo", "nnoremap <silent> <buffer> q :q<CR>" },
        { "FileType", "lspinfo", "nnoremap <buffer> I :LspInstall " },
      },
      -- _codelens_refesh = {
      --   { "BufEnter,CursorHold,InsertLeave", "*", "lua vim.lsp.codelens.refresh()" },
      -- },
      -- _lsp_hover = {
      --   { "CursorHold, CursorHoldI", "*", "lua vim.lsp.buf.hover()" },
      -- },
    }

    -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua
    local servers = opts.servers
    local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

    local function setup(server)
      local server_opts = vim.tbl_deep_extend("force", {
        capabilities = vim.deepcopy(capabilities),
      }, servers[server] or {})

      if opts.setup[server] then
        if opts.setup[server](server, server_opts) then
          return
        end
      elseif opts.setup["*"] then
        if opts.setup["*"](server, server_opts) then
          return
        end
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

    if O.format_on_save then
      require("lsp.functions").format_on_save()
    end
  end,
}
