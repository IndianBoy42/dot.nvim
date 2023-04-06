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
        },
      },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      opts.sources = vim.list_extend(opts.sources, {
        { name = "crates", group_index = 1 },
      })
    end,
  },
  -- correctly setup mason lsp / dap extensions

  require("langs").mason_ensure_installed { "codelldb", "rust-analyzer", "taplo" },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "simrat39/rust-tools.nvim" },
    opts = {
      setup = {
        rust_analyzer = function(_, opts)
          local mason_registry = require "mason-registry"
          -- rust tools configuration for debugging support
          local codelldb = mason_registry.get_package "codelldb"
          local extension_path = codelldb:get_install_path() .. "/extension/"
          local codelldb_path = extension_path .. "adapter/codelldb"
          local liblldb_path = vim.fn.has "mac" == 1 and extension_path .. "lldb/lib/liblldb.dylib"
            or extension_path .. "lldb/lib/liblldb.so"

          -- TODO:
          -- vim.b.miniai_config = {
          --     custom_textobjects =
          -- }

          local inlay_hints_enabled = true
          local rust_tools_executor = nil
          local inlay_hints = vim.tbl_extend("keep", {
            auto = inlay_hints_enabled,
          }, require("langs").inlay_hint_opts)

          local rust_tools_opts = vim.tbl_deep_extend("force", opts, {
            dap = {
              adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
            },
            tools = {
              hover_actions = {
                auto_focus = true,
                border = "rounded",
              },
              inlay_hints = inlay_hints,
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
              on_attach = function()
                local rt = require "rust-tools"
                require("utils.lsp").live_codelens()

                local dap = require "dap"
                dap.listeners.after.event_initialized.rust_tools = function()
                  require("rust-tools").inlay_hints.disable()
                end
                dap.listeners.before.event_terminated.rust_tools = function() require("rust-tools").inlay_hints.enable() end
                dap.listeners.before.event_exited.rust_tools = function() require("rust-tools").inlay_hints.enable() end

                mappings.localleader {
                  m = { "<Cmd>RustExpandMacro<CR>", "Expand Macro" },
                  i = {
                    function()
                      if inlay_hints_enabled then
                        rt.inlay_hints.disable()
                      else
                        rt.inlay_hints.enable()
                      end
                    end,
                    "Toggle Inlay Hints",
                  },
                  -- TODO: Integrate with Kitty.lua
                  e = { "<Cmd>RustRunnables<CR>", "Runnables" },
                  d = { "<Cmd>RustDebuggables<CR>", "Debuggables" },
                  h = { "<Cmd>RustHoverActions<CR>", "Hover Actions" },
                  a = { require("rust-tools").code_action_group.code_action_group, "Code Actions" },
                  s = { ":RustSSR  ==>> <Left><Left><Left><Left><Left><Left>", "Structural S&R" },
                }
                local map = vim.keymap.setl
                map("x", "gh", "<cmd>RustHoverRange<CR>", { desc = "Hover Range" })
                map("n", "gh", "<cmd>RustHoverActions<CR>", { desc = "Hover Actions" })
                map("n", "gj", "<cmd>RustJoinLines<CR>", { desc = "Join Lines" })

                local move_item = function(dir)
                  return function()
                    rt.move_item.move_item(dir == "k")
                    vim.cmd("normal! " .. dir)
                  end
                end
                local move_mode = require "hydra" {
                  name = "Move Item",
                  hint = false,
                  config = { color = "pink" },
                  mode = { "n" },
                  heads = {
                    {
                      "j",
                      move_item "j",
                      { desc = "Move Item Down" },
                    },
                    {
                      "k",
                      move_item "k",
                      { desc = "Move Item Up" },
                    },
                    { "q", nil, { exit = true, nowait = true, desc = "exit" } },
                    { "<ESC>", nil, { exit = true, nowait = true, desc = "exit" } },
                  },
                }
                map("n", "gmj", function()
                  move_item "j"()
                  -- move_mode:activate()
                end, { desc = "Move Item Down" })
                map("n", "gmk", function()
                  move_item "k"()
                  -- move_mode:activate()
                end, { desc = "Move Item Up" })

                -- map("n", "KK", require("rust-tools").code_action_group.code_action_group, { desc = "Code Actions" })
                mappings.vlocalleader {
                  h = { "<cmd>RustHoverRange<CR>", "Hover Range" },
                }
                mappings.ftleader {
                  pR = { "<CMD>RustRunnables<CR>", "Rust Run" },
                  pd = { "<CMD>RustDebuggables<CR>", "Rust Debug" },
                }
              end,
              settings = {
                ["rust-analyzer"] = {
                  -- https://rust-analyzer.github.io/manual.html#configuration
                  cargo = {
                    features = "all",
                  },
                  -- Add clippy lints for Rust.
                  checkOnSave = true,
                  check = {
                    enable = true,
                    command = "clippy",
                    features = "all",
                  },
                  completion = {
                    snippets = snippets,
                    postfix = { enable = true },
                  },
                  procMacro = {
                    enable = true,
                  },
                  diagnostics = {
                    experimental = {
                      enable = false,
                    },
                  },
                  hover = {
                    actions = {
                      references = { enable = true },
                    },
                  },
                  workspace = { symbol = { search = { kind = "all_symbols" } } },
                  -- inlayHints = {
                  --   expressionAdjustmentHints = { enable = true },
                  -- },
                  rustfmt = {
                    rangeFormatting = { enable = true },
                  },
                  typing = {
                    autoClosingAngleBrackets = { enable = true },
                  },
                },
              },
            },
          })
          require("rust-tools").setup(rust_tools_opts)
          return true
        end,
        taplo = function(_, opts)
          local function is_cargo() return vim.fn.expand "%:t" == "Cargo.toml" end
          local function show_popup()
            if vim.fn.expand "%:t" == "Cargo.toml" and require("crates").popup_available() then
              require("crates").show_popup()
            else
              vim.lsp.buf.hover()
            end
          end

          local taplo_on_attach = function(client, buffer)
            if is_cargo() then
              vim.keymap.set("n", "gh", show_popup, { buffer = buffer })
              local crates = require "crates"
              mappings.localleader {
                t = { crates.toggle, "Toggle" },
                r = { crates.reload, "Reload" },
                u = { crates.update_crate, "Update Crate" },
                a = { crates.update_all_crates, "Update All" },
                U = { crates.upgrade_crate, "Upgrade Crate" },
                A = { crates.upgrade_all_crates, "Upgrade All" },
                d = { crates.open_documentation, "Docs" },
                ["<localleader>"] = { crates.show_versions_popup, "Versions" },
              }
              mappings.vlocalleader {
                u = { crates.update_crates, "Update" },
                U = { crates.upgrade_crates, "Upgrade" },
              }
            end
          end
          -- require("utils.lsp").cb_on_attach(taplo_on_attach)
          opts.on_attach = taplo_on_attach
          -- utils.dump("taplo", opts)
          return false -- make sure the base implementation calls taplo.setup
        end,
      },
    },
  },
}
