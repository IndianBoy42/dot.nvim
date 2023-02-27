-- https://sw.kovidgoyal.net/kitty/remote-control/
local titles = {}
local cmd_prefixs = {}
local Kitty = {
  kitty_listen_on = "unix:/tmp/kitty.nvim",
  default_launch = "tab",
  is_tab = false,
}
local history = {}
-- this is a dev tool which helps reloading
-- the pluggin files
function Kitty:user_command(name, cb, opts)
  if self.cmd_prefix == nil then
    return
  end
  local create = vim.api.nvim_create_user_command
  if self.buflocal_cmds then
    create = vim.api.nvim_buf_create_user_command
  end
  create(self.cmd_prefix .. name, cb, vim.tbl_extend("keep", opts, { nargs = "*", range = "%" }))
end

function Kitty:repl()
  local _ft = self.ftype
  if _ft == nil then
    _ft = vim.bo.filetype
  end
  return self[_ft] or {}
end

function Kitty:create_open_cmds(cmds)
  for k, v in pairs(cmds) do
    if v == nil or (type(v) == table and v.cmd == nil) then
      goto continue
    end

    local desc = v
    if type(v) ~= "string" then
      if type(v.cmd) == "string" then
        desc = v.desc or v.cmd
      else
        desc = v.desc or k
      end
    end
    self:user_command(k, function()
      if type(v) == "string" then
        self:open(v)
      else
        self.ftype = v.ftype
        if type(v.cmd) == "string" then
          self:open(v.cmd)
        else
          self:open(v.cmd())
        end
      end
    end, { desc = "Open " .. desc .. " in " .. self.title })
    ::continue::
  end
end

function Kitty:create_send_cmds(cmds)
  for k, v in pairs(cmds) do
    if v == nil or (type(v) == table and v.fun == nil) then
      goto continue
    end
    if type(v) ~= "table" then
      v = {
        fun = v,
      }
    end
    local cmd_fn
    if type(v.fun) == "string" then
      cmd_fn = function(args)
        self[v.fun](self, args)
      end
    elseif type(v.fun) == "function" then
      cmd_fn = function(args)
        v.fun(self, args)
      end
    end
    if v.desc == nil then
      v.desc = k
    end
    self:user_command(k, cmd_fn, { desc = "Send " .. v.desc .. " to " .. self.title })
    ::continue::
  end
end

