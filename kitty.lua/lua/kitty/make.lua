-- TODO: build system/command runner
local Make = {}

local function nop(...)
  return ...
end

function Make.find_build_file(pattern)
  vim.notify("TODO: search cwd/lsp_root_dir for " .. pattern, vim.log.levels.WARN)
end

-- Append commands to T.targets
-- name = { cmd = '', desc = ''}
Make.builtin_target_providers = {
  ["make"] = function(T, _)
    T.make = {
      cmd = "make",
      desc = "Run Makefile",
      priority = 100,
    }
    T.default = T.make
  end,
  ["just"] = function(T, _)
    T.just_default = {
      cmd = "just",
      desc = "Run Justfile",
      priority = 100,
    }
    T.default = T.just
  end,
  ["cargo"] = function(T)
    T.check = {
      cmd = "cargo check",
      desc = "Check Cargo Project",
      priority = 100,
    }
    T.build = {
      cmd = "cargo build",
      desc = "Build Cargo Project",
      priority = 99,
    }
    T.test = {
      cmd = "cargo test",
      desc = "Test Cargo Project",
      priority = 98,
    }
    T.run = { cmd = "cargo run", desc = "Run Cargo Project", priority = 97 }
    T.default = T.check
  end,
}

function Make.setup(T)
  -- Options, state variables, etc
  T.cmd_history = {}
  T.targets = {
    -- default = T.user_default,
    default = { desc = "Default", cmd = "echo Hello World" },
    last_manual = { desc = "Last Run Command", cmd = "" },
    last = { desc = "Last Run Task", cmd = "" },
  }
  T.select = T.select or vim.ui.select
  T.input = T.input or vim.ui.input
  T.task_choose_format = T.task_choose_format
    or function(i, _)
      local name, target = unpack(i)
      return name .. ": " .. target.desc
    end

  -- Functions
  function T:target_list()
    -- TODO: this is kinda inefficient... luajit go brrrrr
    local M = {}
    for k, v in pairs(T.targets) do
      M[#M + 1] = { k, v }
    end
    table.sort(M, function(a, b)
      if a[1] == "default" then
        return true
      elseif b[1] == "default" then
        return false
      end

      if a[2].priority or b[2].priority then
        return (a[2].priority or 0) >= (b[2].priority or 0)
      end

      return a[1] < b[1]
    end)
    return M
  end
  function T:call_or_input(arg, fun, input_opts, from_input)
    if arg == nil then
      local opts = input_opts
      if type(input_opts) == "function" then
        opts = input_opts(T)
      end

      if type(fun) == "string" then
        fun = T[fun]
      end

      from_input = from_input or nop
      T.input(opts, function(i)
        fun(T, from_input(i))
      end)
    else
      fun(arg)
    end
  end
  function T:call_or_select(arg, fun, choices, from_input)
    if arg == nil then
      local opts = choices
      if type(choices) == "function" then
        opts = choices(T)
      end

      T.select(opts[1], opts[2], function(i)
        from_input = from_input or nop
        T[fun](T, from_input(i))
      end)
    else
      fun(arg)
    end
  end
  function T:_add_target_provider(provider)
    local f = type(provider) == "function" and provider or Make.builtin_target_providers[provider]
    f(T.targets, T)
  end
  function T:add_target_provider(provider, force)
    local providers = vim.tbl_keys(Make.builtin_target_providers)
    -- TODO: filter by really available providers?
    if force then
      print "unimplemented"
    end
    T:call_or_select(provider, "_add_target_provider", { providers, { prompt = "Add from Builtin Providers" } })
  end
  function T:last_cmd()
    return T.cmd_history[#T.cmd_history]
  end
  function T:_run(cmd)
    T.cmd_history[#T.cmd_history + 1] = cmd
    T.targets.last_manual.cmd = cmd
    if type(cmd) == "string" then
      T:send(cmd .. "\r")
    elseif type(cmd) == "function" then
      T:send(cmd(T) .. "\r")
    end
    -- TODO: can notify on finish?
  end
  function T:run(cmd, opts)
    T:call_or_input(
      cmd,
      "_run",
      vim.tbl_extend("keep", opts or {}, {
        prompt = "Run in " .. T.title,
        default = T:last_cmd(),
      })
    )
    -- if cmd == nil then
    --   vim.ui.input(
    --     vim.tbl_extend("keep", opts or {}, {
    --       prompt = "Run in " .. T.title,
    --       default = T:last_cmd(),
    --     }),
    --     function(i)
    --       T:_run(i)
    --     end
    --   )
    -- else
    --   T:_run(cmd)
    -- end
  end
  function T:rerun()
    T:_run(T:last_cmd())
  end
  function T:kill_ongoing()
    -- 0x03 is ^C
    T:send_raw "\x03"
  end
  function T:_choose_default(target_name)
    T.targets.default = T.targets[target_name]
  end
  function T:choose_default(target_name)
    T:call_or_select(target_name, "_choose_default", {
      T:target_list(),

      {
        prompt = "Choose default for " .. T.title,
        format_item = T.task_choose_format,
      },
    })
    -- if target_name == nil then
    --   vim.ui.select(T.targets, {
    --     prompt = "Choose default for " .. T.title,
    --     format_item = function(i, _)
    --       return i.name
    --     end,
    --   }, function(i)
    --     T:_choose_default(i)
    --   end)
    -- else
    --   T:_choose_default(target_name)
    -- end
  end
  function T:_make(target)
    if type(target) == "string" then
      target = T.targets[target]
    end
    local cmd = target.cmd or target[2].cmd
    T.targets.last.cmd = cmd
    T:_run(cmd)
  end
  function T:make(target)
    T:call_or_select(target, "_make", {
      T:target_list(),

      {
        prompt = "Run target in " .. T.title,
        format_item = T.task_choose_format,
      },
    }, function(i)
      return i or "default"
    end)
  end
  function T:make_default()
    T:make "default"
  end
  function T:make_last()
    T:make "last"
  end
  function T:_add_target(name, target)
    T.targets[name] = type(target) == "table" and target or { cmd = target, desc = name }
  end
  function T:add_target(name, target)
    function T:_add_target2(target_)
      T:call_or_input(name, "_add_target", { prompt = "Name: ", default = "default" }, function(name)
        return name, target_
      end)
    end
    T:call_or_input(target, "_add_target", {
      prompt = "Cmd: ",
    })
    -- T.targets[name] = type(target) == "table" and target or { cmd = target, desc = name }
  end
  function T:_target_from_last_run(name)
    T.targets[name] = {
      name = name,
      desc = name,
      cmd = T.targets.last_manual.cmd,
    }
  end
  function T:target_from_last_run(name)
    T:call_or_input(name, "_add_target", { prompt = "Name" })
  end


  if T.target_providers ~= nil then
    if type(T.target_providers) ~= "table" then
      T.target_providers = { T.target_providers }
    end
    for _, v in ipairs(T.target_providers) do
      T:_add_target_provider(v)
    end
  end
end

return Make
