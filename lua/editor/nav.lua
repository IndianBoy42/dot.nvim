local partial = utils.partial
local legend = {
  [" "] = "Whitespace",
  ['"'] = 'Balanced "',
  ["'"] = "Balanced '",
  ["`"] = "Balanced `",
  ["("] = "Balanced (",
  [")"] = "Balanced ) including white-space",
  [">"] = "Balanced > including white-space",
  ["<lt>"] = "Balanced <",
  ["]"] = "Balanced ] including white-space",
  ["["] = "Balanced [",
  ["}"] = "Balanced } including white-space",
  ["{"] = "Balanced {",
  ["?"] = "User Prompt",
  _ = "Underscore",
  a = "Argument",
  b = "Brackets ), ], }",
  c = "Call",
  f = "Function",
  j = "Expression",
  k = "Block",
  l = "Line",
  q = "Quote `, \", '",
  t = "Tag",
  E = "Everything",
}
local jump_mappings = function()
  local ai = require "mini.ai"
  local jump_mode = require "keymappings.jump_mode"
  local function mapall(id, desc, sym)
    desc = desc or legend[id] or ""
    id = id or id
    -- TODO: maybe this should use mini.bracketed?
    local w = function() ai.move_cursor("left", "i", id, { search_method = "next" }) end
    local e = function() ai.move_cursor("right", "i", id, { search_method = "cover_or_next" }) end
    local b = function() ai.move_cursor("left", "i", id, { search_method = "cover_or_prev" }) end
    local ge = function() ai.move_cursor("right", "i", id, { search_method = "prev" }) end
    local W = function() ai.move_cursor("left", "a", id, { search_method = "next" }) end
    local E = function() ai.move_cursor("right", "a", id, { search_method = "cover_or_next" }) end
    local B = function() ai.move_cursor("left", "a", id, { search_method = "cover_or_prev" }) end
    local gE = function() ai.move_cursor("right", "a", id, { search_method = "prev" }) end
    local vi = function() ai.select_textobject("i", id, { search_method = "cover" }) end
    local va = function() ai.select_textobject("a", id, { search_method = "cover" }) end
    local vin = function() ai.select_textobject("i", id, { search_method = "next" }) end
    local van = function() ai.select_textobject("a", id, { search_method = "next" }) end
    local vip = function() ai.select_textobject("i", id, { search_method = "prev" }) end
    local vap = function() ai.select_textobject("a", id, { search_method = "prev" }) end
    jump_mode.repeatable(id, desc, { w, b, e, ge }, {})
    jump_mode.repeatable(
      id,
      desc,
      { W, B, E, gE },
      { body = { O.goto_next_outer, O.goto_previous_outer, O.goto_next_outer_end, O.goto_previous_outer_end } }
    )

    local hydra = jump_mode.move_by(
      O.goto_prefix .. id,
      jump_mode.move_by_suffixes,
      { w, b, e, ge, W, B, E, gE, vi, va, vin, vip, van, vap },
      desc
    )
    -- require("which-key").register({ [O.goto_prefix .. id] = desc }, {})
    if sym then
      vim.keymap.set("n", sym, function() return hydra[1]:activate() end, { desc = desc })
      for _, suffix in ipairs(jump_mode.move_by_suffixes) do
        vim.keymap.set("o", sym .. suffix, O.goto_prefix .. id .. suffix, { remap = true, desc = desc })
        vim.keymap.set("x", sym .. suffix, O.goto_prefix .. id .. suffix, { remap = true, desc = desc })
      end
      -- require("which-key").register({ [sym] = { name = desc } }, { mode = "o" })
      -- require("which-key").register({ [sym] = { name = desc } }, { mode = "x" })
    end
  end
  mapall("f", nil, "|")
  mapall("a", nil, ",")
  mapall("k", nil, "=")
  mapall("j", nil, "_")
  -- mapall("b", nil, ")")
  -- mapall("q", nil)
  -- mapall "t"
  -- mapall "p" -- TODO: paragraph movements
  -- TODO: subword movements

  for _, m in ipairs { "n", "x", "o" } do
    require("which-key").register({
      [O.goto_prefix] = {
        name = "Nav mode",
        f = legend.f,
        k = legend.k,
        a = legend.a,
        j = legend.j,
        -- q = legend.q,
        -- b = legend.b,
      },
      ["|"] = legend.f,
      ["="] = legend.k,
      [","] = legend.a,
      ["_"] = legend.j,
      -- [")"] = legend.b,
    }, {
      mode = m, -- NORMAL mode
    })
  end
