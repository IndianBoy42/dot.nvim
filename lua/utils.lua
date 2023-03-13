local M = {}

local feedkeys = vim.api.nvim_feedkeys
local termcodes = vim.api.nvim_replace_termcodes
local function t(k)
  return termcodes(k, true, true, true)
end

function M.else_meta(tbl, fallback)
  return setmetatable(tbl, {
    -- Return always true
    __index = function(tbl, key)
      return fallback
    end,
  })
end

function M.else_true(tbl)
  return M.else_meta(tbl, true)
end

function M.else_false(tbl)
  return M.else_meta(tbl, false)
end

local function dump(...)
  local objects, v = {}, nil
  for i = 1, select("#", ...) do
    v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  print(table.concat(objects, "\n"))
  return ...
end
M.dump = dump

function M.dump_text(...)
  local objects, v = {}, nil
  for i = 1, select("#", ...) do
    v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  local lines = vim.split(table.concat(objects, "\n"), "\n")
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  vim.fn.append(lnum, lines)
  return ...
end

vim.api.nvim_create_user_command("Lua", function(opts)
  dump(opts.args)
end, { nargs = "+" })

function M.check_lsp_client_active(name)
  local clients = vim.lsp.get_active_clients()
  for _, client in pairs(clients) do
    if client.name == name then
      return true
    end
  end
  return false
end

-- TODO: replace this with new interface
function M.define_augroups(definitions) -- {{{1
  -- dump("DEPRECATED", debug.getinfo(2))
  -- Create autocommand groups based on the passed definitions
  --
  -- The key will be the name of the group, and each definition
  -- within the group should have:
  --    1. Trigger
  --    2. Pattern
  --    3. Text
  -- just like how they would normally be defined from Vim itself
  for group_name, definition in pairs(definitions) do
    local augrp = vim.api.nvim_create_augroup("name", {})
    -- vim.cmd("augroup " .. group_name)
    -- vim.cmd "autocmd!"

    for _, def in pairs(definition) do
      vim.api.nvim_create_autocmd(def[1], {
        pattern = def[2],
        command = def[3],
      })
      -- local command = table.concat(vim.tbl_flatten { "autocmd", def }, " ")
      -- vim.cmd(command)
    end

    -- vim.cmd "augroup END"
  end
end

-- Enable nosplit search in vim
local to_cmd_counter = 0
function M.to_cmd(luafunction, args)
  dump(to_cmd_counter, "DEPRECATED", debug.getinfo(2).source)
  vim.notify "to_cmd is deprecated"
end

function M.quickfix_toggle()
  if vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), "v:val.quickfix")) then
    vim.cmd "copen"
  else
    vim.cmd "cclose"
  end
end

function M.conceal_toggle(n)
  if n == nil then
    n = 2
  end
  if vim.opt_local.conceallevel._value == 0 then
    vim.opt_local.conceallevel = n
  else
    vim.opt_local.conceallevel = 0
  end
end

-- TODO: convert to lua
vim.cmd [[
augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* call OpenQuickFixList()
augroup END

function OpenQuickFixList()
    vert cwindow
    wincmd p
    wincmd =
endfunction
]]

function M.operatorfunc_helper_select(lines)
  local start_row, start_col = unpack(vim.api.nvim_buf_get_mark(0, "["))
  local end_row, end_col = unpack(vim.api.nvim_buf_get_mark(0, "]"))

  vim.fn.setpos(".", { 0, start_row, start_col + 1, 0 })
  if lines then
    vim.cmd "normal! V"
  else
    vim.cmd "normal! v"
  end
  if end_col == 1 then
    vim.fn.setpos(".", { 0, end_row - 1, -1, 0 })
  else
    vim.fn.setpos(".", { 0, end_row, end_col + 1, 0 })
  end
end

function M.post_operatorfunc(old_func)
  vim.go.operatorfunc = old_func
  _G.op_func_change_all_operator = nil
end

_G.lv_utils_operatorfuncs = {}
-- wrapper for making operators easily
function M.operatorfunc_scaffold(name, operatorfunc)
  local old_func = vim.go.operatorfunc

  _G.lv_utils_operatorfuncs[name] = function()
    operatorfunc()

    M.post_operatorfunc(old_func)
  end

  return function()
    vim.go.operatorfunc = "v:lua.lv_utils_operatorfuncs." .. name
    feedkeys("g@", "n", false)
  end
end

-- keys linewise
function M.operatorfuncV_keys(name, verbkeys)
  return M.operatorfunc_scaffold(name, function()
    M.operatorfunc_helper_select(true)
    feedkeys(t(verbkeys), "m", false)
  end)
end

-- keys charwise
function M.operatorfunc_keys(name, verbkeys)
  return M.operatorfunc_scaffold(name, function()
    M.operatorfunc_helper_select(false)
    feedkeys(t(verbkeys), "m", false)
  end)
end

