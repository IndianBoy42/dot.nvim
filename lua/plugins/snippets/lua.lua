-- some shorthands...
local ls = require "luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local l = require("luasnip.extras").lambda
local r = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local pa = ls.parser.parse_snippet
local types = require "luasnip.util.types"
local nl = t { "", "" }
local function nlt(line)
  return t { "", line }
end
local function tnl(line)
  return t { line, "" }
end

return {
  s("localM", {
    tnl [[local M = {}]],
    t "M.",
    i(0),
    nlt [[return M]],
  }),
  s("link_url", {
    t '<a href="',
    selected_text(),
    t '">',
    i(1),
    t "</a>",
  }),
  s("function", {
    t "function ",
    i(1),
    t "(",
    i(2),
    t { ")", "" },
    selected_text(),
    -- t { "", "" },
    i(0),
    t { "", "end" },
    -- r(1),
    -- t "(",
    -- r(2),
    -- t { ")", "" },
  }),
  s("function", {
    t "if ",
    i(1),
    t { "then", "" },
    selected_text(),
    -- t { "", "" },
    i(0),
    t { "", "end" },
    -- r(1),
    -- t "(",
    -- r(2),
    -- t { ")", "" },
  }),
  s("iife", {
    t { "(function ()", "return" },
    selected_text(),
    -- t { "", "" },
    i(0),
    t { "", "end)()" },
    -- r(1),
    -- t "(",
    -- r(2),
    -- t { ")", "" },
  }),
}
