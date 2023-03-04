-- Returns a snippet_node wrapped around an insert_node whose initial
-- text value is set to the current date in the desired format.
local function date_input(args, state, fmt)
  fmt = fmt or "%Y-%m-%d"
  return sn(nil, i(1, os.date(fmt)))
end

local shell = function(command) --{{{
  local file = io.popen(command, "r")
  local res = {}
  for line in file:lines() do
    table.insert(res, line)
  end
  return res
end
local snippets = {
  s("time", p(vim.fn.strftime, "%H:%M:%S")),
  s("date", p(vim.fn.strftime, "%Y-%m-%d")),
  s("pwd", { p(shell, "pwd") }),
}

local autosnippets = {}

return snippets, autosnippets
