local snippets = {
  s("shebang", t { "#!/usr/bin/env fish", "" }),
  s("#!", t { "#!/usr/bin/env fish", "" }),
}
local autosnippets = {}

return snippets, autosnippets
