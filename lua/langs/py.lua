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
          srcs(vim.list_extend(srcs(), { name = "jupyter", group_index = 1 }))
          local map = vim.keymap.setl
          map("n", O.hover_key, "<cmd>JupyterInspect<cr>", {})
          map("n", "<localleader>i", "<cmd>JupyterInspect<cr>", {})
          -- map("n", "<localleader>x", "<cmd>JupyterExecute<cr>", {})
          -- map("x", "<localleader>x", ":JupyterExecute<cr>", {})
        end,
        group = vim.api.nvim_create_augroup("jupyter_kernel_setup", {}),
      })
    end,
    cmd = { "JupyterAttach" },
    build = ":UpdateRemotePlugins",
    opts = {},
  },
  {
    "GCBallesteros/NotebookNavigator.nvim",
    dependencies = {
      -- {
      --   "benlubas/molten-nvim",
      --   build = ":UpdateRemotePlugins",
      -- },
    },
    ft = "python",
    config = function()
      local nn = require "notebook-navigator"
      nn.setup {}
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "Python",
        callback = function()
          local map = vim.keymap.setl
          require("keymappings").repeatable("c", "Notebook Cells", {
            function() nn.move_cell "d" end,
            function() nn.move_cell "u" end,
          }, {
            buffer = 0,
            heads = {
              { "x", nn.run_cell, { desc = "Run", nowait = true, private = true } },
              { "X", nn.run_and_move, { desc = "Run & Move", nowait = true, private = true } },
              { "a", nn.add_cell_below, { desc = "Run & Move", nowait = true, private = true } },
              { "i", nn.add_cell_above, { desc = "Run & Move", nowait = true, private = true } },
              { "o", nn.split_cell, { desc = "Run & Move", nowait = true, private = true } },
              { O.commenting.op, nn.comment_cell, { desc = "Run & Move", nowait = true, private = true } },
            },
          })
          for _, v in ipairs {
            { "<localleader>X", function() nn.run_cell() end },
            { "<localleader>x", function() nn.run_and_move() end },
          } do
            map("n", v[1], v[2], v[3])
          end
          vim.b.miniai_config = vim.b.miniai_config or {}
          vim.b.miniai_config.custom_textobjects = vim.b.miniai_config.custom_textobjects or {}
          vim.b.miniai_config.custom_textobjects.C = nn.miniai_spec
        end,
      })
    end,
  },
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

  -- TODO: https://github.com/roobert/f-string-toggle.nvim
  -- TODO: https://github.com/jim-at-jibba/micropython.nvim
}

return M