end
local custom_textobjects = function(ai)
  local s = ai.gen_spec
  local ts = s.treesitter

  return {
    k = ts({
      a = {
        "@function.outer",
        "@block.outer",
        "@class.outer",
        "@conditional.outer",
        "@loop.outer",
        "@return.outer",
      },
      i = {
        "@function.inner",
        "@block.inner",
        "@class.inner",
        "@conditional.inner",
        "@loop.inner",
        "@return.inner",
      },
    }, {}),
    j = ts({
      a = { "@parameter.outer", "@statement.outer", "@call.outer" },
      i = { "@parameter.inner", "@statement.inner", "@call.inner" },
    }, {}),
    -- a = ts({ a = "@parameter.outer", i = "@parameter.inner" }, {}),
    f = ts({ a = "@function.outer", i = "@function.inner" }, {}),
    -- C = ts({ a = "@class.outer", i = "@class.inner" }, {}),
    c = ts({ a = "@call.outer", i = "@call.inner" }, {}),
    -- c = s.function_call(),
    -- line textobject
    l = function(ai_type)
      local line_num = vim.fn.line "."
      local line = vim.fn.getline(line_num)
      -- Select `\n` past the line for `a` to delete it whole
      local from_col, to_col = 1, line:len() + 1
      if ai_type == "i" then
        if line:len() == 0 then
          -- Don't remove empty line
          from_col, to_col = 0, 0
        else
          -- Ignore indentation for `i` textobject and don't remove `\n` past the line
          from_col = line:match "^%s*()"
          to_col = line:len()
        end
      end
      return { from = { line = line_num, col = from_col }, to = { line = line_num, col = to_col } }
    end,
    E = function(ai_type) return { from = { line = 0, col = 0 }, to = { line = -1, col = -1 } } end,
    B = { "%b{}", "^.%s*().-()%s*.$" },
    -- B = function(ai_type)
    --   local n_lines = vim.fn.line "$"
    --   local start_line, end_line = 1, n_lines
    --   if ai_type == "i" then
    --     -- Skip first and last blank lines for `i` textobject
    --     local first_nonblank, last_nonblank = vim.fn.nextnonblank(1), vim.fn.prevnonblank(n_lines)
    --     start_line = first_nonblank == 0 and 1 or first_nonblank
    --     end_line = last_nonblank == 0 and n_lines or last_nonblank
    --   end
    --
    --   local to_col = math.max(vim.fn.getline(end_line):len(), 1)
    --   return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
    -- end,
    C = function(ai_type)
      local line_num = vim.fn.line "."
      local first_line = 1
      local last_line = vim.fn.line "$"
      local line = vim.fn.getline(line_num)
      local cond = function(l)
        if l:len() > 3 then
          if l:sub(1, 4) == "# %%" then return true end
        end
        return false
      end
      local found_up = true

      -- Find first line in cell
      while not cond(line) do
        line_num = line_num - 1
        line = vim.fn.getline(line_num)
        if line_num == 1 then
          found_up = false
          break
        end
      end

      if not found_up then
        local cur_pos = vim.api.nvim_win_get_cursor(0)
        return {
          from = { line = cur_pos[1], col = cur_pos[2] + 1 },
        }
      end

      -- If inside, not include cell delimiter
      if ai_type == "i" then
        first_line = line_num + 1
      else
        first_line = line_num
      end

      -- Find last line in cell
      line_num = vim.fn.line "."
      line = vim.fn.getline(line_num)
      local found_down = true
      while not cond(line) do
        if line_num == last_line then
          found_down = false
          break
        end
        line_num = line_num + 1
        line = vim.fn.getline(line_num)
      end
      local last_col = line:len()
      if found_down then
        last_line = line_num - 1
        line = vim.fn.getline(last_line)
        last_col = math.max(line:len(), 1)
      else
        last_col = math.max(last_col, 1)
      end
      return { from = { line = first_line, col = 1 }, to = { line = last_line, col = last_col } }
    end,
  }
