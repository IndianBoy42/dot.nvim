local function switch_source_header_splitcmd(bufnr, splitcmd)
  local lspconfig = require "lspconfig"
  local lsputil = lspconfig.util

  bufnr = lsputil.validate_bufnr(bufnr)
  local params = { uri = vim.uri_from_bufnr(bufnr) }
  vim.lsp.buf_request(
    bufnr,
    "textDocument/switchSourceHeader",
    params,
    lsputil.compat_handler(function(err, result)
      if err then error(tostring(err)) end
      if not result then
        print "Corresponding file can’t be determined"
        return
      end
      vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
    end)
  )
end

local clangd_cmd =
  -- TODO: can we automate the query drivers finding? Use env variables
  {
    "clangd",
    "--background-index",
    "--query-driver=**/arm-none-eabi-*,**/x86_64-linux-*",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  }
-- table.insert(clangd_flags, "--cross-file-rename")
-- table.insert(clangd_flags, "--header-insertion=never")

return {
  -- correctly setup lspconfig
  require("langs").mason_ensure_installed { "gersemi" },
  {
    -- TODO: hhttps://github.com/LazyVim/LazyVim/blob/f086bcde253c29be9a2b9c90b413a516f5d5a3b2/lua/lazyvim/plugins/extras/lang/clangd.lua#L89
    "neovim/nvim-lspconfig",
    dependencies = {
      "https://git.sr.ht/~p00f/clangd_extensions.nvim",
    },
    opts = {
      -- make sure mason installs the server
      servers = {
        clangd = {
          -- cmd = require("lsp.config").get_cmd "clangd",
          -- cmd_env = require("lsp.config").get_cmd_env "clangd",
          cmd = clangd_cmd,
          commands = {
            -- -- TODO: use winpick
            -- ClangdSwitchSourceHeader = {
            --     function() switch_source_header_splitcmd(0, "edit") end,
            --     description = "Open source/header in current buffer",
            -- },
            -- ClangdSwitchSourceHeaderVSplit = {
            --     function() switch_source_header_splitcmd(0, "vsplit") end,
            --     description = "Open source/header in a new vsplit",
            -- },
            -- ClangdSwitchSourceHeaderSplit = {
            --     function() switch_source_header_splitcmd(0, "split") end,
            --     description = "Open source/header in a new split",
            -- },
          },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "Makefile",
              "configure.ac",
              "configure.in",
              "config.h.in",
              "meson.build",
              "meson_options.txt",
              "build.ninja"
            )(fname) or require("lspconfig.util").root_pattern(
              "compile_commands.json",
              "compile_flags.txt"
            )(fname) or require("lspconfig.util").find_git_ancestor(fname)
          end,

          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
          -- handlers = lsp_status.extensions.clangd.setup(),
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
        },
      },
      setup = {
        clangd = function(_, opts)
          utils.lsp.on_attach(function()
            local map = vim.keymap.setl
            map("n", "<localleader><tab>", "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "c/h" })
            map(
              "n",
              "<localleader>s",
              "<cmd>ClangdSwitchSourceHeaderVSplit<cr>",
              { desc = "c/h split" }
            )
          end)
          require("clangd_extensions").setup {
            server = opts,
            extensions = {
              autoSetHints = false,
              inlay_hints = false,
              ast = {
                --These require codicons (https://github.com/microsoft/vscode-codicons)
                role_icons = {
                  type = "",
                  declaration = "",
                  expression = "",
                  specifier = "",
                  statement = "",
                  ["template argument"] = "",
                },

                kind_icons = {
                  Compound = "",
                  Recovery = "",
                  TranslationUnit = "",
                  PackExpansion = "",
                  TemplateTypeParm = "",
                  TemplateTemplateParm = "",
                  TemplateParamObject = "",
                },
              },
            },
          }
          return false
        end,
      },
    },
  },
  -- TODO: https://github.com/Badhi/nvim-treesitter-cpp-tools
}
