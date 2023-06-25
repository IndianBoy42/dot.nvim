local M = {}
local terms = setmetatable({}, {
  __index = function(t, k)
    if k == 0 then k = vim.api.nvim_get_current_win() end
    if not t[k] then
      -- if t.global == nil then M.kitty_attach() end -- TODO: this is async so this wont work
      t[k] = t.global
    end
    return t[k]
  end,
  __newindex = function(t, k, v)
    if k == 0 then k = vim.api.nvim_get_current_win() end
    rawset(t, k, v)
  end,
})

local cmd = vim.api.nvim_create_user_command
local map = vim.keymap.set

local function get_terminal(args)
  local k = 0
  if args.fargs and #args.fargs > 0 then
    if args:sub(1, 1) == ":" then
      k = args.fargs[0]:sub(2)

      for i = 2, #args.fargs do
        args.fargs[i - 1] = args.fargs[i]
      end
    end
  end
  return k
end
local uuid = 999
local function get_uuid()
  uuid = uuid + 1
  return uuid
end
local function new_terminal(cmd, opts, args)
  opts = opts or {}
  local k = get_terminal(args)
  local cmd = args.fargs
  if not cmd or #cmd == 0 then
    cmd = {} -- TODO: something
  end

  terms[k] = require("kitty.current_win")[cmd](args, cmd)
  terms[get_uuid()] = terms[k]
end

function M.kitty_attach(create_new_win)
  create_new_win = create_new_win or vim.g.kitty_from_current_win or "os-window"

  require("kitty").setup({
    create_new_win = create_new_win,
    target_providers = {
      function(T) T.helloworld = { desc = "Hello world", cmd = "echo hello world" } end,
      "just",
      "cargo",
    },
  }, function(K)
    terms.global = K
    K.setup_make()

    require("rust-tools").config.options.tools.executor = K.rust_tools_executor()
  end)

  return require("kitty").instance
end

M.setup = function()
  cmd("KittyAttach", function(args)
    local create_new_win = nil
    if args.fargs and #args.fargs > 0 then create_new_win = args.fargs[0] end

    kitty_attach(create_new_win)
  end, {})

  cmd("KittyTab", function(args) new_terminal("new_tab", {}, args) end, { nargs = "*" })
  cmd("KittyWindow", function(args) new_terminal("new_window", {}, args) end, { nargs = "*" })
  cmd("KittyNew", function(args) new_terminal("new_os_window", {}, args) end, { nargs = "*" })
  cmd("Kitty", function(args)
    local k = get_terminal(args)

    if args.fargs and #args.fargs > 0 then
      terms[k]:send(args.fargs .. "\n")
    else
      -- TODO:
      terms[k]:focus()
    end

    terms[get_uuid()] = terms[k]
  end, {
    nargs = "*",
    -- preview = function(opts, ns, buf)
    --   -- TODO: livestream to kitty
    -- end,
  })

  map("n", "<leader>mk", function() terms[0]:run() end, { desc = "Kitty Run" })
  map("n", "<leader>mm", function() terms[0]:make() end, { desc = "Kitty Make" })
  map("n", "<leader>m<CR>", function() terms[0]:make "last" end, { desc = "Kitty ReMake" })
  map("n", "yr", function() terms[0]:send { selection = vim.api.nvim_get_mode() } end, { desc = "Kitty Send" })
  map("x", "R", function() terms[0]:send { selection = vim.api.nvim_get_mode() } end, { desc = "Kitty Send" })
  map("n", "yrr", function() terms[0]:send() end, { desc = "Kitty Send Line" })
  -- vim.keymap.set("n", "<leader>mK", KT.run, { desc = "Kitty Run" })
  -- vim.keymap.set("n", "", require("kitty").send_cell, { buffer = 0 })
end

M = setmetatable(M, {
  __index = function(t, k)
    local term = terms[0]
    if type(term[k]) == "function" then
      return function(...) return term[k](term, ...) end
    else
      return term[k]
    end
  end,
  __call = function() return M.kitty_attach() end,
})

return M
