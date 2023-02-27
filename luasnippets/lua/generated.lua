local snippets = {

  s(
    "lazy_plugin",
    fmt(
      [=[
{{
  "{}",
  {}
  {},
}}
]=],
      {
        i(1, "user/plugin"),
        i(2, 'cmd = "StartupTime",'),
        i(3, { "config = function()", "      vim.g.startuptime_tries = 10", "    end" }),
      }
    )
  ),

  ------------------------------------------------------ Snippets goes here
}

local autosnippets = {}

return snippets, autosnippets
