local M = {}
-- TODO: save this information to sessions?
local terms = {}

local function get_terminal(key, raw)
  if key == nil then return terms.global end
  if key == 0 then key = vim.api.nvim_get_current_win() end
  if terms[key] then return terms[key] end
  if type(key) == "number" then return terms.global end
end
M.get_term = get_terminal

local function get_terminal_name(args)
  local k = 0
  if args.fargs and #args.fargs > 0 then
    if args.fargs[1]:sub(1, 1) == ":" then
      k = args.fargs[1]:sub(2)

      for i = 1, #args.fargs do
        args.fargs[i] = args.fargs[i + 1]
      end
      args.args = table.concat(args.fargs, " ")
    end
  end
  if k == 0 then k = vim.api.nvim_get_current_win() end
  return k
end

local uuid = 0
local function get_uuid()
  uuid = uuid + 1
  return "_" .. uuid
end

local function new_terminal(where, opts, args, k)
  opts = opts or {}
  k = k or get_terminal_name(args)
  local cmd = args.fargs
  if not cmd or #cmd == 0 then
    cmd = {} -- TODO: something
  end

  opts.env_injections = opts.env_injections or {}
  if k then opts.env_injections.KITTY_NVIM_NAME = k end

  if cmd == nil then cmd = "launch" end
  terms[k] = require("kitty.current_win").launch(opts, where, cmd)
  terms[get_uuid()] = terms[k]
end

function M.kitty_attach(create_new_win)
  create_new_win = create_new_win or vim.g.kitty_from_current_win or "os-window"
  require("kitty.current_win").setup {
    default_launch_location = create_new_win,
    keep_open = true,
  }

  require("kitty").setup({
    create_new_win = create_new_win,
    default_launch_location = create_new_win,
    target_providers = {
      function(T) T.helloworld = { desc = "Hello world", cmd = "echo hello world" } end,
      "just",
      "cargo",
    },
  }, function(K, ls)
    terms.global = K.instance
    K.setup_make()

    -- TODO: keep polling to update the terms
    local Term = require "kitty.term"
    for id, t in pairs(ls:all_windows()) do
      terms["k" .. id] = Term:new {
        attach_to_current_win = id,
      }
      if t.env and t.env.KITTY_NVIM_NAME then terms[t.env.KITTY_NVIM_NAME] = terms["k" .. id] end
    end

    require("rust-tools").config.options.tools.executor = K.rust_tools_executor()
  end)

  return require("kitty").instance
end

M.setup = function(opts)
  local cmd = vim.api.nvim_create_user_command
  opts = opts or {}
  if opts.attach_now then
    M.kitty_attach()
  else
    cmd("KittyAttach", function(args)
      local create_new_win = nil
      if args.fargs and #args.fargs > 0 then create_new_win = args.fargs[0] end

      M.kitty_attach(create_new_win)
    end, {})
  end

  cmd("KittyTab", function(args) new_terminal("tab", {}, args) end, { nargs = "*" })
  cmd("KittyWindow", function(args) new_terminal("window", {}, args) end, { nargs = "*" })
  cmd("KittyNew", function(args) new_terminal("os-window", {}, args) end, { nargs = "*" })
  cmd("Kitty", function(args)
    if not terms.global then
      M.kitty_attach()
      return
    end
    local k = get_terminal_name(args)
    local t = get_terminal(k)
    if t then
      if args.fargs and #args.fargs > 0 then
        t:send(args.args .. "\n")
      else
        -- TODO:
        t:focus()
      end
    else
      new_terminal(true, {}, args, k)
    end
  end, { nargs = "*" })
  cmd("KittyClose", function(args)
    local k = get_terminal_name(args)
    local t = get_terminal(k)
    if t then
      pcall(function() t:close() end)
      terms[k] = nil
    end
  end, {
    nargs = "*",
    -- preview = function(opts, ns, buf)
    --   -- TODO: livestream to kitty
    -- end,
  })

  local map = vim.keymap.set
  map("n", "<leader>mk", function() get_terminal(0):run() end, { desc = "Kitty Run" })
  map("n", "<leader>mm", function() get_terminal(0):make() end, { desc = "Kitty Make" })
  map("n", "<leader>m<CR>", function() get_terminal(0):make "last" end, { desc = "Kitty ReMake" })
  map("n", "|", function() get_terminal(0):send { selection = vim.api.nvim_get_mode() } end, { desc = "Kitty Send" })
  map("x", "|", function() get_terminal(0):send { selection = vim.api.nvim_get_mode() } end, { desc = "Kitty Send" })
  map("n", "||", function() get_terminal(0):send() end, { desc = "Kitty Send Line" })
  -- vim.keymap.set("n", "<leader>mK", KT.run, { desc = "Kitty Run" })
  -- vim.keymap.set("n", "", require("kitty").send_cell, { buffer = 0 })
end

M = setmetatable(M, {
  __index = function(t, k)
    local term = get_terminal(0)
    if type(term[k]) == "function" then
      return function(...) return term[k](term, ...) end
    else
      return term[k]
    end
  end,
})

return M
