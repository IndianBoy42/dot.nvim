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

local clangd_flags =
  { "--background-index", "--query-driver=**/arm-none-eabi-*,**/x86_64-linux-*", "--cross-file-rename" }
-- table.insert(clangd_flags, "--cross-file-rename")
-- table.insert(clangd_flags, "--header-insertion=never")

return {
  -- correctly setup lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "p00f/clangd_extensions.nvim",
    },
    opts = {
      -- make sure mason installs the server
      servers = {
        clangd = {
          -- cmd = require("lsp.config").get_cmd "clangd",
          -- cmd_env = require("lsp.config").get_cmd_env "clangd",

          extra_cmd_args = clangd_flags,
          commands = {
            ClangdSwitchSourceHeader = {
              function() switch_source_header_splitcmd(0, "edit") end,
              description = "Open source/header in current buffer",
            },
            ClangdSwitchSourceHeaderVSplit = {
              function() switch_source_header_splitcmd(0, "vsplit") end,
              description = "Open source/header in a new vsplit",
            },
            ClangdSwitchSourceHeaderSplit = {
              function() switch_source_header_splitcmd(0, "split") end,
              description = "Open source/header in a new split",
            },
          },

          init_options = { clangdFileStatus = true },
          -- handlers = lsp_status.extensions.clangd.setup(),
          capabilities = (function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.offsetEncoding = { "utf-16" }
            return capabilities
          end)(),
        },
      },
      setup = {
        clangd = function(_, opts)
          local inlay_hints = require("langs").inlay_hints
          local inlay_hints_enabled = inlay_hints.auto and inlay_hints.by_tools
          require("clangd_extensions").setup {
            server = opts,
            extensions = {
              autoSetHints = inlay_hints_enabled,
              inlay_hints = inlay_hints_enabled and inlay_hints or false,
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
          return true
        end,
      },
    },
  },
  -- https://github.com/Civitasv/cmake-tools.nvim
}
