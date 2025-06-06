local M = {}

M.there_and_back = function(action, jump_back)
  return function(match, state)
    vim.api.nvim_win_call(match.win, function()
      vim.api.nvim_win_set_cursor(match.win, match.pos)
      action()
      vim.schedule(function() state:restore() end)
    end)
  end
end

M.flash_diagnostics = function(opts)
  local action = opts and opts.action or vim.diagnostic.open_float
  if opts and opts.action then opts.action = nil end

  require("flash").jump(vim.tbl_deep_extend("force", {
    matcher = function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      return vim.tbl_map(
        ---@param diag Diagnostic
        function(diag)
          return {
            pos = { diag.lnum + 1, diag.col },
            end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
          }
        end,
        vim.diagnostic.get(buf)
      )
    end,
    action = function(match, state)
      vim.api.nvim_set_current_win(match.win)
      vim.api.nvim_win_set_cursor(match.win, match.pos)
      action()
    end,
    search = { max_length = 0 },
  }, opts or {}))
end

M.flash_references = function(opts)
  local params = vim.lsp.util.make_position_params()
  params.context = {
    includeDeclaration = true,
  }
  local first = true
  local bufnr = vim.api.nvim_get_current_buf()
  vim.lsp.buf_request(bufnr, "textDocument/references", params, function(_, result, ctx)
    if not vim.islist(result) then result = { result } end
    if first and result ~= nil and not vim.tbl_isempty(result) then
      first = false
    else
      return
    end
    require("flash").jump(vim.tbl_deep_extend("force", {
      mode = "references",
      search = { max_length = 0 },
      matcher = function(win)
        local cword = #vim.fn.expand "<cword>"
        local oe = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding
        return vim.tbl_map(function(loc)
          local end_pos
          if not loc.end_col then
            end_pos = { loc.lnum, loc.col + cword - 2 }
          else
            end_pos = { loc.end_lnum or loc.lnum, loc.end_col - 1 }
          end
          return {
            pos = { loc.lnum, loc.col - 1 },
            end_pos = end_pos,
          }
        end, vim.lsp.util.locations_to_items(result, oe))
      end,
    }, opts or {}))
  end)
end

M.flash_lines = function(opts)
  require("flash").jump(vim.tbl_deep_extend("force", {
    mode = "lines",
    matcher = function(win)
      local cur = vim.api.nvim_win_get_cursor(win)
      local wininfo = vim.api.nvim_win_call(win, function() return vim.fn.winsaveview() end)
      local top = wininfo.topline
      local h = vim.api.nvim_win_get_height(win)

      local res = {}
      for i = 1, h do
        local pos = { top + i, cur[2] }
        res[#res + 1] = {
          pos = pos,
          end_pos = pos,
        }
      end
      return res
    end,
  }, opts or {}))
end

