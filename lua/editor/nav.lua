local paranormal_map = function()
  local function paranormal(targets)
    -- Get the :normal sequence to be executed.
    local input = vim.fn.input "normal! "
    if #input < 1 then return end

    local ns = vim.api.nvim_create_namespace ""

    -- Set an extmark as an anchor for each target, so that we can also execute
    -- commands that modify the positions of other targets (insert/change/delete).
    for _, target in ipairs(targets) do
      local line, col = unpack(target.pos)
      target.extmark_id = vim.api.nvim_buf_set_extmark(0, ns, line - 1, col - 1, {})
    end

    -- Jump to each extmark (anchored to the "moving" targets), and execute the
    -- command sequence.
    for _, target in ipairs(targets) do
      local id = target.extmark_id
      local pos = vim.api.nvim_buf_get_extmark_by_id(0, ns, id, {})
      vim.fn.cursor(pos[1] + 1, pos[2] + 1)
      vim.cmd("normal! " .. input)
    end

    -- Clean up the extmarks.
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  end
  require("leap").leap {
    target_windows = { vim.fn.win_getid() },
    action = paranormal,
    multiselect = true,
  }
end

local partial = utils.partial
local hop_fn = setmetatable({}, {
  __index = function(_, n)
    return setmetatable({}, {
      __call = function(t, ...) return partial(require("hop-extensions")[n], ...) end,
      __index = function(t, k)
        return function(...) return partial(require("hop-extensions")[n][k], ...) end
      end,
    })
  end,
})

local function leap_to_line()
  local function get_line_starts(winid)
    local wininfo = vim.fn.getwininfo(winid)[1]
    local cur_line = vim.fn.line "."

    -- Get targets.
    local targets = {}
    local lnum = wininfo.topline
    while lnum <= wininfo.botline do
      local fold_end = vim.fn.foldclosedend(lnum)
      -- Skip folded ranges.
      if fold_end ~= -1 then
        lnum = fold_end + 1
      else
        if lnum ~= cur_line then table.insert(targets, { pos = { lnum, 1 } }) end
        lnum = lnum + 1
      end
    end
    -- Sort them by vertical screen distance from cursor.
    local cur_screen_row = vim.fn.screenpos(winid, cur_line, 1)["row"]
    local function screen_rows_from_cur(t)
      local t_screen_row = vim.fn.screenpos(winid, t.pos[1], t.pos[2])["row"]
      return math.abs(cur_screen_row - t_screen_row)
    end
    table.sort(targets, function(t1, t2) return screen_rows_from_cur(t1) < screen_rows_from_cur(t2) end)

    if #targets >= 1 then return targets end
  end
  local winid = vim.api.nvim_get_current_win()
  require("leap").leap {
    target_windows = { winid },
    targets = get_line_starts(winid),
  }
end

local hops = function()
  return {
    { "?", "<cmd>HopPattern<cr>", "Search" },
    { "/", hop_fn.hint_patterns_from({}, { reg = "/" }), "Last Search" },
    -- { "w", exts "hint_words", "Words" },
    { "L", hop_fn.hint_lines_skip_whitespace(), "Lines" },
    { "v", hop_fn.hint_vertical(), "Lines Column" },
    { "w", hop_fn.hint_patterns_from({}, { expand = "<cword>" }), "cword" },
    { "W", hop_fn.hint_patterns_from({}, { expand = "<cWORD>" }), "cWORD" },
    { "m", hop_fn.ts.hint_containing_nodes(), "TS Nodes Containing" },
    -- { "m", function() require("tsht").move { side = "end" } end, "TS Nodes Containing" },
    { "M", function() require("tsht").move { side = "start" } end, "TS Nodes Containing" },
    { "l", hop_fn.ts.hint_defnref(), "Locals" },
    { "D", hop_fn.ts.hint_definition(), "LSP Definitions" },
    { "r", hop_fn.lsp.hint_references(), "LSP References" },
    { "u", hop_fn.ts.hint_usages(), "TS Usages" },
    { "c", hop_fn.ts.hint_scopes(), "Scopes" },
    { "C", hop_fn.ts.hint_containing_scopes(), "Scopes" },
    { "s", hop_fn.lsp.hint_symbols(), "LSP Symbols" },
    { "d", hop_fn.hint_diagnostics(), "LSP Diagnostics" },
    {
      "k",
      hop_fn.ts.hint_textobjects({}, {
        captures = {
          "@function",
          "@block",
          "@class",
          "@conditional",
          "@loop",
        },
      }),
      "Blocks",
    },
    {
      "j",
      hop_fn.ts.hint_textobjects({}, {
        captures = {
          "@parameter",
          "@statement",
          -- "@assignment",
          "@call",
        },
      }),
      "Expressions",
    },
  }