-- cmd linewise
function M.operatorfunc_Vcmd(name, verbkeys)
  return M.operatorfunc_scaffold(name, function()
    M.operatorfunc_helper_select(true)
    vim.cmd(verbkeys)
  end)
end

-- cmd charwise
function M.operatorfunc_cmd(name, verbkeys)
  return M.operatorfunc_scaffold(name, function()
    M.operatorfunc_helper_select(false)
    vim.cmd(verbkeys)
  end)
end

-- the font used in graphical neovim applications
function M.set_guifont(size, font)
  if font == nil then
    font = vim.g.guifontface
  end
  vim.opt.guifont = font .. ":h" .. size
  vim.g.guifontface = font
  vim.g.guifontsize = size
end

function M.mod_guifont(diff, font)
  local size = vim.g.guifontsize
  M.set_guifont(size + diff, font)
  print(vim.opt.guifont._value)
end

vim.cmd [[
  command! FontUp lua require("utils").mod_guifont(1)
  command! FontDown lua require("utils").mod_guifont(-1)
]]

-- TODO: Could use select mode for this like luasnip?

function M.syn_group()
  local s = vim.fn.synID(vim.fn.line ".", vim.fn.col ".", 1)
  print(vim.fn.synIDattr(s, "name") .. " -> " .. vim.fn.synIDattr(vim.fn.synIDtrans(s), "name"))
end

local function luafn(prefix)
  return setmetatable({}, {
    __index = function(tbl, key)
      return "<cmd>lua " .. prefix .. "." .. key .. "()<cr>"
    end,
    __call = function(tbl, key)
      -- dump("DEPRECATED", debug.getinfo(2).source, prefix, key)
      return "<cmd>lua " .. prefix .. "." .. key .. "<cr>"
    end,
  })
end
M.cmd = setmetatable({
  lua = function(arg)
    return "<cmd>lua " .. arg .. "<cr>"
  end,
  call = function(arg)
    return "<cmd>call " .. arg .. "<cr>"
  end,
  from = M.to_cmd,
  op = M.operatorfunc_scaffold,
  require = function(name)
    return luafn("require'" .. name .. "'")
  end,
  lsp = luafn "vim.lsp.buf",
  -- diag = luafn "vim.lsp.diagnostic",
  diag = luafn "vim.diagnostic",
  telescopes = luafn "require'telescopes'",
}, {
  __call = function(tbl, arg)
    return "<cmd>" .. arg .. "<cr>"
  end,
})

M.fn = setmetatable({}, {
  __index = function(_, key)
    return setmetatable({ key }, {
      __index = function(tbl, key2)
        return M.fn[tbl[1] .. "#" .. key2]
      end,
      __call = function(tbl, ...)
        vim.fn[tbl[1]](...)
      end,
    })
  end,
})

-- Meta af autocmd function
local function make_aucmd(trigger, trigargs, action)
  vim.cmd("autocmd " .. trigger .. " " .. trigargs .. " " .. action)
end
local function make_augrp(tbl, cmds)
  local grp = tbl[1]
  vim.cmd("augroup " .. grp)
  vim.cmd "autocmd!"
  for trigger, cmd in pairs(cmds) do
    if type(trigger) == "number" then
      if #cmd == 2 then
        trigger = cmd[1]
        local action = cmd[2]
        make_aucmd(trigger, "*", action)
      else
        trigger = cmd[1]
        local trigargs = cmd[2]
        local action = cmd[3]
        make_aucmd(trigger, trigargs, action)
      end
    else
      if type(cmd) == table then
        local trigargs = cmd[1]
        local action = cmd[2]
        make_aucmd(trigger, trigargs, action)
      else
        make_aucmd(trigger, "*", cmd)
      end
    end
  end
  vim.cmd "augroup END"
end
local augroup_meta = {
  __call = make_augrp,
}
local au
au = setmetatable({}, {
  __call = function(_, arg)
    dump("DEPRECATED", debug.getinfo(2))
    if type(arg) == "string" then
      return setmetatable({ arg }, augroup_meta)
    else
      for group, cmds in pairs(arg) do
        make_augrp({ group }, cmds)
      end
    end
  end,
  __newindex = function(_, trigger, action)
    dump("DEPRECATED", debug.getinfo(2))
    make_aucmd(trigger, "*", action)
  end,
  __index = function(_, trigger)
    dump("DEPRECATED", debug.getinfo(2))
    return setmetatable({}, {
      __newindex = function(_, trigargs, action)
        make_aucmd(trigger, trigargs, action)
      end,
    })
  end,
})
M.au = au

-- Meta af keybinding function
-- TODO: change to keymap.set()
local mapper_meta = nil
local function mapper_call(tbl, mode)
  if mode == nil then
    mode = tbl[2]
  end
  return function(args)
    if args == nil then
      args = tbl[1]
    end
    return setmetatable({ args, mode }, mapper_meta)
  end
end
local function mapper_index(tbl, flag)
  if #flag == 1 then
    return setmetatable({ tbl[1], flag }, mapper_meta)
  else
    return setmetatable({
      vim.tbl_extend("force", { [flag] = true }, tbl[1]),
      tbl[2],
    }, mapper_meta)
  end
