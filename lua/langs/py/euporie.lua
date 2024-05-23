local M = {}
local meta_M = {}
M = setmetatable(M, meta_M)

local get_alt_win = function(term, cmd)
  -- TODO: get existing alternate window automatically
  if not term then
    return require("kitty.terms").use_terminal("window", {
      launch_cmd = cmd,
      bracketed_paste = true,
      send_text_prefix = "\\cc",
      send_text_suffix = require("kitty.utils").unkeycode "<c-cr>",
    })
  else
    term:send(table.concat(cmd, " "))
    return term
  end
end

local function get_jupyter_kernel(bufnr)
  return (vim.fn.stdpath "cache") .. "/" .. vim.fn.fnamemodify(vim.v.servername, ":t") .. bufnr .. ".json"
end

local function get_euporie_cmd(bufnr, cmd)
  local kern = get_jupyter_kernel(bufnr)
  local ret = {
    cmd = { "euporie", cmd, "--connection-file", kern },
    kern = kern,
  }
  if cmd == "notebook" then ret.cmd[#ret.cmd + 1] = vim.api.nvim_buf_get_name(bufnr) end
  return ret
end

local function start_euporie(bufnr, term, type)
  local eu = get_euporie_cmd(bufnr, type)
  eu.term = get_alt_win(term, eu.cmd)
  vim.b[bufnr].euporie_console = eu
  -- TODO: Problem is the jupyter kernel doesn't start immediately
  -- how to schedule? just let user run EuporieAttach? or watch file
  -- vim.defer_fn(function() vim.cmd.JupyterAttach(eu.kern) end, 2000)
  vim.api.nvim_create_user_command(
    "EuporieAttach",
    function() require("jupyter_kernel").attach { args = eu.kern } end,
    {}
  )
  local w = vim.uv.new_fs_event()
  if w then
    local function on_change(err, fname, status)
      vim.cmd.EuporieAttach()
      -- Debounce: stop/start.
      w:stop()
    end
    local function watch_file(fname) end
    w:start(eu.kern, {}, vim.schedule_wrap(on_change))
  end

  return eu
end

M.euporie_notebook = function(term)
  local nn = require "notebook-navigator"
  local bufnr = vim.api.nvim_get_current_buf()
  local eu = start_euporie(bufnr, term, "notebook")

  local map = function(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("keep", opts or {}, { buffer = bufnr, silent = true }))
  end
  local run_cell = function(on)
    -- TODO: force synchronize?
    term:send_key("ctrl+shift+f8", nil, on)
  end

  map("n", "<C-Enter>", function() run_cell() end)
  map("n", "<S-Enter>", function()
    run_cell()
    nn.move_cell "d"
  end)
  map("n", "<C-S-Enter>", function()
    -- TODO: run this and all rest
    local on_exit
    -- FIXME: this doesn't make sense, need to wait for jupyter to finish executing probably?
    on_exit = function(out)
      if out.code ~= 0 then return end
      local cur = vim.api.nvim_win_get_cursor(0)
      nn.move_cell "d"
      local nxt = vim.api.nvim_win_get_cursor(0)
      if cur[1] == nxt[1] and cur[2] == nxt[2] then return end
      run_cell(on_exit)
    end
    run_cell(on_exit)
  end)
  map("n", "<M-Enter>", function()
    run_cell()
    nn.add_cell_below()
  end)
  map("n", "<localleader>jc", function() term:send_key "alt+c" end, { desc = "Copy cell output to clipboard" })
  map("n", "<localleader>jq", function() term:send_raw "ii" end, { desc = "Interrupt Kernel" })
  map("n", "<localleader>jr", function() term:send_raw "rr" end, { desc = "Restart Kernel" })

  local grp = vim.api.nvim_create_augroup("euporie_notebook", {})
  local au = vim.api.nvim_create_autocmd
  au({ "CursorMoved", "CursorMovedI" }, {
    group = grp,
    buffer = bufnr,
    callback = function()
      -- TODO: synchronize the view
    end,
  })
  au("BufWritePost", {
    group = grp,
    buffer = bufnr,
    -- Reload
    callback = function() term:send_key "F5" end,
  })
  au("BufDelete", {
    group = grp,
    buffer = bufnr,
    -- Kill
    callback = function() term:signal_child "SIGINT" end,
  })
  require("notebook-navigator").config.repl_provider = function(start_line, end_line, repl_args, cell_marker)
    if Term then
      -- TODO: Iterate through cells matched by the line range and tell euporie to run it
    end
  end
end

M.euporie_console = function(term)
  local bufnr = vim.api.nvim_get_current_buf()
  local eu = start_euporie(bufnr, term, "console")
  require("notebook-navigator").config.repl_provider = function(start_line, end_line, repl_args, cell_marker)
    if Term then Term.send(vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)) end
  end
end

vim.api.nvim_create_user_command("EuporieConsole", function() M.euporie_console() end, {})
vim.api.nvim_create_user_command("EuporieNotebook", function() M.euporie_notebook() end, {})

return M
