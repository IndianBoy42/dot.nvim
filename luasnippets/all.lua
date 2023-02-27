-- Returns a snippet_node wrapped around an insert_node whose initial
-- text value is set to the current date in the desired format.
local function date_input(args, state, fmt)
  fmt = fmt or "%Y-%m-%d"
  return sn(nil, i(1, os.date(fmt)))
end

local snippets = {
  s("date", { d(1, date_input, {}, "%A, %B %d of %Y") }),
}

local autosnippets = {}

return snippets, autosnippets