end
mapper_meta = {
  __index = mapper_index,
  __newindex = vim.keymap.set,
  __call = mapper_call,
}
local mapper = setmetatable({ {}, "n" }, mapper_meta)
M.map = mapper

-- TODO: change this to use `vim.on_key`
function M.timeout_helper(timeout, callback)
  local timerperiod = 20
  timeout = (timeout or 1000) / timerperiod
  local timer
  local counter = 0
  local latch = false -- Make sure we don't repeatedly call the callback
  local function cb()
    if not latch then
      counter = 1 + counter
      if counter > timeout then
        latch = true
        -- CursorHold(timeout) complete
        callback()
      end
    end
  end
  --  Call this function from CursorMoved autocmd
  return {
    disable = function()
      counter = 0
      latch = true -- Disable the counter in Insert Mode
    end,
    reenable = function()
      counter = 0
      latch = false -- Reenable the counter in Normal Mode
    end,
    reset = function()
      if timer == nil then
        timer = vim.loop.new_timer()
        timer:start(0, timerperiod, vim.schedule_wrap(cb))
      end
      -- Reset counter on CursorMoved
      counter = 0
      latch = false
    end,
  }
end

M.hold_jumplist = (function()
  -- local setmark = vim.api.nvim_buf_set_mark
  -- local getcurpos = vim.api.nvim_win_get_cursor
  return M.timeout_helper(1000, function()
    -- local row, col = unpack(getcurpos(0))
    -- setmark(0, "'", row, col)
    if vim.api.nvim_get_mode().mode == "n" then
      vim.cmd "normal! m'"
    end
    -- feedkeys("m'", "n", true)
  end)
end)()
M.hold_jumplist_aucmd = {
  { "InsertEnter,CmdlineEnter", "*", "lua require'utils'.hold_jumplist.disable()" },
  { "InsertLeave,CmdlineLeave", "*", "lua require'utils'.hold_jumplist.reenable()" },
  { "CursorMoved", "*", "lua require'utils'.hold_jumplist.reset()" },
}

local function augroup_helper(tbl, name, clear)
  local grp = {
    id = vim.api.nvim_create_augroup(name, { clear = clear }),
  }
  local wrapper
  wrapper = function(event, opts, pattern)
    if "function" == type(opts) then
      vim.api.nvim_create_autocmd(event, { group = name, pattern = pattern, callback = opts })
    elseif "string" == type(opts) then
      vim.api.nvim_create_autocmd(event, { group = name, pattern = pattern, command = opts })
    else
      vim.api.nvim_create_autocmd(event, vim.tbl_extend("keep", { group = name, pattern = pattern }, opts))
    end
  end
  -- return function(opts)
  --   vim.api.nvim_create_autocmd(opts.event, opts)
  -- end
  return setmetatable(grp, {
    __index = function(tbl, event)
      return setmetatable({}, {
        __index = function(tbl, pat)
          return function(opts)
            wrapper(event, opts)
            return tbl
          end
        end,
        __newindex = function(tbl, pat, opts)
          wrapper(event, opts)
          return tbl
        end,
        __call = function(tbl, opts)
          wrapper(event, opts)
          return tbl
        end,
      })
    end,
    __newindex = function(tbl, event, opts)
      wrapper(event, opts)
      return tbl
    end,
  })
end
M.augroup = setmetatable({}, {
  __index = augroup_helper,
  __call = augroup_helper,
})

-- TODO: merge repeated 'x'
M.delete_merge = (function()
  local repeat_set = M.fn["repeat"].set
  return M.timeout_helper(1000, function()
    repeat_set("\\<Plug>RepeatDeletes", vim.v.count)
  end)
end)()

local new_command_helper = function(idx, val, opts)
  if "string" == type(val) then
    vim.api.nvim_create_user_command(idx, val, opts or {})
  else
    local rhs = val.rhs
    val.rhs = nil
    vim.api.nvim_create_user_command(idx, rhs, val)
  end
end
M.new_command = setmetatable({}, {
  __newindex = function(tbl, idx, val)
    new_command_helper(idx, val)
  end,
  __index = function(tbl, idx)
    return function(val, opts)
      new_command_helper(idx, val, opts)
    end
  end,
})

M.on_very_lazy = function(cb)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      cb()
    end,
  })
end
M.have_plugin = function(name)
  return require("lazy.core.config").plugins[name] ~= nil
end

local mt = {}
function mt.__index(self, key)
  print("accessing key " .. key)
  local value = self.proxy[key]
  if type(value) == "table" then
    return setmetatable({ proxy = value }, mt)
  else
    return value
  end
end

function mt.__newindex(self, key, value)
  print("setting key " .. key .. " to value " .. tostring(value))
  self.proxy[key] = value
end

function M.setproxy(of)
  local new = { proxy = of }
  setmetatable(new, mt)
  return new
end

M.lsp = require "utils.lsp"

return M