end
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

local function leap_anywhere()
  local focusable_windows_on_tabpage = vim.tbl_filter(
    function(win) return vim.api.nvim_win_get_config(win).focusable end,
    vim.api.nvim_tabpage_list_wins(0)
  )
  require("leap").leap { target_windows = focusable_windows_on_tabpage }
end
local function _leap_bi()
  local winnr = vim.api.nvim_get_current_win()
  local pre_leap_pos = vim.api.nvim_win_get_cursor(winnr)
  require("leap").leap {
    target_windows = { winnr },
    inclusive_op = true,
  }
  local post_leap_pos = vim.api.nvim_win_get_cursor(winnr)

  -- If jumping behind original position
  local behind = (pre_leap_pos[1] > post_leap_pos[1])
    or ((pre_leap_pos[1] == post_leap_pos[1]) and (pre_leap_pos[2] > post_leap_pos[2]))
  return behind
end
local function leap_bi_o(inc)
  return function()
    local behind = _leap_bi()

    if inc == true or inc == 2 then
      if behind then
        vim.cmd "normal! h"
      else
        vim.cmd "normal! l"
      end
    elseif inc == false or inc == 0 then
      if behind then
        vim.cmd "normal! l"
      else
        vim.cmd "normal! h"
      end
    end
  end
end
local function leap_bi_n()
  require("leap").leap { target_windows = { vim.api.nvim_get_current_win() }, inclusive_op = true }
end
local function leap_bi_x(inc)
  return function()
    local behind = _leap_bi()

    if inc == true or inc == 2 then
      if not behind then vim.cmd "normal! l" end
    elseif inc == false or inc == 0 then
      if behind then
        vim.cmd "normal! 2l"
      else
        vim.cmd "normal! h"
      end
    elseif inc == 1 then
      if behind then vim.cmd "normal! l" end
    end
  end