function Kitty:setup()
  -- Warn about Duplicate window titles
  for _, v in ipairs(titles) do
    if self.title == v then
      vim.notify("Kitty Window title already used: " .. self.title, vim.log.WARN, {})
    end
  end
  titles[#titles + 1] = self.title

  -- Warn about Duplicate window titles
  for _, v in ipairs(cmd_prefixs) do
    if self.cmd_prefix == v then
      vim.notify("Kitty Window title already used: " .. self.cmd_prefix, vim.log.ERR, {})
      self.cmd_prefix = nil
    end
  end
  cmd_prefixs[#cmd_prefixs + 1] = self.cmd_prefix

  if self.cmd_prefix ~= nil then
    if self.open_cmds ~= nil then
      self:create_open_cmds(self.open_cmds)
    end
    if self.send_cmds ~= nil then
      self:create_send_cmds(self.send_cmds)
    end
  end

  --TODO: VimLeave kill
  vim.api.nvim_create_autocmd("VimLeave", {
    callback = function()
      self:close_window()
    end,
  })
end

function Kitty:close(args_)
  local args = { "close-window" }
  self:append_match_args(args)
  vim.list_extend(args, args_)
  self:send_raw(args)
end

function Kitty:launch(type, o, args_)
  type = type or self.default_launch

  local Sub = self:new(o)
  if type == "tab" then
    Sub.is_tab = true
    Sub.match_arg = "tab_title:" .. Sub.title
  else
    Sub.match_arg = "window_title:" .. Sub.title
  end

  local args = { "launch", "--window-title", Sub.title, "--tab-title", Sub.title, "--type", type }
  self:append_match_args(args)
  vim.list_extend(args, args_)
  local handle, pid = self:send_raw(args)

  -- TODO: get the window/tab id
  vim.notify("Unimplemented", vim.log.levels.ERROR, {})
end
function Kitty:launch_tab(o, args_)
  self:launch("tab", o, args_)
end
function Kitty:launch_win(o, args_)
  self:launch("win", o, args_)
end

function Kitty:focus(dont_wait)
  local args = { "focus-window" }
  if self.is_tab then
    args = { "focus-tab" }
  end
  self:append_match_args(args)
  if dont_wait then
    args[#args + 1] = "--no-response"
  end
  self:send_raw(args)
end

function Kitty:detach(target, dont_wait)
  local args = { "detach-window" }
  if self.is_tab then
    args = { "detach-tab" }
    if target ~= nil and target ~= "new" then
      vim.list_extend(args, { "--target-tab", target })
    end
  else
    -- Pass 'new' for new tab
    if target ~= nil and target ~= "new-window" then
      vim.list_extend(args, { "--target-tab", target }) -- target should be SomeTab.match_arg
    end
  end
  self:append_match_args(args)
  if dont_wait then
    args[#args + 1] = "--no-response"
  end
  self:send_raw(args)
end

function Kitty:open(program)
  if self.is_opened then
    return
  end
  local args = {
    "-o",
    "allow_remote_control=yes",
    "--listen-on",
    self.kitty_listen_on,
    "--title",
    self.title,
  }
  if program ~= nil and program ~= "" then
    vim.list_extend(args, { "bash", "-c", program })
  end

  vim.loop.spawn("kitty", {
    args = args,
  }, function()
    -- self.is_opened = false
  end)
  self.is_opened = true
end

function Kitty:cell_delimiter()
  return self:repl().comment_character .. " %%"
end
-- function Kitty:highlight_cell_delimiter(color)
--   vim.cmd([[highlight KittyCellDelimiterColor guifg=]] .. color .. [[ guibg=]] .. color)
--   vim.cmd [[sign define KittyCellDelimiters linehl=KittyCellDelimiterColor text=> ]]
--   vim.cmd("sign unplace * group=KittyCellDelimiters buffer=" .. vim.fn.bufnr())
--   local lines = vim.fn.getline(0, "$")
--   for line_number, line in pairs(lines) do
--     if line:find(self:cell_delimiter()) then
--       vim.cmd(
--         "sign place 1 line="
--           .. line_number
--           .. " group=KittyCellDelimiters name=KittyCellDelimiters buffer="
--           .. vim.fn.bufnr()
--       )
--     end
--   end
-- end
function Kitty:send_cell()
  local opts = {}
  opts.line1 = vim.fn.search(self:cell_delimiter(), "bcnW")
  opts.line2 = vim.fn.search(self:cell_delimiter(), "nW")
  -- line after delimiter or top of file
  opts.line1 = opts.line1 and opts.line1 + 1 or 1
  -- line before delimiter or bottom of file
  opts.line2 = opts.line2 and opts.line2 - 1 or vim.fn.line "$"
  if opts.line1 <= opts.line2 then
    self:send_range(opts)
  else
    self:send_file()
  end
end

function Kitty:send_range(opts)
  local startline = opts.line1
  local endline = opts.line2
  -- save registers for restore
  local rv = vim.fn.getreg '"'
  local rt = vim.fn.getregtype '"'
  -- yank range silently
  vim.cmd("silent! " .. startline .. "," .. endline .. "yank")
  local payload = vim.fn.getreg '"'
  -- restore
  self:send(payload)
  vim.fn.setreg('"', rv, rt)
end

function Kitty:send_current_line()
  local payload = vim.api.nvim_get_current_line()
  local prefix = self:repl().line_delimiter_start
  local suffix = self:repl().line_delimiter_end
  self:send(prefix .. payload .. suffix .. "\n")
end

function Kitty:send_current_word()
  vim.cmd "normal! yiw"
  self:send(vim.fn.getreg '@"' .. "\n")
end

function Kitty:send_file(_, dontsave)
  local filename = vim.fn.expand "%:p"
  local payload = ""
  local lines = vim.fn.readfile(filename)
  for _, line in ipairs(lines) do
    payload = payload .. line .. "\n"
  end
  if not dontsave then
    history[#history + 1] = { self.send_file, "file: " .. filename }
  end
  self:send(payload)
end

function Kitty:send(text, dontsave)
  if not dontsave then
    history[#history + 1] = { self.send, text }
  end
  local args = { "send-text" }
  self:append_match_args(args)
  vim.list_extend(args, { "--", text })
  self:send_raw(args)
end

local termcodes = vim.api.nvim_replace_termcodes
local function t(k)
  return termcodes(k, true, true, true)
end
function Kitty:send_key(text)
  vim.notify("Unimplemented", vim.log.levels.ERROR, {})
end

function Kitty:resend(i)
  i = i or #history
  local fn, text = unpack(history[i])
  fn(text, true)
end

function Kitty:send_raw(args, on_exit)
  local args_ = { "@", "--to=" .. self.kitty_listen_on, unpack(args) }
  return vim.loop.spawn("kitty", {
    args = args_,
  }, on_exit)
end

function Kitty:get_selection()
  local s_start = vim.fn.getpos "'<"
  local s_end = vim.fn.getpos "'>"
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, "\n")
end
function Kitty:send_selection()
  self:send(self:get_selection())
end

function Kitty:append_match_args(args)
  if self.match_arg then
    vim.list_extend(args, { "--match", self.match_arg })
  end
  return args
end

function Kitty:last_cmd(i)
  i = i or 0
  return history[#history - i] or { function() end, "" }
end

function Kitty:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

return Kitty
