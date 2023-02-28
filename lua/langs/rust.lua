return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "Saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        opts = {
          null_ls = { enabled = true, name = "crates.nvim" },
        },
      },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require "cmp"
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, {
        { name = "crates" },
      }))
    end,
  },
  -- correctly setup mason lsp / dap extensions
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "codelldb", "rust-analyzer", "taplo" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "simrat39/rust-tools.nvim" },
    opts = {
      setup = {
        rust_analyzer = function(_, opts)
          require("lsp.functions").cb_on_attach(function(client, buffer)
            if client.name ~= "rust_analyzer" then
              return
            end
            mappings.localleader {
              m = { "<Cmd>RustExpandMacro<CR>", "Expand Macro" },
              H = { "<Cmd>RustToggleInlayHints<CR>", "Toggle Inlay Hints" },
              e = { "<Cmd>RustRunnables<CR>", "Runnables" },
              h = { "<Cmd>RustHoverActions<CR>", "Hover Actions" },
              s = { ":RustSSR  ==>> <Left><Left><Left><Left><Left><Left>", "Structural S&R" },
            }
            local map = vim.keymap.setl
            map("x", "gh", "<cmd>RustHoverRange<CR>", { desc = "Hover Range" })
            map("n", "gh", "<cmd>RustHoverActions<CR>", { desc = "Hover Actions" })
            map("n", "gj", "<cmd>RustJoinLines<CR>", { desc = "Join Lines" })
            -- map("n", "K", "<cmd>RustCodeAction<CR>")
            map("n", "K", vim.lsp.buf.code_action, { desc = "Code Actions" })
            map("x", "gK", ":lua vim.lsp.buf.range_code_action()<cr>", { desc = "Code Actions" })
            mappings.ftleader {
              pR = { "<CMD>RustRunnables<CR>", "Rust Run" },
              pd = { "<CMD>RustDebuggables<CR>", "Rust Debug" },
            }
          end)

          local mason_registry = require "mason-registry"
          -- rust tools configuration for debugging support
          local codelldb = mason_registry.get_package "codelldb"
          local extension_path = codelldb:get_install_path() .. "/extension/"
          local codelldb_path = extension_path .. "adapter/codelldb"
          local liblldb_path = vim.fn.has "mac" == 1 and extension_path .. "lldb/lib/liblldb.dylib"
            or extension_path .. "lldb/lib/liblldb.so"

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
          local snippets = {
            ["Arc::new"] = postfix_wrap_call("arc", "Arc::new", "std::sync::Arc"),
            ["Mutex::new"] = postfix_wrap_call("mutex", "Mutex::new", "std::sync::Mutex"),
            ["RefCell::new"] = postfix_wrap_call("refcell", "RefCell::new", "std::cell::RefCell"),
            ["Cell::new"] = postfix_wrap_call("cell", "Cell::new", "std::cell::Cell"),
            ["Rc::new"] = postfix_wrap_call("rc", "Rc::new", "std::rc::Rc"),
            ["Box::pin"] = postfix_wrap_call("pin", "Box::pin"),
            ["unsafe"] = {
              postfix = "unsafe",
              body = { "unsafe { ${receiver} }" },
              description = "Wrap in unsafe{}",
              scope = "expr",
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
              scope = "expr",
            },
            ["channel"] = {
              prefix = "channel",
              body = { "let (tx,rx) = mpsc::channel()" },
              description = "(tx,rx) = channel()",
              requires = "std::sync::mpsc",
              scope = "expr",
            },
            ["from"] = {
              postfix = "from",
              body = {
                "${0:From}::from(${receiver})",
              },
              scope = "expr",
            },
          }

          local rust_tools_opts = vim.tbl_deep_extend("force", opts, {
            dap = {
              adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
            },
            tools = {
              hover_actions = {
                auto_focus = false,
                border = "single",
              },
              inlay_hints = {
                auto = false,
                show_parameter_hints = true,
              },
              runnables = {
                use_telescope = true,
                layout_config = {
                  width = 0.4,
                  height = 0.4,
                },
              },
              debuggables = {
                use_telescope = true,
                layout_config = {
                  width = 0.4,
                  height = 0.4,
                },
              },
            },
            server = {
              settings = {
                ["rust-analyzer"] = {
                  cargo = {
                    features = "all",
                  },
                  -- Add clippy lints for Rust.
                  checkOnSave = {
                    enable = true,
                    command = "clippy", -- comment out to not use clippy
                  },
                  check = {
                    command = "clippy",
                    features = "all",
                  },
                  completion = {
                    snippets = snippets,
                  },
                  procMacro = {
                    enable = true,
                  },
                },
              },
            },
          })
          require("rust-tools").setup(rust_tools_opts)
          return true
        end,
        taplo = function(_, opts)
          local function is_cargo()
            return vim.fn.expand "%:t" == "Cargo.toml"
          end
          local function show_documentation()
            if vim.fn.expand "%:t" == "Cargo.toml" and require("crates").popup_available() then
              require("crates").show_popup()
            else
              vim.lsp.buf.hover()
            end
          end

          require("lsp.functions").cb_on_attach(function(client, buffer)
            if client.name == "taplo" then
              vim.keymap.set("n", "gh", show_documentation, { buffer = buffer })
              if is_cargo() then
                local crates = require "crates"
                mappings.localleader {
                  t = { crates.toggle, "Toggle" },
                  r = { crates.reload, "Reload" },
                  u = { crates.update_crate, "Update Crate" },
                  a = { crates.update_all_crates, "Update All" },
                  U = { crates.upgrade_crate, "Upgrade Crate" },
                  A = { crates.upgrade_all_crates, "Upgrade All" },
                  ["<localleader>"] = { crates.show_versions_popup, "Versions" },
                }
                mappings.vlocalleader {
                  u = { crates.update_crates, "Update" },
                  U = { crates.upgrade_crates, "Upgrade" },
                }
              end
            end
          end)
          return false -- make sure the base implementation calls taplo.setup
        end,
      },
    },
  },
}
