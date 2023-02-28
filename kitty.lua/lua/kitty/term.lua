-- https://sw.kovidgoyal.net/kitty/remote-control/
local titles = {}
local Kitty = {
  listen_on = "unix:/tmp/kitty.nvim",
  default_launch_location = "tab",
  is_tab = false,
  launch_counter = 0,
  from_id = 1,
}
-- Use this to control the window that neovim is inside
function Kitty.current_win_listen_on()
  return vim.env.KITTY_LISTEN_ON
end
function Kitty.current_win_id()
  return vim.env.KITTY_WINDOW_ID
end
local unique_listen_on_counter = 0
function Kitty.port_from_pid(prefix)
  unique_listen_on_counter = unique_listen_on_counter + 1
  return (prefix or "unix:/tmp/kitty.nvim-") .. vim.fn.getpid() .. unique_listen_on_counter
end

function Kitty:close_on_leave(evt)
  -- FIXME: this doesn't work
  vim.api.nvim_create_autocmd(evt or "VimLeavePre", {
    callback = function()
      self:close_window(nil, nil, true)
    end,
  })
end
function Kitty:close(args_, on_exit, block)
  if block then
    return self:api_command_block("close-window", args_)
  else
    return self:api_command("close-window", args_, on_exit)
  end
end

local function custom_open(fn)
  return function(self, args, on_exit)
    if self.is_opened then
      return
    end

    fn(self, args, on_exit)

    self.is_opened = true
  end
end

Kitty.open = custom_open(function(self, args_, on_exit)
  local args = {
    -- "-o",
    -- "allow_remote_control=yes",
    "--listen-on",
    self.listen_on,
    "--title",
    self.title,
    unpack(args_ or {}),
  }

  vim.loop.spawn("kitty", {
    args = args,
  }, function(...)
    -- self.is_opened = false
    if on_exit then
      on_exit(...)
    end
  end)
end)

function Kitty:sub_window(o, where)
  if where == true then
    where = self.default_launch_location
  end
  where = where or self.default_launch_location

  o = o or {}
  if o.title == nil or o.title == self.title then
    o.title = self.title .. "-" .. self.launch_counter
    self.launch_counter = self.launch_counter + 1
  end
  o.attach_to_current_win = false
  o.from_id = nil
  o.is_opened = false

  local Sub = self:new(o)
  Sub.match_arg = "title:" .. Sub.title

  Sub.launch_args = { "--window-title", Sub.title, "--tab-title", Sub.title, "--type", where }

  Sub.open = custom_open(function(sub, args_, on_exit)
    sub.launch_args = vim.list_extend(sub.launch_args, args_ or {})

    -- TODO: get the window/tab id
    -- vim.notify("Unimplemented", vim.log.levels.ERROR, {})
    self:api_command("launch", sub.launch_args, on_exit)
  end)

  return Sub
end
function Kitty:launch(o, where, args_, on_exit)
  local Sub = self:sub_window(o, where)
  Sub:open(args_, on_exit)
  return Sub
end

--https://sw.kovidgoyal.net/kitty/remote-control/#cmdoption-kitty-launch-type
function Kitty:new_tab(o, args)
  return self:launch(o, "tab", args)
end
function Kitty:new_window(o, args)
  return self:launch(o, "window", args)
end
function Kitty:new_hsplit(o, args)
  args = args or {}
  args[#args + 1] = "--location=hsplit"
  return self:launch(o, "window", args)
end
function Kitty:new_vsplit(o, args)
  self:goto_layout "splits"
  args = args or {}
  args[#args + 1] = "--location=vsplit"
  return self:launch(o, "window", args)
end
function Kitty:new_os_window(o, args)
  return self:launch(o, "os-window", args)
end

function Kitty:goto_layout(name, on_exit)
  return self:api_command("goto_layout", { name })
end
function Kitty:api_kitten(args, on_exit)
  return self:api_command("kitten", args, on_exit)
end

function Kitty:focus(dont_wait, on_exit)
  local args = {}
  if dont_wait then
    args[1] = "--no-response"
  end
  return self:api_command(self.is_tab and "focus-tab" or "focus-window", args, on_exit)
end

function Kitty:detach(target, dont_wait, on_exit)
  local args = {}
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
  if dont_wait then
    args[#args + 1] = "--no-response"
  end
  return self:api_command("detach-window", args, on_exit)
end

-- function Kitty:send_file()
--   local filename = vim.fn.expand "%:p"
--   local payload = ""
--   local lines = vim.fn.readfile(filename)
--   for _, line in ipairs(lines) do
--     payload = payload .. line .. "\n"
--   end
--   self:send(payload)
-- end

function Kitty:send(text, on_exit)
  return self:api_command("send-text", { "--", text }, on_exit)
end
function Kitty:send_file(from_file, on_exit)
  return self:api_command("send-text", {
    "--from-file",
    (from_file or vim.api.nvim_buf_get_name(0)),
  }, on_exit)
end

local termcodes = vim.api.nvim_replace_termcodes
local function t(k)
  return termcodes(k, true, true, true)
end
function Kitty:send_key(text)
  print(text)
  vim.notify("Unimplemented", vim.log.levels.ERROR, {})
end

function Kitty:build_api_command(cmd, args_)
  local args = { "@", "--to", self.listen_on, cmd }
  self:append_match_args(args)
  args = vim.list_extend(args, args_ or {})
  return args
end
function Kitty:api_command(cmd, args_, on_exit)
  return vim.loop.spawn("kitty", {
    args = self:build_api_command(cmd, args_),
  }, on_exit)
end
function Kitty:api_command_block(cmd, args_)
  local cmdline = self:build_api_command(cmd, args_)
  cmdline = { "kitty", unpack(cmdline) }
  vim.fn.system(cmdline)
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
  if self.match_arg and self.match_arg ~= "" then
    vim.list_extend(args, { "--match", self.match_arg })
  end
  return args
end

function Kitty:universal()
  return self:new { match_arg = "" }
end
function Kitty:current_tab()
  return self:new { match_arg = "", is_tab = self.is_tab }
end

function Kitty:set_match_arg_from_id(id)
  self.match_arg = "id:" .. id
end

function Kitty:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  -- Setup stuff
  if o.listen_on == "unique_port" then
    o.listen_on = Kitty.port_from_pid()
  end
  if o.attach_to_current_win then
    o.listen_on = Kitty.current_win_listen_on()
    o.from_id = Kitty.current_win_id()
    o.open = function(...) end
  end
  if o.from_id then
    o:set_match_arg_from_id(o.from_id)
  end
  -- Warn about Duplicate window titles
  for _, v in ipairs(titles) do
    if o.title == v then
      vim.notify("Kitty Window title already used: " .. o.title, vim.log.WARN, {})
    end
  end
  titles[#titles + 1] = o.title

  return o
end

Kitty.setup_make = require("kitty.make").setup
Kitty.setup_repl = require("kitty.repl").setup

return Kitty
