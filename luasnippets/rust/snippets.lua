local snippets = {
  s("ssr", {
    d(1, function(args, snip)
      local res, env = {}, snip.env
      local selected = env.TM_SELECT_TEXT
      if selected == nil or selected == "" or selected == {} then
        res = vim.split(vim.fn.getreg '"', "\n")
      else
        if type(selected) == "string" then selected = { selected } end
        for _, ele in ipairs(selected) do
          table.insert(res, ele)
        end
      end
      return sn(nil, { i(1, res) })
    end, {}),
    t " ==>> ",
    -- TODO: Could find identifiers or something?
    d(2, function(args)
      -- the returned snippetNode doesn't need a position; it's inserted
      -- "inside" the dynamicNode.
      return sn(nil, {
        -- jump-indices are local to each snippetNode, so restart at 1.
        i(1, args[1]),
      })
    end, { 1 }),
  }),
}
local autosnippets = {}

return snippets, autosnippets
