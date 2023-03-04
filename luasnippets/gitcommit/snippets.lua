local function make(trig, name)
  return s(
    trig,
    fmt("{} {}\n\n{}", {
      c(1, {
        sn(nil, fmt("{}({}):", { t(name), i(1, "scope") })),
        t(name .. ":"),
      }),
      i(2, "title"),
      i(0),
    })
  )
end

local snippets = {
  make("ref", "ref"),
  make("rev", "revert"),
  make("add", "add"),
  make("break", "breaking"),
  make("fix", "fix"),
  make("refac", "refactor"),
  make("chore", "chore"),
  make("docs", "docs"),
  make("chore", "chore"),
  make("chore", "chore"),
  make("ci", "ci"),
}
local autosnippets = {}

return snippets, autosnippets
