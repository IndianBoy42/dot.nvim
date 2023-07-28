local Pkg = require "mason-core.package"
local _ = require "mason-core.functional"
local pip3 = require "mason-core.managers.pip3"

return {
  name = "python-lsp-server",
  description = "python-lsp-server + plugins",
  homepage = "https://github.com/python-lsp/python-lsp-server",
  licenses = {"MIT"},
  categories = {"LSP"},
  languages = {"Python"},
  source = {id = "pkg:pypi/python-lsp-server@1.7.4?extra=all"},
  schemas = {id = "pkg:pypi/python-lsp-server@1.7.4?extra=all"},
  install = pip3.packages { "python-lsp-ruff", bin = {} },
}
