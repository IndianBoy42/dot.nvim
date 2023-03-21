local hops = function(n)
  return function()
    -- Proxies into require'hop' for me
    require("hop-extensions")[n]()
  end
end
return {
  -- {["/"] , prefix .. "hint_patterns({}, vim.fn.getreg('/'))<cr>", "Last Search" },
  -- {"g" , exts"hint_localsgd", "Go to Definition of" },
  { "/", "<cmd>HopPattern<cr>", "Search" },
  {
    "?",
    function()
      require("hop-extensions").hint_patterns({}, vim.fn.getreg "/")
    end,
    "Last Search",
  },
  -- { "w", exts "hint_words", "Words" },
  { "L", hops "hint_lines_skip_whitespace", "Lines" },
  { "l", hops "hint_vertical", "Lines Column" },
  {
    "w",
    -- exts "hint_cword",
    function()
      -- TODO: escape?
      require("hop-extensions").hint_patterns({}, vim.fn.expand "<cword>")
    end,
    "cword",
  },
  {
    "W",
    function()
      -- TODO: escape?
      require("hop-extensions").hint_patterns({}, vim.fn.expand "<cWORD>")
    end,
    "cWORD",
  },
  {
    "j",
    function()
      require("tsht").move { side = "end" }
    end,
    "TS Nodes Containing",
  },
  {
    "k",
    function()
      require("tsht").move { side = "start" }
    end,
    "TS Nodes Containing",
  },
  { "i", hops "hint_all_ts_defnref", "Locals" },
  { "d", hops "hint_lsp_definition", "LSP Definitions" },
  { "r", hops "hint_lsp_references", "LSP References" },
  { "u", hops "hint_ts_usages", "References" },
  { "s", hops "hint_all_ts_scopes", "Scopes" },
  { "S", hops "hint_containing_scopes", "Scopes" },
  { "t", hops "hint_textobjects", "Textobjects" },
  {
    "b",
    function()
      require("hop-extensions.lsp").hint_symbols()
    end,
    "LSP Symbols",
  },
  {
    "g",
    function()
      require("hop-extensions").hint_diagnostics()
    end,
    "LSP Diagnostics",
  },
  {
    "f",
    function()
      require("hop-extensions").hint_textobjects { captures = "@function" }
    end,
    "Functions",
  },
  {
    "a",
    function()
      require("hop-extensions").hint_textobjects { captures = "@parameter" }
      -- require("hop-extensions").hint_from_queryfile "indents"
    end,
    "Parameters",
  },
}
