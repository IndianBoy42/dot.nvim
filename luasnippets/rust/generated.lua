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
