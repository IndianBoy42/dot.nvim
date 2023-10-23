return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- { "folke/neoconf.nvim", cmd = "Neoconf",                                config = true },
    -- { "folke/neodev.nvim",  opts = { experimental = { pathStrict = true } } },
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
  init = function() require("lsp.fswatch").setup() end,
  config = function(_, opts)
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
    vim.diagnostic.config(require("langs").diagnostic_config)
    handlers["textDocument/codeLens"] = lspwith(vim.lsp.codelens.on_codelens, require("langs").codelens_config)
    do
      local current_definition_handler = vim.lsp.handlers["textDocument/definition"]
      vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, config)
        if not result then vim.notify "could not find definition" end
        current_definition_handler(err, result, ctx, config)
      end
    end

    -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua
    local servers = opts.servers
    local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

    local lsp_sel_rng = require "lsp-selection-range"
    lsp_sel_rng.update_capabilities(capabilities)

    utils.lsp.on_attach(function(client, bufnr) utils.lsp.document_highlight(client, bufnr) end)

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
}
