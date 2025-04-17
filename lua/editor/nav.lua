local partial = utils.partial
local nav = require "editor.nav.lib"
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
  i = "Indent",
  j = "Expression",
  k = "Block",
  l = "Line",
  q = "Quote `, \", '",
  t = "Balanced <>",
  x = "xml tag",
  E = "Everything",
  C = "Code Cell",
}
local jump_mappings = function()
  local ai = require "mini.ai"
  local jump_mode = require "keymappings.jump_mode"
  local function mapall(id, desc, sym)
    desc = desc or legend[id] or ""
    -- TODO: this should use mini.bracketed
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
    if sym then
      local hydra = jump_mode.move_by(
        sym,
        jump_mode.move_by_suffixes,
        { w, b, e, ge, W, B, E, gE, vi, va, vin, vip, van, vap },
        desc
      )
      -- TODO: enable these hydras in visual mode after selection, ie
      -- viaeee should select argument and then extend the selection 3 arguments ahead.
    end
  end
  mapall("k", nil, "<leader>k")
  mapall("a", nil, ",")
  -- mapall("b", nil, ")")
  -- mapall("q", nil)
  -- mapall "t"
  -- mapall "p" -- TODO: paragraph movements
end
local custom_textobjects = function(ai)
  local s = ai.gen_spec
  local ts = s.treesitter
  local ex = require("mini.extra").gen_ai_spec

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
    -- c = ts({ a = "@call.outer", i = "@call.inner" }, {}),
    -- c = s.function_call(),
    -- line textobject
    l = ex.line(),
    B = { "%b{}", "^.().*().$" },
    t = { "%b<>", "^.().*().$" },
    x = { "<(%w-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
    S = {
      {
        { "%u[%l%d]+[^%l%d]", "^().*()[^%l%d]$" },
        { "%S[%l%d]+[^%l%d]", "^%S().*()[^%l%d]$" },
        { "%P[%l%d]+[^%l%d]", "^%P().*()[^%l%d]$" },
        { "^[%l%d]+[^%l%d]", "^().*()[^%l%d]$" },
      },
    },
    -- Subword (TODO: 'a' variant)
    s = {
      {
        "%u[%l%d]+%f[^%l%d]",
        "%f[%S][%l%d]+%f[^%l%d]",
        "%f[%P][%l%d]+%f[^%l%d]",
        "^[%l%d]+%f[^%l%d]",
      },
      "^().*()$",
    },
    i = ex.indent(),
    e = ex.buffer(),
    d = ex.diagnostic(),
    N = ex.number(),
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

return {
  {
    "ggandor/leap.nvim",
    keys = {
      { "}" }, -- Repeat mappings
      { "{" },
      { "s", "<Plug>(leap)", mode = "n", desc = "Leap" },
      { "q", "<Plug>(leap)", mode = { "x", "o" }, desc = "Leap" },
      { "S", "<Plug>(leap-remote)", mode = "n", desc = "Leap Remote" },
      {
        O.goto_prefix .. O.goto_prefix,
        "<Plug>(leap-anywhere)",
        mode = { "n", "x", "o" },
        desc = "Leap anywhere",
      },
      { ";", leap_bi_o(1), mode = "o", desc = "Leap SemiInc" },
      { ".", leap_bi_o(2), mode = "o", desc = "Leap Incl." },
      {
        "t", -- semi-inclusive
        function()
          vim.cmd.normal { "v", bang = true }
          require("leap").leap { inclusive_op = true }
        end,
        mode = "n",
        desc = "Leap v t",
      },
      {
        "T", -- semi-inclusive
        function()
          vim.cmd.normal { "v", bang = true }
          require("leap").leap { backward = true, offset = 1, inclusive_op = true }
        end,
        mode = "n",
        desc = "Leap v T",
      },
      {
        O.select_dynamic,
        "<Plug>(leap-treesitter)",
        mode = { "o", "x" },
        desc = "Cursor Node",
      },
      {
        O.goto_prefix .. "r",
        "<Plug>(leap-remote)",
        desc = "Leap Remote",
        mode = { "n", "x", "o" },
      },
      {
        "r",
        "<Plug>(leap-remote)",
        desc = "Leap Remote",
        mode = "o",
      },
      {
        "<Plug>(leap-remote)",
        function() require("leap.remote").action() end,
        desc = "Leap Remote",
        mode = { "o", "x" },
      },
      { -- FIXME: treesitter doesn't trigger (leap thinks we're done too soon)
        O.select_remote_dynamic,
        function()
          require("leap.remote").action {
            input = "<Plug>(leap-treesitter)",
          }
        end,
        desc = "Leap Remote",
        mode = { "o", "x" },
      },
      {
        "<Plug>(leap-treesitter)",
        function()
          require("leap.treesitter").select()
          -- local sk = vim.deepcopy(require("leap").opts.special_keys)
          -- -- The items in `special_keys` can be both strings or tables - the
          -- -- shortest workaround might be the below one:
          -- sk.next_target = vim.fn.flatten(vim.list_extend({ O.select_dynamic }, { sk.next_target }))
          -- sk.prev_target = vim.fn.flatten(vim.list_extend({ O.select_dynamic:upper() }, { sk.prev_target }))
          -- require("leap.treesitter").select { opts = { special_keys = sk } }
        end,
        mode = { "n", "o", "x" },
        desc = "Cursor Node",
      },
      {
        "<Plug>(leap-treesitter-line)",
        'V<cmd>lua require("leap.treesitter").select()<cr>',
        mode = { "n", "o", "x" },
        desc = "Cursor V Node",
      },
      {
        "<leader>gx",
        function() require("leap.remote").action { input = "gx" } end,
        desc = "Leap Remote",
        mode = { "o", "x" },
      },
      {
        "ar",
        function()
          local ok, char = pcall(vim.fn.getcharstr)
          if not ok or char == vim.keycode "<esc>" then return end
          require("leap.remote").action { input = "a" .. char }
        end,
        mode = { "o", "x" },
        desc = "Leap Remote (inside)",
      },
      {
        "ir",
        function()
          local ok, char = pcall(vim.fn.getcharstr)
          if not ok or char == vim.keycode "<esc>" then return end
          require("leap.remote").action { input = "i" .. char }
        end,
        mode = { "o", "x" },
        desc = "Leap Remote (around)",
      },
      {
        "rp",
        mode = "n",
        desc = "Remote Paste",
        nav.remote_paste(),
        -- function() require("leap.remote").action { input = "p" } end,
      },
      {
        "rP",
        mode = "n",
        desc = "Remote Paste line",
        nav.remote_paste(nil, "<Plug>(YankyPutIndentAfterLinewise)"),
      },
      -- [cdy]<>rp<>
      -- [cdy]<>R<>
      -- [cdy]r<>[pP]
      -- [cdy]r<>r<>
      -- TODO: y<motion><something><leap><motion>
      {
        "rx",
        mode = { "n", "x" },
        desc = "Exchange <motion1> with <motion2>",
        function()
          require("leap.remote").action {
            input = "cx",
            and_then = ".",
          }
        end,
      },
      {
        "rX",
        mode = { "n", "x" },
        desc = "Exchange V<motion1> with V<motion2>",
        function()
          require("leap.remote").action {
            input = "cxV",
            and_then = ".",
          }
        end,
      },
      {
        "ry",
        mode = { "n" },
        desc = "Remote yank and paste here",
        function()
          require("leap.remote").action {
            input = "y",
            and_then = "P",
          }
        end,
      },
      {
        "rd",
        mode = { "x", "n" },
        desc = "Remote delete and paste here",
        function()
          require("leap.remote").action {
            input = "d",
            and_then = "P",
          }
        end,
      },
      {
        "rc",
        mode = { "x", "n" },
        desc = "Remote change and paste here",
        function()
          require("leap.remote").action {
            input = "c",
            and_then = "P",
          }
        end,
      },
      -- TODO: implement these with leap.remote (without repeat motion?)
      { -- FIXME: swap the order of this
        "rY",
        mode = { "x", "n" },
        desc = "Replace with <remote-motion>",
        function() nav.swap_with { exchange = { not_there = true } } end,
      },
      { -- FIXME: swap the order of this
        "rD",
        mode = { "x", "n" },
        desc = "Replace with d<remote-motion>",
        function() nav.swap_with { exchange = { not_there = true } } end,
      },
      { -- FIXME: swap the order of this
        "rC",
        mode = { "x", "n" },
        desc = "Replace with c<remote-motion>",
        function() nav.swap_with { exchange = { not_there = true } } end,
      },
      { "<leader>f", "<Plug>(leap-forward-to)", mode = "x", desc = "Leap f" },
      { "<leader>t", "<Plug>(leap-forward-till)", mode = "x", desc = "Leap t" },
      { "<leader>F", "<Plug>(leap-backward-to)", mode = "x", desc = "Leap F" },
      { "<leader>T", "<Plug>(leap-backward-till)", mode = "x", desc = "Leap T" },
      -- { "<leader>f", leap_bi_x(2), mode = "x", desc = "Leap Inc" },
      -- { "<leader>t", leap_bi_x(0), mode = "x", desc = "Leap Exc" },
      { "<leader>f", leap_bi_o(2), mode = "o", desc = "Leap Inc" },
      { "<leader>t", leap_bi_o(0), mode = "o", desc = "Leap Exc" },
    },
    -- TODO: unlazy me
    config = function()
      local leap = require "leap"
      leap.opts.equivalence_classes = {
        " \t\r\n",
        "(){}[]b",
        "()p",
        "{}[]B",
        "\"'`q",
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
      -- TODO: make this n/N for repeating motions
      require("leap.user").set_repeat_keys("}", "{", {})
      local remote = require("leap.remote").action
      require("leap.remote").action = function(args)
        if args and args.and_then then
          vim.api.nvim_create_autocmd("User", {
            group = vim.api.nvim_create_augroup("UserLeapRemote", {}),
            once = true,
            pattern = "RemoteOperationDone",
            callback = function()
              if type(args.on_return) == "string" then
                vim.feedkeys(args.and_then, "m")
              else
                args.and_then()
              end
            end,
          })
        else
          vim.api.nvim_create_augroup("UserLeapRemote", { clear = true })
        end
        remote(args)
      end
    end,
  },
  {
    "ggandor/flit.nvim",
    lazy = false,
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
    opts = {
      labeled_modes = "nx",
      opts = { equivalence_classes = {} },
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      labels = O.hint_labels,
      search = {
        incremental = true,
      },
      highlight = { backdrop = false },
      label = { current = true },
      jump = {
        autojump = false, -- Causes accidents
        history = true,
        register = true,
        pos = "start", ---@type "start" | "end" | "range"
      },
      remote_op = {
        restore = true,
        motion = true,
      },
      modes = {
        search = {
          enabled = false,
          label = { min_pattern_length = 3 },
        },
        char = {
          enabled = false,
          keys = { "f", "F", "t", "T" },
        },
        fuzzy = {
          search = { mode = "fuzzy", max_length = 9999 },
          label = { min_pattern_length = 9999 },
          jump = { autojump = false },
          char_actions = function(motion)
            return {
              [vim.keycode "<C-g>"] = "next",
              [vim.keycode "<C-t>"] = "prev",
            }
          end,
          -- label = { before = true, after = false },
        },
        treesitter = {
          labels = O.hint_labels,
          remote_op = {
            restore = false,
            motion = false,
          },
          search = { multi_window = false, wrap = true, incremental = false, max_length = 0 },
          config = function(opts)
            if false and vim.fn.mode() == "v" then
              opts.labels:gsub("[cdyrxCDYRX]", "") -- TODO: Remove all operations
            end
          end,
          treesitter = {},
          matcher = nav.custom_ts,
          actions = nav.ts_actions,
        },
        remote_ts = {
          -- TODO: use `;,<cr><tab><spc` to extend the selection to sibling nodes
          -- TODO: integrate i/a textobjects somehow. Maybe 'i<label><char>' = jump<label> i<char>
          mode = "treesitter",
          search = {
            -- mode = "fuzzy",
            -- mode = navutils.remote_ts_search,
            max_length = 2,
            incremental = false,
          },
          jump = { pos = "range", register = false },
          highlight = { matches = true },
          treesitter = {},
          remote_op = {
            restore = true,
            motion = true,
          },
          matcher = nav.remote_ts,
          actions = nav.ts_actions,
        },
        remote_sel = {
          mode = "treesitter",
          search = {
            -- mode = "fuzzy",
            -- mode = navutils.remote_ts_search,
            max_length = 4,
            incremental = false,
          },
          label = { min_pattern_length = 2 },
          jump = { pos = "range", register = false },
          highlight = { matches = true },
          treesitter = {},
          remote_op = {
            restore = true,
            motion = true,
          },
          matcher = nav.remote_sel,
          actions = nav.ts_actions,
        },
        leap = { -- Is this even possible really?
          search = {
            max_length = 2,
          },
        },
        textcase = {
          search = { mode = nav.mode_textcase },
        },
        search_diagnostics = {
          search = { mode = "fuzzy" },
          action = nav.there_and_back(utils.lsp.diag_line),
        },
        hover = {
          search = { mode = "fuzzy" },
          action = function(match, state)
            vim.api.nvim_win_call(match.win, function()
              vim.api.nvim_win_set_cursor(match.win, match.pos)
              utils.lsp.hover(function(err, result, ctx)
                vim.lsp.handlers.hover(err, result, ctx, { focusable = true, focus = true })
                -- vim.api.nvim_win_set_cursor(match.win, state.pos)
              end)
            end)
          end,
        },
        select = {
          search = { mode = "fuzzy" },
          jump = { pos = "range" },
          label = { before = true, after = true },
        },
        references = {},
        diagnostics = {
          search = { multi_window = true, wrap = true, incremental = true },
          label = { current = true },
          highlight = { backdrop = true },
        },
        remote = {
          search = { mode = "fuzzy" },
          jump = { autojump = true },
        },
      },
    },
    keys = {
      -- TODO: jump continue with nN
      {
        "?",
        mode = { "n", "x", "o" },
        function() require("flash").jump { mode = "fuzzy" } end,
        desc = "Fuzzy search",
      },
      { O.goto_prefix .. "/", "/<Plug>(flash-search-toggle)", desc = "Flash search(/)" },
      { "<C-s>", mode = "c", "<Plug>(flash-search-toggle)", desc = "Flash search(/)" },
      {
        "<Plug>(flash-search-toggle)",
        mode = { "n", "c" },
        function() require("flash").toggle() end,
        desc = "Flash search(/)",
      },
      -- {
      --   "?",
      --   mode = { "o" },
      --   function() require("flash").remote { mode = "select" } end,
      --   desc = "Fuzzy Sel",
      -- },
      -- {
      --   "?",
      --   mode = "x",
      --   function() require("flash").jump { mode = "select" } end,
      --   desc = "Fuzzy Sel",
      -- },
      {
        "<Plug>(flash-treesitter)",
        mode = { "n", "o", "x" },
        desc = "Cursor Node",
        function() require("flash").jump { mode = "treesitter" } end,
      },
      -- {
      --   O.select_remote_dynamic,
      --   mode = { "o", "x" },
      --   desc = "Remote Node",
      --   "<Plug>(flash-remote-ts)",
      -- },
      {
        "<Plug>(flash-remote-ts)",
        mode = { "o", "x" },
        desc = "Remote Node",
        function() require("flash").jump { mode = "remote_ts" } end,
      },
      -- {
      --   O.goto_next .. O.select_remote_dynamic,
      --   mode = { "o", "x" },
      --   function() require("flash").jump { mode = "remote_ts", treesitter = { starting_from_pos = true } } end,
      --   desc = "Select node",
      -- },
      -- {
      --   O.goto_prev .. O.select_remote_dynamic,
      --   mode = { "o", "x" },
      --   function() require("flash").jump { mode = "remote_ts", treesitter = { ending_at_pos = true } } end,
      --   desc = "Select node",
      -- },
      {
        O.goto_next .. O.select_remote_dynamic,
        mode = "n",
        function()
          require("flash").jump {
            mode = "remote_ts",
            treesitter = { end_of_node = true },
            jump = { pos = "end" },
          }
        end,
        desc = "Jump to end of node",
      },
      {
        O.goto_prev .. O.select_remote_dynamic,
        mode = "n",
        function()
          require("flash").jump {
            mode = "remote_ts",
            treesitter = { start_of_node = true },
            jump = { pos = "start" },
          }
        end,
        desc = "Jump to start of node",
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
      max_results = 5,
      labels = O.hint_labels_array,
    },
    cmd = "Portal",
    keys = {
      {
        "<C-i>",
        function() require("portal.builtin").jumplist.tunnel_forward() end,
        desc = "portal fwd",
      },
      {
        "[j",
        function() require("portal.builtin").jumplist.tunnel_backward() end,
        desc = "portal bwd",
      },
      {
        "]j",
        function() require("portal.builtin").jumplist.tunnel_forward() end,
        desc = "portal fwd",
      },
      {
        "<C-o>",
        function() require("portal.builtin").jumplist.tunnel_backward() end,
        desc = "portal bwd",
      },
      -- TODO: use other queries?
    },
  },
  {
    "chrisgrieser/nvim-spider",
    -- TODO: subword hydra
    opts = { skipInsignificantPunctuation = true },
    config = function(_, opts)
      require("spider").setup(opts)
      require "hydra" {
        name = "Subwords",
        mode = "n",
        hint = false,
        body = "_",
        heads = {
          { "w", "<cmd>lua require('spider').motion('w')<cr>", desc = "Spider-w" },
          { "e", "<cmd>lua require('spider').motion('e')<cr>", desc = "Spider-e" },
          { "b", "<cmd>lua require('spider').motion('b')<cr>", desc = "Spider-b" },
          { "g", "<cmd>lua require('spider').motion('ge')<cr>", desc = "Spider-ge" },
        },
      }
    end,
    keys = { "_" },
  },
  {
    "rapan931/lasterisk.nvim",
    -- TODO: use lasterisk
  },
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = { "echasnovski/mini.extra" },
    config = function(_, opts)
      _G.config_traceback = debug.traceback()
      local ai = require "mini.ai"
      opts = {
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
        silent = true,
      }
      ai.setup(opts)

      jump_mappings()

      local wkdescs = {
        mode = { "o", "x" },
      }

      for k, v in pairs(legend) do
        wkdescs[#wkdescs + 1] = { "i" .. k, desc = v }
        wkdescs[#wkdescs + 1] = { "a" .. k, desc = v:gsub(" including.*", "") }
      end

      require("which-key").add(wkdescs)
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
        if O.select and client.server_capabilities.selectionRangeProvider then
          local lsp_sel_rng = require "lsp-selection-range"
          map("n", O.select, "v" .. O.select, { remap = true, desc = "LSP Selection Range" })
          map("n", O.select, "v" .. O.select_outer, { remap = true, desc = "LSP Selection Range" })
          map("x", O.select, lsp_sel_rng.expand, { desc = "LSP Selection Range" })
          map(
            "x",
            O.select_outer,
            O.select .. O.select,
            { remap = true, desc = "LSP Selection Range" }
          ) -- TODO: use folding range
        end
      end)
    end,
  },
}