M.mode_textcase = function(pat, modes)
  modes = modes
    or {
      "to_constant_case",
      "to_lower_case",
      "to_snake_case",
      "to_dash_case",
      "to_camel_case",
      "to_pascal_case",
      "to_path_case",
      "to_title_case",
      "to_phrase_case",
      "to_dot_case",
    }
  local pats = { pat }
  local tc = require("textcase").api
  for _, mode in ipairs(modes) do
    local pat2 = tc[mode](pat)
    if pat2 ~= pat then pats[#pats + 1] = pat2 end
  end
  return "\\V\\(" .. table.concat(pats, "\\|") .. "\\)"
end

local do_op = function(state, win, pos, end_pos)
  local _restore = function()
    vim.api.nvim_set_current_win(state.win)
    vim.fn.winrestview(state.view)
  end
  local function restore()
    vim.schedule(function()
      -- TODO: wait if visual mode
      require("flash.jump").restore_remote {
        restore = _restore,
      }
    end)
  end
  local function __do_op(start, finish)
    vim.api.nvim_win_set_cursor(0, start)
    vim.cmd "normal! v"
    vim.api.nvim_win_set_cursor(0, finish)
    vim.api.nvim_input('"' .. state.register .. state.operator)

    restore()
  end

  vim.api.nvim_feedkeys(vim.keycode "<C-\\><C-n>", "nx", false)
  vim.api.nvim_feedkeys(vim.keycode "<esc>", "n", false)

  vim.schedule(function()
    vim.api.nvim_set_current_win(win)

    if not end_pos or type(end_pos) ~= "table" then -- Use a op-pending to get a selction
      vim.api.nvim_win_set_cursor(win, pos)

      if type(end_pos) == "function" then
        end_pos() -- FIXME: doesn't work at all
        restore()
      else
        -- _G.__remote_op_opfunc = function() __do_op(vim.api.nvim_buf_get_mark(0, "["), vim.api.nvim_buf_get_mark(0, "]")) end
        -- vim.go.operatorfunc = "v:lua.__remote_op_opfunc"
        vim.go.operatorfunc = state.op_func
        vim.api.nvim_input('"' .. state.register .. state.operator .. (end_pos and end_pos or ""))
        restore()
      end
    else
      __do_op(pos, end_pos)
    end
  end)
end

M.remote_op = function(callback, operator, register, opfunc)
  if operator then
    if type(operator) == "function" then
      _G.__remote_op_opfunc = operator
      operator = "g@"
      opfunc = "v:lua.__remote_op_opfunc"
    end
  end
  local opstate = {
    operator = operator or vim.v.operator,
    register = register or vim.v.register,
    op_func = opfunc or vim.go.operatorfunc,
    pos = vim.api.nvim_win_get_cursor(0),
    win = vim.api.nvim_get_current_win(),
    view = vim.fn.winsaveview(),
  }

  -- vim.api.nvim_feedkeys(vim.keycode "<C-\\><C-n>", "nx", false)
  -- vim.api.nvim_feedkeys(vim.keycode "<esc>", "n", false)
  if callback then callback(function(...) do_op(opstate, ...) end) end
  return opstate
end
M.do_op = do_op

local swap_text = function(opts, ma, mb)
  local start, finish = vim.api.nvim_buf_get_mark(0, ma), vim.api.nvim_buf_get_mark(0, mb)
  local this_text =
    vim.api.nvim_buf_get_text(0, start[1] - 1, start[2], finish[1] - 1, finish[2], {})
  vim.schedule(function()
    require("flash").jump(vim.tbl_deep_extend("force", {
      action = function(match, state)
        local other_buf = vim.api.nvim_win_get_buf(match.win)
        local other_start, other_finish = match.pos, match.end_pos
        local other_text = vim.api.nvim_buf_get_text(
          0,
          other_start[1] - 1,
          other_start[2],
          other_finish[1] - 1,
          other_finish[2],
          {}
        )
        vim.api.nvim_buf_set_text(
          other_buf,
          other_start[1] - 1,
          other_start[2],
          other_finish[1] - 1,
          other_finish[2],
          this_text
        )
        vim.api.nvim_buf_set_text(0, start[1] - 1, start[2], finish[1] - 1, finish[2], other_text)
      end,
      remote_op = {
        restore = true,
        motion = true,
      },
    }, opts))
  end)
end

local swap_with = function(opts, ma, mb, jumper)
  local reg = vim.fn.getreg '"'
  -- TODO: can use extmarks instead
  local start, finish = vim.api.nvim_buf_get_mark(0, ma), vim.api.nvim_buf_get_mark(0, mb)
  local ra, rb = vim.api.nvim_buf_get_mark(0, "a"), vim.api.nvim_buf_get_mark(0, "b")
  vim.api.nvim_buf_set_mark(0, "a", start[1], start[2], {})
  vim.api.nvim_buf_set_mark(0, "b", finish[1], finish[2], {})
  local vis_mode = opts and opts.exchange and opts.exchange.visual_mode or "v"
  vim.api.nvim_feedkeys("`a" .. vis_mode .. "`by", "nx", false)

  -- vim.schedule(function()
  _G.__remote_op_opfunc = function()
    local a, b, c, d = "`a", "`b", "`[", "`]"
    if opts.reversed then
      a, b, c, d = c, d, b, a
    end
    local action = c .. vis_mode .. d
    if opts and opts.exchange and opts.exchange.not_there then
      action = action .. "y"
    else
      action = action .. "p"
    end
    if not (opts and opts.exchange and opts.exchange.not_here) then
      action = action .. a .. vis_mode .. b .. "p"
    end
    vim.cmd("normal! " .. action)

    vim.fn.setreg('"', reg)
    vim.api.nvim_buf_set_mark(0, "a", ra[1], ra[2], {})
    vim.api.nvim_buf_set_mark(0, "b", rb[1], rb[2], {})
  end
  vim.go.operatorfunc = "v:lua.__remote_op_opfunc"
  vim.api.nvim_feedkeys("g@" .. (jumper or vim.keycode "<Plug>(leap-remote)"), "mi", false)
  -- end)
end

M.swap_with = function(opts, textobj, textobj2)
  -- FIXME:
  if opts and opts.reversed then
    textobj, textobj2 = textobj2, textobj
    textobj = textobj or vim.keycode "<Plug>(leap-remote)"
    textobj2 = textobj2 or ""
  end
  _G.__remote_op_opfunc = function() swap_with(opts, "[", "]", textobj2) end
  vim.go.operatorfunc = "v:lua.__remote_op_opfunc"
  vim.api.nvim_feedkeys("g@" .. (textobj or ""), "mi", false)
end
M.exch_with = function(opts, textobj, textobj2)
  local v = opts and opts.exchange and opts.exchange.visual_mode or "v"
  _G.__remote_op_opfunc = function()
    require("substitute.exchange").operator {
      motion = vim.keycode("<cmd>normal! " .. v .. "`[o`]\r"),
    }
    vim.api.nvim_feedkeys("cx" .. (textobj2 or vim.keycode "<Plug>(leap-remote)"), "m", false)
  end
  vim.go.operatorfunc = "v:lua.__remote_op_opfunc"
  vim.api.nvim_feedkeys("g@" .. (textobj or ""), "mi", false)
end
M.two_part = function(opts, op, textobj, op2, textobj2)
  local v = opts and opts.exchange and opts.exchange.visual_mode or "v"
  _G.__remote_op_opfunc = function()
    vim.api.nvim_feedkeys(
      vim.keycode(
        op
          .. "<cmd>normal! "
          .. v
          .. "`[o`]"
          .. op2
          .. (textobj2 or vim.keycode "<Plug>(leap-remote)")
      ),
      "m",
      false
    )
  end
  vim.go.operatorfunc = "v:lua.__remote_op_opfunc"
  vim.api.nvim_feedkeys("g@" .. (textobj or ""), "mi", false)
end

function M.leap_anywhere(action)
  local focusable_windows_on_tabpage = vim.tbl_filter(
    function(win) return vim.api.nvim_win_get_config(win).focusable end,
    vim.api.nvim_tabpage_list_wins(0)
  )
  require("leap").leap {
    case_sensitive = false,
    target_windows = focusable_windows_on_tabpage,
    action = action,
  }
end
M.leap_remote = function()
  M.remote_op(function(do_op)
    M.leap_anywhere(function(jt) do_op(jt.wininfo.winid, jt.pos) end)
  end)
end

M.remote_paste_manual = function(key, paste_key)
  key = key or "<Plug>(leap-anywhere)"
  paste_key = paste_key or "p"
  return function()
    local view = vim.fn.winsaveview()
    local winnr = vim.api.nvim_get_current_win()
    local pos = vim.api.nvim_win_get_cursor(winnr)
    _G.__remote_op_opfunc = function()
      local win2 = vim.api.nvim_get_current_win()
      local cur = vim.api.nvim_win_get_cursor(win2)
      -- Get the other side of the selection
      local a, b = vim.api.nvim_buf_get_mark(0, "["), vim.api.nvim_buf_get_mark(0, "]")
      if cur[1] == a[1] and cur[2] == a[2] then
        vim.api.nvim_win_set_cursor(win2, b)
      elseif cur[1] == b[1] and cur[2] == b[2] then
        a[2] = a[2] - 1
        vim.api.nvim_win_set_cursor(win2, a)
      end
      -- vim.api.nvim_input(vim.keycode "<esc>" .. paste_key)
      vim.api.nvim_feedkeys(vim.keycode(paste_key), "m", false)
      vim.schedule(function()
        vim.api.nvim_set_current_win(winnr)
        vim.fn.winrestview(view)
        vim.api.nvim_win_set_cursor(winnr, pos)
      end)
    end
    vim.go.operatorfunc = "v:lua.__remote_op_opfunc"
    vim.api.nvim_feedkeys("g@" .. key, "m", false)
  end
end

M.remote_paste = function(key, paste_key, dir_key)
  paste_key = paste_key or "p"
  dir_key = dir_key or "l"
  return function()
    _G.__remote_op_opfunc = function() vim.api.nvim_feedkeys(vim.keycode(paste_key), "m", false) end
    vim.go.operatorfunc = "v:lua.__remote_op_opfunc"
    require("leap.remote").action {
      input = "g@" .. dir_key,
    }
  end
end

-- TODO: operator that when repeated does a replace instead
M.dual_operator = function(op1, op2)
  op1 = op1 or "y"
  op2 = op2 or "r"
  local is_repeat = false
  return function()
    _G.__remote_op_opfunc = function()
      if is_repeat then
        vim.api.nvim_feedkeys("`[" .. op2 .. "`]", "m", false)
      else
        vim.api.nvim_feedkeys("`[" .. op1 .. "`]", "m", false)
      end
    end
    vim.go.operatorfunc = "v:lua.__remote_op_opfunc"
    is_repeat = true
    return "g@"
  end
end

local ai_objs = {
  "a(",
  "i(",
  "a'",
  "i'",
  'a"',
  'i"',
  "a[",
  "i[",
  "a{",
  "i{",
  "a<",
  "i<",
  "a`",
  "i`",
}
M.filter_nodes = function(nodes, win, pos, end_pos)
  local Pos = require "flash.search.pos"
  local function fto(obj, count)
    return MiniAi.find_textobject(obj:sub(1, 1), obj:sub(2, 2), {
      search_method = "cover",
      reference_region = {
        from = { line = pos[1], col = pos[2] + 1 },
        -- to = { line = end_pos[1], col = end_pos[2] },
      },
      n_times = count,
    })
  end
  for _, obj in ipairs(ai_objs) do
    if type(obj) == "string" then
      local count = 1
      local tobj = fto(obj, count)
      while tobj ~= nil do
        nodes[#nodes + 1] = {
          pos = Pos { tobj.from.line, tobj.from.col - 1 },
          end_pos = Pos { tobj.to.line, tobj.to.col - 1 },
          win = win,
        }
        count = count + 1
        tobj = fto(obj, count)
      end
    elseif type(obj) == "function" then
      obj(win, pos, end_pos)
    end
  end
  return nodes
end
M.get_nodes = function(win, pos, end_pos)
  local nodes = require("flash.plugins.treesitter").get_nodes(win, pos)
  local matches = {}
  -- nodes = M.filter_nodes(nodes, win, pos, end_pos)
  return nodes
end

local function sib(dir, n)
  if dir < 0 then
    return n:prev_named_sibling()
  else
    return n:next_named_sibling()
  end
end

local function node_proc(bwd, fwd, m, matches, n, opts, state)
  local ok = true
  local tsopts = state.opts.treesitter or {}
  if tsopts.starting_from_pos then ok = ok and (m.pos == n.pos) end
  if tsopts.ending_at_pos then ok = ok and (m.end_pos == n.end_pos) end
  if tsopts.containing_end_pos or tsopts.containing_end_pos == nil then
    ok = ok and (m.end_pos <= n.end_pos)
  end
  if fwd ~= 0 or bwd ~= 0 then
    local node = n.node
    local parent = n.node:parent()
    while parent ~= nil do
      local a, b, c, d = parent:range()
      local na, nb, nc, nd = node:range()
      if a ~= na or b ~= nb or c ~= nc or d ~= nd then break end
      node = parent
      parent = parent:parent()
    end

    local sn, en = node, node
    if fwd ~= 0 then
      for _ = 1, math.abs(fwd) do
        en = sib(fwd, en)
        if en == nil then
          ok = false
          break
        end
      end
      if en ~= nil then
        local r, c = en:end_()
        n.end_pos = { row = r + 1, col = c - 1 }
        -- TODO: needs some correction
      end
    end
    if bwd ~= 0 then
      for _ = 1, math.abs(bwd) do
        sn = sib(-bwd, sn)
        if sn == nil then
          ok = false
          break
        end
      end
      if sn ~= nil then
        local r, c = sn:start()
        n.pos = { row = r + 1, col = c }
      end
    end
  end

  if ok then
    -- don't highlight treesitter nodes. Use labels only
    n.highlight = false
    if tsopts.end_of_node then
      n.pos = n.end_pos
      n.end_pos = n.pos
    end
    if tsopts.start_of_node then
      if tsopts.end_of_node then
        local n2 = vim.deepcopy(n)
        n2.end_pos = nil
        table.insert(matches, n2)
      else
        n.end_pos = nil
      end
    end
    table.insert(matches, n)
  end
  return ok
end

-- TODO: Full on almost arbitrary node selection (iswap.nvim style)
-- TODO: "outer" variation by extending to sibling nodes
M.custom_ts = function(win, state, opts)
  local fwd = state.remote_ts_fwd or 0
  local bwd = state.remote_ts_bwd or 0
  local matches = {}
  local m = {
    pos = state.pos,
    end_pos = state.pos,
  }
  for _, n in ipairs(M.get_nodes(win, m.pos, m.end_pos)) do
    node_proc(bwd, fwd, m, matches, n, opts, state)
  end
  return matches
end
M.remote_ts = function(win, state, opts)
  if state.pattern.pattern == " " then
    state.opts.search.max_length = 1
    return M.custom_ts(win, state, opts)
  end

  local Search = require "flash.search"
  local matches = {} ---@type Flash.Match[]
  local search = Search.new(win, state)
  local smatches = search:get(opts)
  local find_nodes = #state.pattern.pattern >= 2
  local fwd = state.remote_ts_fwd or 0
  local bwd = state.remote_ts_bwd or 0
  for _, m in ipairs(smatches) do
    local ok = false
    if find_nodes then
      for _, n in ipairs(M.get_nodes(win, m.pos, m.end_pos)) do
        ok = node_proc(bwd, fwd, m, matches, n, opts, state)
      end
    end
    if not find_nodes or ok then
      -- don't add labels to the search results
      m.label = false
      table.insert(matches, m)
    end
  end
  return matches
end
local function ts_shift(state, fwdincr, bwdincr)
  state.remote_ts_fwd = (state.remote_ts_fwd or 0) + fwdincr
  state.remote_ts_bwd = (state.remote_ts_bwd or 0) + bwdincr

  -- Force update
  -- state.pattern:set(state.remote_ts_fwd .. state.remote_ts_bwd)
  -- state:update { force = true }
  require("flash.cache").cache = {}
  state:_update()
end
M.ts_actions = {
  -- Extend right
  ["}"] = function(state) ts_shift(state, 1, 0) end,
  ["{"] = function(state) ts_shift(state, 0, 1) end,
  -- Extend left
  ["["] = function(state) ts_shift(state, -1, 0) end,
  ["]"] = function(state) ts_shift(state, 0, -1) end,
  -- Move
  [")"] = function(state) ts_shift(state, 1, -1) end,
  ["("] = function(state) ts_shift(state, -1, 1) end,
  -- TODO: Expand/Shrink
  ["<tab>"] = function(state) state:jump { match = current, forward = false } end,
  ["<S-tab>"] = function(state) state:jump { forward = true, match = current } end,
}
-- TODO: this needs a lot of work
M.remote_sel = function(win, state, opts)
  local pat = state.pattern.pattern
  state.pattern:set(#pat == 1 and pat or pat:sub(1, -2))
  local search = require("flash.search").new(win, state)
  local matches = {}
  vim.print(state.pattern)
  local starts = search:get(opts)
  for i, m in ipairs(starts) do
    if #pat <= 1 then
      matches[#matches + 1] = m
    else
      state.pattern:set(pat:sub(-1))
      vim.print(state.pattern)
      for _, n in
        ipairs(search:get {
          from = m.pos,
          to = starts[i + 1] and starts[i + 1].pos,
        })
      do
        -- n.end_pos = n.pos
        n.pos = m.pos
        n.highlight = false
        matches[#matches + 1] = n
      end
    end
  end
  state.pattern:set(pat)
  return matches
end

M.move_by_ts = function()
  local iter = {
    next = function() return true end,
    prev = function() return true end,
    state = {},
  }
end

M.select_operatorfunc = function()
  local start, finish = vim.api.nvim_buf_get_mark(0, "["), vim.api.nvim_buf_get_mark(0, "]")
  vim.api.nvim_win_set_cursor(0, start)
  vim.cmd "normal! v"
  vim.api.nvim_win_set_cursor(0, finish)
end
M.select_mapping = function()
  vim.go.operatorfunc = "v:lua.require'editor.nav.lib'.select_operatorfunc"
  return "g@"
end

local leap_select_state = { prev_input = nil }
function M.leap_select(kwargs)
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
    if ch == vim.keycode(repeat_key) then
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

return M
