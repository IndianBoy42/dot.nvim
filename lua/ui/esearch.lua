return {
  "eugen0329/vim-esearch",
  keys = {
    { "<leader>re", desc = "Esearch", "<Plug>(esearch)" },
    { "<leader>R", desc = "Esearch (op)", "<Plug>(operator-esearch-prefill)", mode = { "n", "x" } },
    { "<C-e>", desc = "Esearch", "<cr><Plug>(esearch)", mode = "c" },
    -- TODO: full suite of keymaps
  },
  init = function()
    vim.g.esearch = {
      -- default_mappings = 0,
      live_update = 1,
      prefill = { "hlsearch", "last", "clipboard" },
      default_mappings = 0,
      win_map = {
        { "n", "R", "<plug>(esearch-win-reload)" },
        { "n", "t", "<plug>(esearch-win-tabopen)" },
        { "n", "T", "<plug>(esearch-win-tabopen:stay)" },
        { "n", "o", "<plug>(esearch-win-split)" },
        { "n", "O", "<plug>(esearch-win-split:reuse:stay)" },
        { "n", "s", "<plug>(esearch-win-vsplit)" },
        { "n", "S", "<plug>(esearch-win-vsplit:reuse:stay)" },
        { "n", "<cr>", "<plug>(esearch-win-open)" },
        { "n", "p", "<plug>(esearch-win-preview)" },
        { "n", "P", "100<plug>(esearch-win-preview:enter)" },
        { "n", "<esc>", "<plug>(esearch-win-preview:close)" },
        -- { " ", "J", "<plug>(esearch-win-jump:entry:down)" },
        -- { " ", "K", "<plug>(esearch-win-jump:entry:up)" },
        -- { " ", "}", "<plug>(esearch-win-jump:filename:down)" },
        -- { " ", "{", "<plug>(esearch-win-jump:filename:up)" },
        -- TODO: make this repeatable with just one press : Hydra.nvim
        -- Use ]m )m
        { "n", "]]", "<Plug>(esearch-win-jump:entry:down)" },
        { "n", "[[", "<Plug>(esearch-win-jump:entry:up)" },
        { " ", "))", "<plug>(esearch-win-jump:dirname:down)" },
        { " ", "((", "<plug>(esearch-win-jump:dirname:up)" },
        { "ov", "im", "<plug>(textobj-esearch-match-i)" },
        { "ov", "am", "<plug>(textobj-esearch-match-a)" },
        { "ic", "<cr>", "<plug>(esearch-cr)", { nowait = 1 } },
        { "n", "I", "<plug>(esearch-I)" },
        { "x", "x", "<plug>(esearch-d)" },
        { "nx", "d", "<plug>(esearch-d)" },
        { "n", "dd", "<plug>(esearch-dd)" },
        { "nx", "c", "<plug>(esearch-c)" },
        { "n", "cc", "<plug>(esearch-cc)" },
        { "nx", "C", "<plug>(esearch-C)" },
        { "nx", "D", "<plug>(esearch-D)" },
        -- { "x", "s", "<plug>(esearch-c)" },
        { "n", ".", "<plug>(esearch-.)" },
        { "n", "@:", "<plug>(esearch-@:)" },
        { "n", "za", "<plug>(esearch-za)" },
        { "n", "zc", "<plug>(esearch-zc)" },
        { "n", "zM", "<plug>(esearch-zM)" },
        { "n", "<C-q>", "<cmd>bdelete<cr>" },
        --  Yank a hovered file absolute path.
        { "n", "yf", ":call setreg(esearch#util#clipboard_reg(), b:esearch.filename())<cr>" },
        --  Open in picked window
        { "n", "<localleader>p", ':call b:esearch.open("WP")<cr>' },
        --  Render [count] more lines after a line with matches. Ex: + adds 1 line, 10+ adds 10.
        { "n", "<localleader>+", ":call esearch#init(extend(b:esearch, AddAfter(+v:count1)))<cr>" },
        --  Render [count] less lines after a line with matches. Ex: - hides 1 line, 10- hides 10.
        { "n", "<localleader>-", ":call esearch#init(extend(b:esearch, AddAfter(-v:count1)))<cr>" },
        --  Populate QuickFix list using results of the current pattern search.
        { "n", "<localleader>q", ':call esearch#init(extend(copy(b:esearch), {"out": "qflist"}))<cr>' },
        --  Sort the results by path. NOTE that it's search util-specific.
        { "n", "<localleader>sp", ":call esearch#init(extend(b:esearch, esearch_sort_by_path))<cr>" },
        --  Sort the results by modification date. NOTE that it's search util-specific.
        { "n", "<localleader>sd", ":call esearch#init(extend(b:esearch, esearch_sort_by_date))<cr>" },
        -- TODO: need to disable s/S so I can leap
        { "n", "s", "s" },
        { "n", "S", "S" },
      },
      name = "[esearch]",
    }
    vim.g.esearch_sort_by_path = { adapters = { rg = { options = "--sort path" } } }
    vim.g.esearch_sort_by_date = { adapters = { rg = { options = "--sort modified" } } }
    vim.cmd [[ let g:AddAfter = {n -> {'after': b:esearch.after + n, 'backend': 'system'}} ]]
    vim.cmd [[ let g:esearch.win_new = {esearch -> esearch#buf#goto_or_open(esearch.name, 'vnew')} ]]
  end,
}
