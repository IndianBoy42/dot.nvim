local Pkg = require "mason-core.package"
local _ = require "mason-core.functional"
local pip3 = require "mason-core.managers.pip3"

return Pkg.new {
  name = "python-lsp-mypy",
  desc = "Mypy plugin for pylsp",
  homepage = "https://github.com/python-lsp/pylsp-mypy",
  categories = { Pkg.Cat.LSP },
  languages = { Pkg.Lang.Python },
  install = pip3.packages { "pylsp-mypy", bin = {} },
}