end
return {
  { -- TODO: move from hop to leap
    "IndianBoy42/hop-extensions",
    dev = true,
    dependencies = { "phaazon/hop.nvim" },
    -- event = "VeryLazy",
    opts = {
      keys = O.hint_labels,
    },
    keys = function()
      local hop_pattern = {
        "<M-h>", -- "<M-CR>",
        "<CR><CMD>lua require'hop'.hint_patterns({}, vim.fn.getreg('/'))<CR>",
        mode = { "c" },
      }
      local keys = { hop_pattern }
      for _, rhs_ in ipairs(hops()) do
        local lhs, rhs, desc = unpack(rhs_)
        table.insert(keys, { "<leader>h" .. lhs, rhs, desc = desc, mode = { "n", "x", "o" } })
      end
      return keys
    end,
  },
  {
    "ggandor/leap.nvim",
    keys = {
      -- {
      --   "s",
      --   function()
      --     local current_window = vim.fn.win_getid()
      --     require("leap").leap { target_windows = { current_window } }
      --   end,
      --   mode = "n",
      --   desc = "Leap",
      -- },
      { "s", "<Plug>(leap-forward-to)", mode = "n", desc = "Leap" },
      { "x", "<Plug>(leap-forward-to)", mode = { "x", "o" }, desc = "Leap" },
      { "z", "<Plug>(leap-forward-till)", mode = { "x", "o" }, desc = "Leap" },
      { "S", "<Plug>(leap-backward-to)", mode = "n", desc = "Leap" },
      { "X", "<Plug>(leap-backward-to)", mode = { "x", "o" }, desc = "Leap" },
      { "Z", "<Plug>(leap-backward-till)", mode = { "x", "o" }, desc = "Leap" },
      -- {
      --   "z",
      --   function()
      --     local current_window = vim.fn.win_getid()
      --     require("leap").leap { target_windows = { current_window } }
      --   end,
      --   mode = { "x", "o" },
      --   desc = "Leap",
      -- },
    },
    config = function() end,
  },
  {
    "IndianBoy42/pounce.nvim",
    keys = {
      {
        "<leader>hf",
        -- "<cmd>Pounce<cr>",
        function()
          mappings.register_nN_repeat { "<cmd>PounceRepeat<cr>", "<cmd>PounceRepeat<cr>" }
          -- vim.cmd.Pounce()
          require("pounce").pounce()
        end,
        desc = "Fuzzy",
      },
    },
    cmd = { "Pounce" },
    opts = {
      accept_keys = O.hint_labels:upper(),
    },
  },
  {
    "ggandor/flit.nvim",
    -- TODO:
    -- dependencies = {
    --   {
    --     "jinh0/eyeliner.nvim",
    --     config = function()
    --       require("eyeliner").setup {
    --         highlight_on_key = true,
    --       }
    --     end,
    --   },
    -- },
    keys = function()
      local ret = {}
      for i, key in ipairs { "f", "F", "t", "T" } do
        ret[i] = { key, mode = { "n", "x", "o" }, desc = key }
      end
      return ret
    end,
    opts = { labeled_modes = "nx" },
  },
  {
    "cbochs/portal.nvim",
    dependencies = {
      -- "cbochs/grapple.nvim", -- Optional: provides the "grapple" query item
      -- "ThePrimeagen/harpoon", -- Optional: provides the "harpoon" query item
    },
    opts = {
      window_options = {
        border = "rounded",
        relative = "cursor",
        height = 5,
      },
      select_first = true,
      labels = O.hint_labels_array,
    },
    cmd = "Portal",
    keys = {
      { "<C-i>", function() require("portal.builtin").jumplist.tunnel_forward() end, desc = "portal fwd" },
      { "]o", function() require("portal.builtin").jumplist.tunnel_backward() end, desc = "portal fwd" },
      { "<C-o>", function() require("portal.builtin").jumplist.tunnel_backward() end, desc = "portal bwd" },
      -- TODO: use other queries?
    },
  },
  {
    "chrisgrieser/nvim-spider",
    enabled = false,
    keys = {
      { "w", "<cmd>lua require('spider').motion('w')<CR>", desc = "Spider-w", mode = { "n", "o", "x" } },
      { "e", "<cmd>lua require('spider').motion('e')<CR>", desc = "Spider-e", mode = { "n", "o", "x" } },
      { "b", "<cmd>lua require('spider').motion('b')<CR>", desc = "Spider-b", mode = { "n", "o", "x" } },
      { "ge", "<cmd>lua require('spider').motion('ge')<CR>", desc = "Spider-ge", mode = { "n", "o", "x" } },
    },
  },
}
