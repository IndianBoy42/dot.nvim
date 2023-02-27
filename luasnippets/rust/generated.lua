local ls = require "luasnip"
local s = ls.snippet
local i = ls.insert_node

local snippets = {
  s(
    "my_snippet",
    fmt(
      [=[
Hello {}
]=],
      { i(1, "World") }
    )
  ),

  ------------------------------------------------------ Snippets goes here
}

local autosnippets = {}

return snippets, autosnippets
