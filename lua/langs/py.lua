local function get_python_path(workspace)
  local util = require "lspconfig/util"
  local path = util.path
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then return path.join(vim.env.VIRTUAL_ENV, "bin", "python") end

  -- Find and use virtualenv in workspace directory.
  for _, pattern in ipairs { "*", ".*" } do
    local match = vim.fn.glob(path.join(workspace, pattern, "pyvenv.cfg"))
    if match ~= "" then return path.join(path.dirname(match), "bin", "python") end
  end

  -- Fallback to system Python.
  return vim.fn.exepath "python3" or vim.fn.exepath "python" or "python"
end
local M = {
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = {},
  --   ---@param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     opts.sources = vim.list_extend(opts.sources, {
  --       { name = "jupyter", group_index = 2 },
  --     })
  --   end,
  -- },
  {
    "lkhphuc/jupyter-kernel.nvim",
    init = function()
      vim.api.nvim_create_autocmd("Filetype", {
        pattern = "python",
        callback = function()
          local srcs = require("langs.complete").sources
          srcs(vim.list_extend(srcs(), { name = "jupyter", group_index = 2 }))
          local map = vim.keymap.setl
          map("n", O.hover_key, "<cmd>JupyterInspect<cr>", {})
          map("n", "<localleader>i", "<cmd>JupyterInspect<cr>", {})
          map("n", "<localleader>x", "<cmd>JupyterExecute<cr>", {})
          map("x", "<localleader>x", ":JupyterExecute<cr>", {})
          map("n", "<localleader>ja", "<cmd>JupyterAttach<cr>", {})
        end,
        group = vim.api.nvim_create_augroup("jupyter_kernel_setup", {}),
      })
    end,
    cmd = { "JupyterAttach", "JupyterInspect", "JupyterExecute" },
    build = ":UpdateRemotePlugins",
    opts = {},
  },
  -- {
  --   "WhiteBlackGoose/magma-nvim-goose",
  --   run = ":UpdateRemotePlugins",
  -- },
  -- {
  --   "untitled-ai/jupyter_ascending.vim",
  --   build = "pipx install jupyter_ascending",
  --   init = function()
  --     vim.g.jupyter_ascending_default_mappings = false
  --   end,
  -- },
  {
    "goerz/jupytext.vim",
    build = "pipx install jupytext",
    lazy = false, -- TODO: lazy load?
    -- event = { "BufReadCmd *.ipynb" },
    init = function()
      vim.g.jupytext_fmt = "md:markdown"
      vim.g.jupytext_fmt = "py:percent"
    end,
  },

  -- require("langs").mason_ensure_installed { "python-lsp-server", "python-lsp-mypy", "python-lsp-black" },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff_lsp = {},
        pylsp = {
          mason = false,
          before_init = function(_, config)
            local python_path = get_python_path(config.root_dir)
            config.settings.python.pythonPath = python_path
            config.settings.pylsp.plugins.pylsp_mypy.overrides = { "--python-executable", python_path }
            vim.g.python_host_prog = python_path
            vim.g.python3_host_prog = python_path
          end,
          settings = {
            pylsp = {
              plugins = {
                -- formatter options
                black = { enabled = true },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                -- linter options
                pylint = { enabled = false, executable = "pylint" },
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
                -- type checker
                pylsp_mypy = { enabled = true },
                -- auto-completion options
                jedi_completion = { fuzzy = true },
                -- import sorting
                pyls_isort = { enabled = false },
              },
            },
          },
        },
        -- pyright = {
        --   handlers = {
        --     ["textDocument/publishDiagnostics"] = function() end,
        --   },
        --   on_attach = function(client, _) client.server_capabilities.codeActionProvider = false end,
        --   settings = {
        --     pyright = {
        --       disableOrganizeImports = true,
        --     },
        --     python = {
        --       analysis = {
        --         autoSearchPaths = true,
        --         typeCheckingMode = "basic",
        --         useLibraryCodeForTypes = true,
        --       },
        --     },
        --   },
        -- },
        -- ["ruff_lsp"] = {
        --   on_attach = function(client, _) client.server_capabilities.hoverProvider = false end,
        --   init_options = {
        --     settings = {
        --       args = {},
        --     },
        --   },
        -- },
      },
    },
    init = function()
      local function mason_package_path(package)
        local path = vim.fn.resolve(vim.fn.stdpath "data" .. "/mason/packages/" .. package)
        return path
      end
      -- TODO: on install hook??
      vim.api.nvim_create_user_command("PyLsp", function()
        -- depends on package manager / language
        local command = "./venv/bin/pip"
        local args = {
          "install",
          "pylsp-rope",
          "python-lsp-ruff",
          "pyls-isort",
          "python-lsp-black",
          "pylsp-mypy",
        }

        require("plenary.job")
          :new({
            command = command,
            args = args,
            cwd = mason_package_path "python-lsp-server",
          })
          :start()
      end, {})
    end,
  },

  -- https://github.com/roobert/f-string-toggle.nvim
}

local get_alt_win = function(term, cmd)
  -- TODO: get existing alternate window automatically
  if not term then
    require("kitty.terms").new_terminal("window", {
      launch_cmd = cmd,
      bracketed_paste = true,
      send_text_prefix = "\\cc",
      send_text_suffix = require("kitty.utils").unkeycode "<c-cr>",
    })
  else
    term:send(table.concat(cmd, " "))
  end
end

local function get_jupyter_kernel(bufnr)
  return (vim.fn.stdpath "cache") .. "/" .. vim.fn.fnamemodify(vim.v.servername, ":t") .. bufnr .. ".json"
end

local function get_euporie_cmd(bufnr, cmd)
  local kern = get_jupyter_kernel(bufnr)
  local M = { cmd = {
    "euporie",
    cmd,
    "--connection-file",
    kern,
  }, kern = kern }
  if cmd == "notebook" then M.cmd[#M.cmd + 1] = vim.api.nvim_buf_get_name(bufnr) end
  return M
end

local function start_euporie(bufnr, term, type)
  local eu = get_euporie_cmd(bufnr, type)
  eu.term = get_alt_win(term, eu.cmd)
  vim.b[bufnr].euporie_console = eu
  -- TODO: better scheduling
  -- vim.defer_fn(function() vim.cmd.JupyterAttach(eu.kern) end, 2000)

  vim.api.nvim_create_user_command("EuporieAttach", function() vim.cmd.JupyterAttach(eu.kern) end, {})

  return eu
end

M.euporie_notebook = function(term)
  local bufnr = vim.api.nvim_get_current_buf()
  local eu = start_euporie(bufnr, term, "notebook")

  Au.grp("euporie_term-" .. bufnr, function(au)
    au("BufWritePost", {
      buffer = bufnr,
      callback = function()
        -- Reload the euporie notebook view
        term:send ""
      end,
    })
  end)
end

M.euporie_console = function(term)
  local bufnr = vim.api.nvim_get_current_buf()
  start_euporie(bufnr, term, "console")
end

vim.api.nvim_create_user_command("EuporieConsole", function() M.euporie_console() end, {})
vim.api.nvim_create_user_command("EuporieNotebook", function() M.euporie_notebook() end, {})

return M
