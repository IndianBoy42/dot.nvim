local snippets = {
  s("#!", { t { "#!/usr/bin/env -S uv run --script", "" } }),
  s("#uv", { t { "# /// script", "# dependencies = [", "# ]", "# ///", "", "" } }),
}
local autosnippets = {}

return snippets, autosnippets
