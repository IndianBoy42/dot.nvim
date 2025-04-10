-- LSP Server to use for Rust.
-- Set to "bacon-ls" to use bacon-ls instead of rust-analyzer.
-- only for diagnostics. The rest of LSP support will still be
-- provided by rust-analyzer.
-- local diagnostics = "rust-analyzer"
local use_diagnostics = "bacon-ls"
local function on_attach()
  local map = vim.keymap.setl
  map("x", O.hover_key, "<cmd>RustLsp hover range<CR>", { desc = "Hover Range" })
  map("n", O.hover_key, "<cmd>RustLsp hover actions<CR>", { desc = "Hover Actions" })
  map("n", "gj", "<cmd>RustLsp joinlines<CR>", { desc = "Join Lines" })
  map("n", "<leader>de", "<cmd>RustLsp explainError cycle<CR>", { desc = "Explain" })

  local move_item = function(dir)
    return function() vim.cmd.RustLsp { "moveItem", dir } end
  end
  local move_mode = require "hydra" {
    name = "Move Item",
    config = { color = "pink" },
    mode = { "n" },
    body = "<localleader>",
    heads = {
      { "l", move_item "down", { desc = "Move Item Down" } },
      { "h", move_item "up", { desc = "Move Item Up" } },
      { "<ESC>", nil, { exit = true, nowait = true, desc = "exit" } },
    },
  }
  -- map("n", "gmj", function()
  --   move_item "j"()
  --   -- move_mode:activate()
  -- end, { desc = "Move Item Down" })
  -- map("n", "gmk", function()
  --   move_item "k"()
  --   -- move_mode:activate()
  -- end, { desc = "Move Item Up" })

  local function code_action(kind, sub, opts)
    opts = opts or {}
    opts.context = opts.context or {}
    opts.context.only = { kind }
    opts.apply = true
    if sub then opts.filter = function(c) return c.title:sub(-#sub) == sub end end
    return function() vim.lsp.buf.code_action(opts) end
  end

  -- map("n", "KK", require("rust-tools").code_action_group.code_action_group, { desc = "Code Actions" })
  map = vim.keymap.localleader
  map("n", "m", "<CMD>RustLsp debuggables<CR>", { desc = "Expand Macro" })
  -- TODO: Integrate with Kitty.lua
  map("n", "R", "<CMD>RustLsp runnables<CR>", { desc = "Runnables" })
  map("n", "i", code_action "refactor.inline", { desc = "Inline" })
  map("n", "r", code_action "refactor.rewrite", { desc = "Rewrite" })
  map("n", "D", "<Cmd>RustLsp debuggables<CR>", { desc = "Debuggables" })
  map("n", "d", "<Cmd>RustLsp relatedDiagnostics<CR>", { desc = "Related" })
  map("n", "o", "<Cmd>RustLsp openDocs<CR>", { desc = "Open Docs.rs" })
  map("n", "s", ":RustLsp ssr  ==>> <Left><Left><Left><Left><Left><Left>", { desc = "Structural S&R" })
  map("x", "h", "<cmd>RustLsp hover range", { desc = "LSP Hover" })
  map("x", "ef", code_action("refactor.extract", "function"), { desc = "Extract function" })
  map("x", "ev", code_action("refactor.extract", "variable"), { desc = "Extract variable" })
  -- TODO: the rest of these actions
  vim.keymap.leader("n", "pR", "<Cmd>RustLsp runnables<CR>", { buffer = 0, desc = "Rust Run" })
  vim.keymap.leader("n", "pd", "<Cmd>RustLsp expandMacro<CR>", { buffer = 0, desc = "Rust Debug" })
end
local function postfix_wrap_call(trig, call, requires)
  return {
    postfix = trig,
    body = {
      call .. "(${receiver})",
    },
    requires = requires,
    scope = "expr",
  }
end
local function postfix_wrap_type(trig, call, requires)
  return {
    postfix = trig,
    body = {
      call .. "<${receiver}>",
    },
    requires = requires,
    scope = "type",
  }
end
local snippets = {
  ["Extend::extend"] = postfix_wrap_call("extend", "_.extend"),
  ["Arc::new"] = postfix_wrap_call("arc", "Arc::new", "std::sync::Arc"),
  ["Mutex::new"] = postfix_wrap_call("mutex", "Mutex::new", "std::sync::Mutex"),
  ["RefCell::new"] = postfix_wrap_call("refcell", "RefCell::new", "std::cell::RefCell"),
  ["Cell::new"] = postfix_wrap_call("cell", "Cell::new", "std::cell::Cell"),
  ["Rc::new"] = postfix_wrap_call("rc", "Rc::new", "std::rc::Rc"),
  ["Box::pin"] = postfix_wrap_call("pin", "Box::pin"),
  ["Some"] = postfix_wrap_call("some", "Some", nil),
  ["Ok"] = postfix_wrap_call("ok", "Ok", nil),
  ["Err"] = postfix_wrap_call("err", "Err", nil),
  ["Option"] = postfix_wrap_type("option_type", "Option", nil),
  ["RefCell"] = postfix_wrap_type("refcell_type", "RefCell", nil),
  ["Rc"] = postfix_wrap_type("rc_type", "Rc", nil),
  ["Box"] = postfix_wrap_type("box_type", "Box", nil),
  ["unsafe"] = {
    postfix = "unsafe",
    body = { "unsafe { ${receiver} }" },
    description = "Wrap in unsafe{}",
    scope = "expr",
  },
  ["for"] = {
    postfix = "for",
    body = { [[for ${1:i} in ${receiver} {
              $0
              }]] },
    description = "Wrap in for _ in _ {}",
    scope = "expr",
  },
  ["if"] = {
    postfix = "if",
    body = { [[if ${receiver} {
              $0
              }]] },
    scope = "expre",
    description = "Wrap in if _ {}",
  },
  ["thread::spawn"] = {
    prefix = "spawn",
    body = {
      "thread::spawn(move || {",
      "\t$0",
      "});",
    },
    description = "Spawn a new thread",
    requires = "std::thread",
  },
  ["channel"] = {
    prefix = "channel",
    body = { "let (tx,rx) = mpsc::channel()" },
    description = "(tx,rx) = channel()",
    requires = "std::sync::mpsc",
  },
  ["from"] = {
    postfix = "from",
    body = {
      "${0:From}::from(${receiver})",
    },
    scope = "expr",
  },
}

return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "Saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        opts = {
          null_ls = { enabled = true, name = "crates.nvim" },
          completion = { cmp = { enabled = true } },
          popup = {
            border = "rounded",
          },
        },
      },
    },
  },
  -- correctly setup mason lsp / dap extensions

  require("langs").mason_ensure_installed { "codelldb", "rust-analyzer", "taplo", "bacon", "bacon-ls" },

  -- TODO: rustaceanvim
  -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/rust.lua
  -- https://github.com/mrcjkb/rustaceanvim/discussions/122
  {
    "mrcjkb/rustaceanvim",
    ft = { "rust" },
    opts = {
      tools = {
        float_win_config = {
          border = "rounded",
        },
      },
      server = {
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            cargo = {
              targetDir = "target/analyzer",
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            -- Add clippy lints for Rust if using rust-analyzer
            checkOnSave = use_diagnostics == "rust-analyzer",
            -- Enable diagnostics if using rust-analyzer
            diagnostics = {
              -- enable = use_diagnostics == "rust-analyzer",
              experimental = {
                enable = true,
              },
            },
            completion = {
              snippets = snippets,
              postfix = { enable = true },
              fullFunctionSignatures = { enable = true },
              termSearch = { enable = true },
            },
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
            hover = {
              actions = {
                references = { enable = true },
              },
            },
            -- imports = {},
            workspace = { symbol = { search = { kind = "all_symbols" } } },
            inlayHints = {
              -- bindingModeHints = { enable = true },
              -- closureCaptureHints = { enable = true },
              -- closureReturnTypeHints = { enable = true },
              -- discriminantHints = { enable = true },
              -- expressionAdjustmentHints = { enable = true },
              -- lifetimeElisionHints = { enable = true },
            },
            rustfmt = {
              rangeFormatting = { enable = true },
            },
            typing = {
              autoClosingAngleBrackets = { enable = true },
            },
            files = {
              excludeDirs = {
                ".direnv",
                ".git",
                ".github",
                ".gitlab",
                "bin",
                "node_modules",
                "target",
                "venv",
                ".venv",
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      if utils.have_plugin "mason.nvim" then
        local package_path = require("mason-registry").get_package("codelldb"):get_install_path()
        local codelldb = package_path .. "/extension/adapter/codelldb"
        local library_path = package_path .. "/extension/lldb/lib/liblldb.dylib"
        local uname = io.popen("uname"):read "*l"
        if uname == "Linux" then library_path = package_path .. "/extension/lldb/lib/liblldb.so" end
        opts.dap = {
          adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path),
        }
      end
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
      utils.lsp.on_attach(on_attach)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        taplo = function(_, opts)
          local function is_cargo() return vim.fn.expand "%:t" == "Cargo.toml" end
          local function show_popup()
            if is_cargo() and require("crates").popup_available() then
              require("langs.complete").sources {
                sources = {
                  { name = "vimtex" },
                },
              }
              require("crates").show_popup()
            else
              vim.lsp.buf.hover()
            end
          end

          local taplo_on_attach = function(client, buffer)
            if is_cargo() then
              vim.keymap.set("n", O.hover_key, show_popup, { buffer = buffer })
              local crates = require "crates"
              local map = vim.keymap.localleader
              map("n", "t", crates.toggle, { desc = "Toggle" })
              map("n", "r", crates.reload, { desc = "Reload" })
              map("n", "u", crates.update_crate, { desc = "Update Crate" })
              map("n", "a", crates.update_all_crates, { desc = "Update All" })
              map("n", "U", crates.upgrade_crate, { desc = "Upgrade Crate" })
              map("n", "A", crates.upgrade_all_crates, { desc = "Upgrade All" })
              map("n", "d", crates.open_documentation, { desc = "Docs" })
              map("n", "<localleader>", crates.show_versions_popup, { desc = "Versions" })
              map("x", "u", crates.update_crates, { desc = "Update" })
              map("x", "U", crates.upgrade_crates, { desc = "Upgrade" })
            end
          end
          -- require("utils.lsp").on_attach(taplo_on_attach)
          opts.on_attach = taplo_on_attach
          -- utils.dump("taplo", opts)
          return false -- make sure the base implementation calls taplo.setup
        end,
        rust_analyzer = function(_, opts) return true end,
      },
      servers = {
        bacon_ls = {
          enabled = use_diagnostics == "bacon-ls",
        },
      },
    },
  },
}
