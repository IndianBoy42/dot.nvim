-- https://github.com/L3MON4D3/LuaSnip/blob/4baa7334e17d177841d66dbe71d51000ca55c144/lua/luasnip/config.lua#L22
local preamble = [[
    local snippets = {

    }
    local autosnippets = {

    }

    return snippets, autosnippets
    ]]
local stylua_toml = [[column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "None"
collapse_simple_statement = "Always"
]]

local last_lua_module_section = function(args) --{{{
  local text = args[1][1] or ""
  local split = vim.split(text, ".", { plain = true })

  local options = {}
  for len = 0, #split - 1 do
    local node = t(table.concat(vim.list_slice(split, #split - len, #split), "_"))
    table.insert(options, node)
  end

  return sn(nil, {
    c(1, options),
  })
end
local function node_refs_node(ji)
  return c(ji, {
    fmt([[, {{ {} }}]], {
      i(1, "refs"),
    }),
    t "",
  })
end
local function lambda_node()
  return fmt("l(l._{}{}{})", {
    i(1, "1"), -- TODO: choice nodes with variables?
    i(3, ".do_something"),
    node_refs_node(2),
  })
end
local function dyn_lambda_node(ji)
  return fmt("dl({}, l._{}{}{})", {
    i(1, ji and ji or "jump-index"),
    i(3, "1"),
    i(4, ".do_something"),
    node_refs_node(2),
  })
end
local function fun_node()
  return fmt("{}({}{})", {
    i(1, "f"),
    c(3, {
      i(1, "fn"),
      sn(
        nil,
        fmt(
          [[function(nodes, parent, ...) 
        {} 
        end]],
          { i(1) }
        )
      ),
    }),
    node_refs_node(2),
  })
end
local function dyn_node(ji)
  return fmt("d({}, {}{})", {
    i(1, ji and tostring(ji) or "jump-index"),
    c(3, {
      i(1, "fn"),
      sn(
        nil,
        fmt(
          [[function(nodes, parent, ...) 
           return sn(nil, {{{}}})
        end]],
          { i(1, "snip-node") }
        )
      ),
    }),
    node_refs_node(2),
  })
end
local any_node
local function fmt_node(srch, fmts)
  srch = srch or "{}"
  fmts = fmts or "fmt"

  return fmta(fmts .. [=[([[<>]], {
<>
    }) ]=], {
    i(1),
    d(2, function(args)
      local count = 0
      for _, snip in ipairs(args[1]) do
        local _, c = string.gsub(snip, srch, srch)
        count = c + count
      end
      local res = {}
      for j = 1, count do
        table.insert(res, any_node(j))
        table.insert(res, t { ",", "" })
      end
      return sn(nil, res)
    end, { 1 }),
  })
end
any_node = function(j, k, with_fmt)
  k = tostring(k or j)
  local nodes = {
    sn(nil, fmt("i({})", { i(1, k) })),
    sn(nil, fmt("i({}, '{}')", { i(1, k), i(2) })),
    sn(nil, fmta("c(<>, {<>})", { i(1, k), i(2) })), -- TODO: improve this
    sn(nil, lambda_node()),
    sn(nil, dyn_lambda_node(k)),
    sn(nil, fun_node()),
    sn(nil, dyn_node(k)),
    sn(nil, i(1, "node")),
  }
  if with_fmt then nodes = { fmt_node(), unpack(nodes) } end
  return c(j, nodes)
end
local function snip_node()
  return fmta("sn(<>, <>),", {
    i(1, "nil"),
    -- i(2),
    any_node(2, "", true),
  })
end

local snippets = {
  s("opfunc", fmt("vim.go.operatorfunc = 'v:lua.__{}_opfunc'", i(1, "my"))),
  s("luasnippets_preamble", t(vim.split(preamble, "\n"))),
  s("stylua_toml", t(vim.split(stylua_toml, "\n"))),
  s(
    "snip",
    fmt("s('{}', {})", {
      i(1, "name"),
      any_node(2, "nodes", true),
    })
  ),
  s(
    "postfix",
    fmta([[postfix("<>", <>)]], {
      i(1, "trigger"),
      any_node(2, "nodes", true),
    })
  ),
  s("fmt-node", fmt_node()),
  s("fmta-node", fmt_node("<>", "fmta")),
  s("snip-node", snip_node()),
  s("fun-node", fun_node()),
  s("dyn-node", dyn_node()),
  s("lambda-node", lambda_node()),
  s("dlambda-node", dyn_lambda_node()),
  s("selected_text", t "snip.env.TM_SELECTED_TEXT"),

  s(
    "module",
    fmta(
      [[local <> = {}
local <> = {}
M = setmetatable(<>, <>)
<>.<>
return M]],
      {
        i(1, "M"),
        l("meta_" .. l._1, { 1 }),
        l(l._1, { 1 }),
        -- i(2, "field"),
        l("meta_" .. l._1, { 1 }),
        l(l._1, { 1 }),
        c(2, {
          sn(
            nil,
            fmta([[<> = <>]], {
              i(1, "field"),
              i(2, "value"),
            })
          ),
          sn(
            nil,
            fmta(
              [[<> = function(<>)
        <>
        end]],
              {
                i(1, "setup"),
                i(2, "..."),
                -- c(2, { i(1, "opts"), i(1, "...") }),
                i(3, "return "),
              }
            )
          ),
        }),
      }
    )
    -- {
    -- i(1),
    -- tnl [[local M = {}]],
    -- t "M.",
    -- i(0),
    -- nlt [[return M]],
    -- }
  ),
  s("link_url", {
    t '<a href="',
    sel(),
    t '">',
    i(1),
    t "</a>",
  }),
  -- TODO: make this smarter?
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
  s("funcret", {
    t "function ",
    i(1),
    t "(",
    i(2),
    t { ")", "return " },
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
  s( -- Require Module
    { trig = "req", name = "Require", dscr = "Choices are on the variable name" },
    fmt([[local {} = require("{}")]], {
      d(2, last_lua_module_section, { 1 }),
      i(1),
    })
  ),
  postfix(
    "assign",
    fmta([[<> = <>]], {
      c(1, {
        i(1, "var"),
        sn(
          nil,
          fmta([[local <>]], {
            i(1, "var"),
          })
        ),
        sn(
          nil,
          fmta([[<>.<>]], {
            i(1, "var"),
            i(2, "M"),
          })
        ),
      }),
      l(l.POSTFIX_MATCH),
    })
  ),
  s( -- Ignore stylua {{{
    { trig = "ignore", name = "Ignore Stylua" },
    fmt("-- stylua: ignore {}\n{}", {
      c(1, {
        t "start",
        t "end",
      }),
      i(0),
    })
  ), --}}}
  s(
    "plugin",
    fmta(
      [[{"<>", opts = {
<>
}, cmd = {}, event = {}, keys = {}}]],
      {
        i(1),
        i(2),
      }
    )
  ),
  s(
    "config",
    fmta(
      [[config = function(_, opts) 
require'<>'.setup(opts)
<>
end,]],
      {
        i(1),
        i(2),
      }
    )
  ),
  s(
    "create_cmd",
    fmta([[vim.api.<>("<>", <>, {<>})]], {
      c(1, { i(1, "nvim_create_user_command"), i(1, "nvim_buf_create_user_command") }),
      i(2, "Command"),
      c(4, {
        sn(nil, fmt([[function(args) {} end]], { i(1) })),
        sn(nil, fmt([["{}"]], { i(1) })),
      }),
      c(3, {
        sn(
          nil,
          fmt([[nargs = {}]], {
            c(1, {
              i(1, '"*"'),
              i(1, '"?"'),
              i(1, '"+"'),
              i(1, '"0"'),
              i(1, '"1"'),
            }),
          })
        ),
      }),
    })
  ),
  s(
    "feedkeys_termcodes",
    fmta(
      [[
local feedkeys = vim.api.nvim_feedkeys
local termcodes = vim.api.nvim_replace_termcodes
local function t(k)
  return termcodes(k, true, true, true)
end
   ]],
      {}
    )
  ),
  postfix(
    -- TODO: assign to variable iff no =
    "augroup",
    fmta([[<> vim.api.nvim_create_augroup("<>")]], {
      d(2, function(_, parent)
        local line = parent.env.POSTFIX_MATCH
        if line then
          if line:find "group%s*=%s*$" then return sn(nil, { t "" }) end
          if line:find "local%s+$" then return sn(nil, { t "augroup = " }) end
        end
        -- if line:find "local%s+$" then return sn(nil, { l(l._1, { 1 }) }) end
        return sn(nil, { t "group = " })
      end),
      i(1),
    })
  ),
  s(
    "autocmd",
    fmta(
      [[vim.api.nvim_create_autocmd(<>, {
    group = <>,
    pattern = <>,
    <>
})]],
      {
        c(1, {
          sn(
            nil,
            fmta([["<>"]], {
              i(1, "event"),
            })
          ),
          sn(
            nil,
            fmta([[{"<>"}]], {
              i(1, "events"),
            })
          ),
        }),
        i(2, "group"),
        c(3, {
          sn(
            nil,
            fmta([["<>"]], {
              i(1, "pattern"),
            })
          ),
          sn(
            nil,
            fmta([[{"<>"}]], {
              i(1, "patterns"),
            })
          ),
          t '"*"',
        }),
        c(4, {
          sn(
            nil,
            fmta(
              [[callback = function()
        <>
        end]],
              {
                i(1),
              }
            )
          ),
          sn(
            nil,
            fmta([[command = "<>"]], {
              i(1),
            })
          ),
        }),
      }
    )
  ),
  s("bufnr", t "bufnr = vim.api.nvim_get_current_buf()"),
  s("winnr", t "winnr = vim.api.nvim_get_current_win()"),
  s("tabnr", t "tabnr = vim.api.nvim_get_current_tab()"),
  postfix({ trig = "++", desc = "increment" }, fmt("{} = {} + 1", { l(l.POSTFIX_MATCH, {}), l(l.POSTFIX_MATCH, {}) })),
  postfix({ trig = "--", desc = "increment" }, fmt("{} = {} - 1", { l(l.POSTFIX_MATCH, {}), l(l.POSTFIX_MATCH, {}) })),
}
local autosnippets = {
  s("!=", t "~="),
}

return snippets, autosnippets
