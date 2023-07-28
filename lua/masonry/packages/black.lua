local Pkg = require "mason-core.package"
local _ = require "mason-core.functional"
local pip3 = require "mason-core.managers.pip3"

return Pkg.new {
  name = "python-lsp-black",
  desc = "Black plugin for pylsp",
  homepage = "https://github.com/python-lsp/python-lsp-black",
  categories = { Pkg.Cat.LSP },
  languages = { Pkg.Lang.Python },
  install = pip3.packages { "python-lsp-black", bin = {} },
}
