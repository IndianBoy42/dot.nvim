local stylua_toml = [[column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "None"
collapse_simple_statement = "Always"
]]

return {
  s("stylua_toml", t(vim.split(stylua_toml, "\n"))),
}, {}