end
local leap_select_state = { prev_input = nil }
local function leap_select(kwargs)
  kwargs = kwargs or {}
  if kwargs.inclusive_op == nil then kwargs.inclusive_op = true end

  local function get_input(bwd)
    vim.cmd 'echo ""'
    local hl = require "leap.highlight"
    if vim.v.count == 0 and not (kwargs.unlabeled and vim.fn.mode(1):match "o") then
      -- TODO: figure this out
      hl["apply-backdrop"](hl, bwd)
    end
    hl["highlight-cursor"](hl)
    vim.cmd "redraw"
    local ch = require("leap.util")["get-input-by-keymap"] { str = ">" }
    hl["cleanup"](hl, { vim.fn.win_getid() })
    if not ch then return end
    -- Repeat with the previous input?
    local repeat_key = require("leap.opts").special_keys.repeat_search
    if ch == vim.api.nvim_replace_termcodes(repeat_key, true, true, true) then
      if leap_select_state.prev_input then
        ch = leap_select_state.prev_input
      else
        vim.cmd 'echo "no previous search"'
        return
      end
    else
      leap_select_state.prev_input = ch
    end
    return ch
  end
  local function get_pattern(input)
    -- See `expand-to-equivalence-class` in `leap`.
    -- Gotcha! 'leap'.opts redirects to 'leap.opts'.default - we want .current_call!
    local chars = require("leap.opts").eq_class_of[input]
    if chars then
      chars = vim.tbl_map(function(ch)
        if ch == "\n" then
          return "\\n"
        elseif ch == "\\" then
          return "\\\\"
        else
          return ch
        end
      end, chars or {})
      input = "\\(" .. table.concat(chars, "\\|") .. "\\)" -- "\(a\|b\|c\)"
    end
    return "\\V" .. (kwargs.multiline == false and "\\%.l" or "") .. input
  end
  local function get_targets(pattern, bwd)
    local search = require "leap.search"
    local bounds = search["get-horizontal-bounds"]()
    local get_char_at = require("leap.util")["get-char-at"]
    local match_positions = search["get-match-positions"](pattern, bounds, { ["backward?"] = bwd })
    local targets = {}
    for _, pos in ipairs(match_positions) do
      table.insert(targets, { pos = pos, chars = { get_char_at(pos, {}) } })
    end
    return targets
  end

  local targets2
  require("leap").leap {
    targets = function()
      local state = require("leap").state
      local pattern, pattern2
      if state.args.dot_repeat then
        pattern = state.dot_repeat_pattern
        pattern2 = state.dot_repeat_pattern2
      else
        local input = get_input(true)
        if not input then return end
        pattern = get_pattern(input)

        local input2 = get_input(false)
        if not input2 then return end
        pattern2 = get_pattern(input2)
        -- Do not save into `state.dot_repeat`, because that will be
        -- replaced by `leap` completely when setting dot-repeat.
        state.dot_repeat_pattern = pattern
        state.dot_repeat_pattern2 = pattern2
      end
      targets2 = get_targets(pattern2, false)
      return get_targets(pattern, true)
    end,
    inclusive_op = kwargs.inclusive_op,
    action = function(target)
      target.pos[2] = target.pos[2] - 1
      vim.api.nvim_win_set_cursor(0, target.pos)
      local feedkeys = vim.api.nvim_feedkeys
      feedkeys("o", "n", false)
      vim.schedule(function()
        -- TODO: AOT label this!
        require("leap").leap {
          targets = targets2,
          inclusive_op = kwargs.inclusive_op,
          action = function(target)
            target.pos[2] = target.pos[2] - 1
            vim.api.nvim_win_set_cursor(0, target.pos)
          end,
        }
      end)
    end,
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
  { "phaazon/hop.nvim" },
  { -- TODO: move from hop to leap
    "IndianBoy42/hop-extensions",
    dev = true,
    opts = { keys = O.hint_labels },
    -- event = "VeryLazy",
    keys = function()
      local hop_pattern = {
        "<C-CR>", -- "<M-CR>",
        "<CR><CMD>lua require'hop'.hint_patterns({}, vim.fn.getreg('/'))<CR>",
        mode = { "c" },
      }
      local keys = { hop_pattern }
      for _, rhs_ in ipairs(hops()) do
        local lhs, rhs, desc = unpack(rhs_)
        table.insert(keys, { O.goto_prefix .. "h" .. lhs, rhs, desc = desc, mode = { "n", "x", "o" } })
      end
      return keys
    end,
  },
  {
    "ggandor/leap.nvim",
    keys = {
      { "<leader>h", leap_anywhere, mode = "n", desc = "Leap all windows" },
      -- { "L", leap_to_line, mode = "n", desc = "Leap to Line" },
      { "s", leap_bi_n, mode = "n", desc = "Leap" },
      { "z", leap_bi_x(1), mode = "x", desc = "Leap" },
      { "<leader>f", leap_bi_x(2), mode = "x", desc = "Leap Inc" },
      { "<leader>t", leap_bi_x(0), mode = "x", desc = "Leap Exc" },
      { "z", leap_bi_o(1), mode = "o", desc = "Leap" },
      { "<leader>f", leap_bi_o(2), mode = "o", desc = "Leap Inc" },
      { "<leader>t", leap_bi_o(0), mode = "o", desc = "Leap Exc" },
      -- { "m", leap_select, mode = "v", "Leap Exc" },
      -- { "s", "<Plug>(leap-forward-to)", mode = "n", desc = "Leap Fwd" },
      -- { "S", "<Plug>(leap-backward-to)", mode = "n", desc = "Leap Bwd" },
      -- {
      --   "z", -- semi-inclusive
      --   function() require("leap").leap { inclusive_op = true } end,
      --   mode = { "x", "o" },
      --   desc = "Leap f",
      -- },
      -- {
      --   "Z", -- semi-inclusive
      --   function() require("leap").leap { backward = true, offset = 1, inclusive_op = true } end,
      --   mode = { "x", "o" },
      --   desc = "Leap f",
      -- },
      -- { "<leader>f", "<Plug>(leap-forward-to)", mode = { "x", "o" }, desc = "Leap f" },
      -- { "<leader>t", "<Plug>(leap-forward-till)", mode = { "x", "o" }, desc = "Leap t" },
      -- { "<leader>F", "<Plug>(leap-backward-to)", mode = { "x", "o" }, desc = "Leap F" },
      -- { "<leader>T", "<Plug>(leap-backward-till)", mode = { "x", "o" }, desc = "Leap T" },
    },
    config = function()
      local leap = require "leap"
      leap.opts.equivalence_classes = {
        " \t\r\n",
        "(){}[]b",
        "()p",
        "{}[]B",
        "\"'q",
        "<>t",
        -- ")]}>",
        -- "([{<",
        -- "\"'`",
      }
      -- stylua: ignore
    leap.opts.safe_labels = {
        "s", "f", "n", "u", "t",
        "h", "j", "k", "l",
        "b", "e", "w",
        ",", "-",
      }
    end,
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
      for _, key in ipairs { "f", "F", "t", "T" } do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
      end
      return ret
    end,
    opts = {
      labeled_modes = "nx",
      opts = { equivalence_classes = {} },
    },
  },
  {
    "atusy/leap-search.nvim",
    keys = {
      { "<C-CR>", '<cr><cmd>lua require("leap-search").leap(vim.fn.getreg("/"))', mode = "c", desc = "Leap Search" },
      {
        O.goto_prefix .. "n",
        function()
          local pat = vim.fn.getreg "/"
          local leapable = require("leap-search").leap(pat)
          if not leapable then return vim.fn.search(pat) end
        end,
        desc = "Leap Next",
      },
      {
        O.goto_prefix .. "N",
        function()
          local pat = vim.fn.getreg "/"
          local leapable = require("leap-search").leap(pat, {}, { backward = true })
          if not leapable then return vim.fn.search(pat, "b") end
        end,
        desc = "Leap Prev",
      },
      {
        "<leader>sI",
        function()
          require("leap-search").leap(nil, {
            engines = {
              { name = "string.find", plain = true, ignorecase = true },
              -- { name = "kensaku.query" }, -- to search Japanese string with romaji with https://github.com/lambdalisue/kensaku.vim
            },
          }, { target_windows = { vim.api.nvim_get_current_win() } })
        end,
        desc = "Leap Search",
      },
    },
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
      { "w", F "require('spider').motion('w')", desc = "Spider-w", mode = { "n", "o", "x" } },
      { "e", F "require('spider').motion('e')", desc = "Spider-e", mode = { "n", "o", "x" } },
      { "b", F "require('spider').motion('b')", desc = "Spider-b", mode = { "n", "o", "x" } },
      { "ge", F "require('spider').motion('ge')", desc = "Spider-ge", mode = { "n", "o", "x" } },
    },
  },
  {
    "rapan931/lasterisk.nvim",
    -- TODO: use lasterisk
  },
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      return {
        n_lines = 1000,
        custom_textobjects = custom_textobjects(require "mini.ai"),
        search_method = "cover",
        mappings = {
          around = "a",
          inside = "i",
          around_next = O.select_next_outer, -- TODO: select_first.lua and repeatable
          inside_next = O.select_next,
          around_last = O.select_previous_outer,
          inside_last = O.select_previous,
          -- around_next = "an", -- TODO: select_first.lua and repeatable
          -- inside_next = "in",
          -- around_last = "aN",
          -- inside_last = "iN",
          goto_left = "",
          goto_right = "",
        },
      }
    end,
    config = function(_, opts)
      local ai = require "mini.ai"
      ai.setup(opts)

      jump_mappings()

      local i = legend

      local a = vim.deepcopy(i)
      for k, v in pairs(a) do
        a[k] = v:gsub(" including.*", "")
      end

      -- local ic = vim.deepcopy(i)
      -- local ac = vim.deepcopy(a)
      -- for key, name in pairs { n = "Next", l = "Last" } do
      --   i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
      --   a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
      -- end
      require("which-key").register {
        mode = { "o", "x" },
        i = i,
        a = a,
      }
    end,
  },
  {
    "echasnovski/mini.bracketed",
    main = "mini.bracketed",
    opts = {
      -- Disable all
      buffer = { suffix = "" },
      comment = { suffix = "" },
      conflict = { suffix = "" },
      diagnostic = { suffix = "" },
      file = { suffix = "" },
      indent = { suffix = "" },
      jump = { suffix = "" },
      location = { suffix = "" },
      oldfile = { suffix = "" },
      quickfix = { suffix = "" },
      treesitter = { suffix = "" },
      undo = { suffix = "" },
      window = { suffix = "" },
      yank = { suffix = "" },
    },
    -- TODO: auto repeatable, clean up my config
  },
  {
    "camilledejoye/nvim-lsp-selection-range",
    opts = function()
      local lsr_client = require "lsp-selection-range.client"
      return {
        get_client = lsr_client.select_by_filetype(lsr_client.select),
      }
    end,
    init = function()
      utils.lsp.on_attach(function(client, bufnr)
        local map = function(mode, lhs, rhs, opts)
          if bufnr then opts.buffer = bufnr end
          vim.keymap.set(mode, lhs, rhs, opts)
        end
        if client.server_capabilities.selectionRangeProvider then
          local lsp_sel_rng = require "lsp-selection-range"
          map("n", O.select, "v" .. O.select, { remap = true, desc = "LSP Selection Range" })
          map("n", O.select, "v" .. O.select_outer, { remap = true, desc = "LSP Selection Range" })
          map("x", O.select, lsp_sel_rng.expand, { desc = "LSP Selection Range" })
          map("x", O.select_outer, O.select .. O.select, { remap = true, desc = "LSP Selection Range" }) -- TODO: use folding range
        end
      end)
    end,
  },
  {
    "ggandor/leap-ast.nvim",
    keys = {
      {
        "M",
        function() require("leap-ast").leap() end,
        mode = { "n", "x", "o" },
      },
    },
  },
  { -- TODO:? remove for leap-ast once double sided labelling is implemented
    "mfussenegger/nvim-treehopper",
    config = function() require("tsht").config.hint_keys = O.hint_labels_array end,
    -- event = { "BufReadPost", "BufNewFile" },
    keys = {
      { O.select_dynamic, [[:<C-U>lua require('tsht').nodes()<CR>]], mode = "o", silent = true },
      { O.select_dynamic, [[:lua require('tsht').nodes()<CR>]], mode = "x", silent = true },
      {
        O.goto_next .. O.select_dynamic,
        [[:<C-U>lua require('tsht').nodes({side = "end"})<CR>]],
        mode = "o",
        silent = true,
      },
      {
        O.goto_prev .. O.select_dynamic,
        [[:<C-U>lua require('tsht').nodes({side = "start"})<CR>]],
        mode = "o",
        silent = true,
      },
      {
        O.goto_next .. O.select_dynamic,
        [[:lua require('tsht').nodes({side = "end"})<CR>]],
        mode = "x",
        silent = true,
      },
      {
        O.goto_prev .. O.select_dynamic,
        [[:lua require('tsht').nodes({side = "start"})<CR>]],
        mode = "x",
        silent = true,
      },
      {
        O.goto_next .. O.select_dynamic,
        [[:lua require('tsht').nodes({side = "end", mode = "move"})<CR>]],
        mode = "n",
        silent = true,
      },
      {
        O.goto_prev .. O.select_dynamic,
        [[:lua require('tsht').nodes({side = "start", mode = "move"})<CR>]],
        mode = "n",
        silent = true,
      },
    },
    -- module = "tsht",
  },
  {
    "drybalka/tree-climber.nvim",
    opts = {
      highlight = true,
    },
    keys = { "-" },
    config = function(_, opts)
      local treeclimber = require "tree-climber"
      local tc = setmetatable({}, {
        __index = function(t, k)
          return function(args)
            return function() treeclimber[k](vim.tbl_extend("keep", args or {}, opts)) end
          end
        end,
      })
      local keys = { "w", "b", "-", "e", "I", ")", "(" }
      local keys = { "j", "k", "h", "l", "I", ")", "(" }
      require "hydra" {
        name = "Treeclimber",
        config = {
          color = "pink",
          invoke_on_body = true,
          -- timeout = 5000, -- millis
          hint = {
            border = "rounded",
            type = "window",
            position = "top",
            show_name = true,
          },
          on_key = function() vim.wait(50) end,
        },
        body = "-",
        mode = { "n", "x" },
        heads = {
          { keys[1], tc.goto_next() },
          { keys[2], tc.goto_prev() },
          { keys[3], tc.goto_parent() },
          { keys[4], tc.goto_child() },
          { keys[5], tc.select_node() },
          { keys[6], tc.swap_next { skip_comments = true } },
          { keys[7], tc.swap_prev { skip_comments = true } },
        },
      }
    end,
  },
}
