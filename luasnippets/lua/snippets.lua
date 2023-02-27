local autosnippets = {}
local snippets = {
    s(
        "luasnippets_preamble",
        t [[
    local snippets = {

    }
    local autosnippets = {

    }

    return snippets, autosnippets
    ]]
    ),
    s("localM", {
        tnl [[local M = {}]],
        t "M.",
        i(0),
        nlt [[return M]],
    }),
    s("link_url", {
        t '<a href="',
        sel(),
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
        sel(),
        -- t { "", "" },
        i(0),
        t { "", "end" },
        -- r(1),
        -- t "(",
        -- r(2),
        -- t { ")", "" },
    }),
    s("if", {
        t "if ",
        i(1),
        t { "then", "" },
        sel(),
        -- t { "", "" },
        i(0),
        -- TODO: choice node here
        t { "", "end" },
        -- r(1),
        -- t "(",
        -- r(2),
        -- t { ")", "" },
    }),
    s("iife", {
        t { "(function ()", "return" },
        sel(),
        -- t { "", "" },
        i(0),
        t { "", "end)()" },
        -- r(1),
        -- t "(",
        -- r(2),
        -- t { ")", "" },
    }),
}

return snippets, autosnippets
