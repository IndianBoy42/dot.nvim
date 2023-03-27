local M = {}
local api = vim.api
local cmd = vim.cmd
local vfn = vim.fn
local lsp = vim.lsp
-- local diags = lsp.diagnostic
local diags = vim.diagnostic
-- TODO: reduce nested lookups for performance (\w+\.)?(\w+\.)?\w+\.\w+\(

-- Location information about the last message printed. The format is
-- `(did print, buffer number, line number)`.
local last_echo = { false, -1, -1 }
-- The timer used for displaying a diagnostic in the commandline.
local echo_timer = nil
-- The timer after which to display a diagnostic in the commandline.
local echo_timeout = 30
-- The highlight group to use for warning messages.
local warning_hlgroup = "WarningMsg"
-- The highlight group to use for error messages.
local error_hlgroup = "ErrorMsg"
-- If the first diagnostic line has fewer than this many characters, also add
-- the second line to it.
local short_line_limit = 20

-- Prints the first diagnostic for the current line.
-- Bind to CursorMoved to update live: cmd [[autocmd CursorMoved * :lua require("utils.lsp").echo_diagnostic()]]
function M.echo_diagnostic()
  if echo_timer then echo_timer:stop() end

  echo_timer = vim.defer_fn(function()
    local line = vfn.line "." - 1
    local bufnr = api.nvim_win_get_buf(0)

    if last_echo[1] and last_echo[2] == bufnr and last_echo[3] == line then return end

    local ldiags = diags.get_line_diagnostics(bufnr, line, { severity_limit = "Warning" })

    if #ldiags == 0 then
      -- If we previously echo'd a message, clear it out by echoing an empty
      -- message.
      if last_echo[1] then
        last_echo = { false, -1, -1 }

        vim.cmd 'echo ""'
      end

      return
    end

    last_echo = { true, bufnr, line }

    local diag = ldiags[1]
    local width = api.nvim_get_option "columns" - 15
    local lines = vim.split(diag.message, "\n")
    local message = lines[1]
    local lineindex = 2

    if width == 0 then
      if #lines > 1 and #message <= short_line_limit then message = message .. " " .. lines[lineindex] end
    else
      while #message < width do
        message = message .. " " .. lines[lineindex]
        lineindex = lineindex + 1
      end
    end

    if width > 0 and #message >= width then message = message:sub(1, width) .. "..." end

    local kind = "warning"
    local hlgroup = warning_hlgroup

    if diag.severity == lsp.protocol.DiagnosticSeverity.Error then
      kind = "error"
      hlgroup = error_hlgroup
    end

    local chunks = {
      { kind .. ": ", hlgroup },
      { message },
    }

    api.nvim_echo(chunks, false, {})
  end, echo_timeout)
end

function M.simple_echo_diagnostic()
  local line_diagnostics = diags.get_line_diagnostics()
  if vim.tbl_isempty(line_diagnostics) then
    cmd [[echo ""]]
    return
  end
  for _, diagnostic in ipairs(line_diagnostics) do
    cmd("echo '" .. diagnostic.message .. "'")
  end
end

local getmark = api.nvim_buf_get_mark
local feedkeys = api.nvim_feedkeys
local termcodes = vim.api.nvim_replace_termcodes
local function t(k) return termcodes(k, true, true, true) end

-- Format a range using LSP
function M.format_range_operator()
  local old_func = vim.go.operatorfunc
  _G.op_func_formatting = function()
    local start = getmark(0, "[")
    local finish = getmark(0, "]")
    lsp.buf.format {
      range = { start = start, ["end"] = finish },
    }
    vim.go.operatorfunc = old_func
    _G.op_func_formatting = nil
  end
  vim.go.operatorfunc = "v:lua.op_func_formatting"
  feedkeys("g@", "n", false)
end

-- TODO: Figure out the easiest way to implement this
function M.range_diagnostics(opts, buf_nr, start, finish)
  start = start or getmark(0, "[")
  finish = finish or getmark(0, "]")

  vim.notify("Unimplemented", vim.log.levels.ERROR)
end

-- Preview definitions and things
-- TODO: most buf_request could probably just use vim.lsp.buf + on_list_handler
local function preview_location_callback(_, result)
  if result == nil or vim.tbl_isempty(result) then return nil end
  lsp.util.preview_location(result[1], {
    border = O.lsp.border,
  })
end

function M.preview_location_at(name)
  return function()
    local params = lsp.util.make_position_params()
    return lsp.buf_request(0, "textDocument/" .. name, params, preview_location_callback)
  end
end

function M.view_location_split_callback(split_cmd)
  local util = vim.lsp.util
  local log = require "vim.lsp.log"

  -- note, this handler style is for neovim 0.5.1/0.6, if on 0.5, call with function(_, method, result)
  local function handler(_, result, ctx)
    if result == nil or vim.tbl_isempty(result) then
      local _ = log.info() and log.info(ctx.method, "No location found")
      return nil
    end

    if split_cmd then vim.cmd(split_cmd) end

    if vim.tbl_islist(result) then
      util.jump_to_location(result[1])

      if #result > 1 then
        util.set_qflist(util.locations_to_items(result))
        api.nvim_command "copen"
        api.nvim_command "wincmd p"
      end
    else
      util.jump_to_location(result)
    end
  end

  return handler
end

-- TODO: generalized view_location_in (existing windows, new tabs, etc)
function M.view_location_split(name, split_cmd)
  local cb = M.view_location_split_callback(split_cmd)
  return function()
    local params = lsp.util.make_position_params()
    return lsp.buf_request(0, "textDocument/" .. name, params, cb)
  end
end

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    if vim.b.lsp_diagnostics_hide == nil then vim.b.lsp_diagnostics_hide = false end
  end,
})
function M.toggle_diagnostics(b)
  if vim.diagnostic.is_disabled(b) then
    diags.enable(b or 0)
  else
    diags.disable(b or 0)
  end
end
function M.disable_diagnostic(b) diags.disable(b or 0) end
function M.enable_diagnostic(b) diags.enable(b or 0) end

-- TODO: Implement codeLens handlers
function M.show_codelens()
  -- cmd [[ autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh() ]]
  -- cmd(
  --   [[
  --   augroup lsp_codelens_refresh
  --     autocmd! * <buffer>
  --     autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()
  --   augroup END
  --   ]],
  --   false
  -- )

  local clients = vim.lsp.get_active_clients { bufnr = 0 }
  local codelens = lsp.codelens
  for k, v in pairs(clients) do
    codelens.display(nil, 0, k)
  end
end

function M.run_any_codelens(select)
  local codelens = lsp.codelens.get(0)
  select = select or vim.ui.select
  select(codelens, {
    prompt = "CodeLens actions:",
    format_item = function(item)
      local title = item.command.title .. ": "
      if item.command.arguments[1] then
        title = title .. item.command.arguments[1].kind .. " " .. item.command.arguments[1].label
      end

      return title
    end,
  }, function(selected)
    if not selected then return end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local start = selected.range.start
    vim.api.nvim_win_set_cursor(0, { start.line + 1, start.character })
    vim.lsp.codelens.run()
    vim.api.nvim_win_set_cursor(0, cursor)
  end)
end

-- Jump between diagnostics
-- TODO: clean up and remove the deprecate functions
local popup_diagnostics_opts = function()
  return {
    header = false,
    border = "rounded",
    scope = "line",
  }
end
function M.diag_line() diags.open_float(vim.tbl_deep_extend("keep", { scope = "line" }, popup_diagnostics_opts())) end
function M.diag_cursor() diags.open_float(vim.tbl_deep_extend("keep", { scope = "cursor" }, popup_diagnostics_opts())) end
function M.diag_buffer() diags.open_float(vim.tbl_deep_extend("keep", { scope = "buffer" }, popup_diagnostics_opts())) end

function M.get_highest_diag(ns, bufnr)
  local diag_list = vim.diagnostic.get(bufnr, { namespace = ns })
  local highest = vim.diagnostic.severity.HINT
  for _, diag in ipairs(diag_list) do
    local sev = diag.severity
    if sev < highest then highest = sev end
  end
  -- return highest
end
function M.diag_next(opts)
  diags.goto_next(vim.tbl_extend("keep", opts or {}, {
    enable_popup = true,
    float = popup_diagnostics_opts(),
    severity = M.get_highest_diag(),
  }))
end
function M.diag_prev(opts)
  diags.goto_prev(vim.tbl_extend("keep", opts or {}, {
    enable_popup = true,
    float = popup_diagnostics_opts(),
    severity = M.get_highest_diag(),
  }))
end

function M.error_next() M.diag_next { severity = vim.diagnostic.severity.ERROR } end
function M.error_prev() M.diag_prev { severity = vim.diagnostic.severity.ERROR } end

function M.live_codelens()
  local id = vim.api.nvim_create_augroup("lsp_codelens_refresh", { clear = false })
  vim.api.nvim_create_autocmd(
    { "CursorHold", "InsertLeave", "BufWritePost" },
    { buffer = 0, callback = vim.lsp.codelens.refresh, group = id }
  )
end

-- Helper for better renaming interface
M.rename = (function()
  local function handler(...)
    local result
    local method
    local err = select(1, ...)
    local is_new = not select(4, ...) or type(select(4, ...)) ~= "number"
    if is_new then
      method = select(3, ...).method
      result = select(2, ...)
    else
      method = select(2, ...)
      result = select(3, ...)
    end

    if O.lsp.rename_notification then
      if err then
        vim.notify(("Error running LSP query '%s': %s"):format(method, err), vim.log.levels.ERROR)
        return
      end

      -- echo the resulting changes
      local new_word = ""
      if result and result.changes then
        local msg = {}
        for f, c in pairs(result.changes) do
          new_word = c[1].newText
          table.insert(msg, ("%d changes -> %s"):format(#c, utils.get_relative_path(f)))
        end
        local currName = vim.fn.expand "<cword>"
        vim.notify(msg, vim.log.levels.INFO, { title = ("Rename: %s -> %s"):format(currName, new_word) })
      end
    end

    vim.lsp.handlers[method](...)
  end

  local function do_rename()
    local new_name = vim.trim(vim.fn.getline("."):sub(5, -1))
    vim.cmd [[q!]]
    local params = lsp.util.make_position_params()
    local curr_name = vim.fn.expand "<cword>"
    if not (new_name and #new_name > 0) or new_name == curr_name then return end
    params.newName = new_name
    lsp.buf_request(0, "textDocument/rename", params, handler)
  end

  return function()
    require("plugins.ui.input").inline_text_input {
      border = O.lsp.rename_border,
      -- enter = do_rename,
      enter = vim.lsp.buf.rename,
      startup = function() feedkeys(t "viw<C-G>", "n", false) end,
      init_cword = true,
      at_begin = true, -- FIXME: What happened to this?
      minwidth = true,
    }
  end
end)()

-- Use select mode for renaming
M.renamer = (function()
  local function del_keymaps()
    vim.keymap.del("i", "<CR>")
    vim.keymap.del("i", "<ESC><ESC>")
  end

  local function enter_cb(old, oldpos)
    -- local cword = vim.fn.expand "<cword>"
    -- utils.dump(cword)
    vim.cmd "stopinsert"
    vim.defer_fn(function()
      -- vim.api.nvim_win_set_cursor(0, oldpos)
      local cword = vim.fn.expand "<cword>"
      -- utils.dump(cword)
      feedkeys(t("ciw" .. old .. "<ESC>"), "n", false)

      del_keymaps()

      vim.lsp.buf.rename(cword)
    end, 1)
  end

  local function cancel_cb(old)
    vim.cmd "stopinsert"
    -- feedkeys(t "u", "n", false)
    feedkeys(t("ciw" .. old .. "<ESC>"), "n", false)
    del_keymaps()
  end

  local function mk_keymaps(old)
    local enter = function() enter_cb(old, vim.api.nvim_win_get_cursor(0)) end
    local cancel = function() cancel_cb(old) end
    vim.keymap.setl("i", "<CR>", enter, { silent = true })
    vim.keymap.setl("i", "<M-CR>", enter, { silent = true })
    vim.keymap.setl("i", "<ESC><ESC>", cancel, { silent = true })
  end

  return function()
    local old = vim.fn.expand "<cword>"
    feedkeys(t "viw<C-G>", "n", false) -- Go select mode
    mk_keymaps(old)
  end
end)()
-- M.rename = M.renamer.keymap

function M.format(opts)
  opts = opts or {}
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  local have_nls = #require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") > 0

  vim.lsp.buf.format(vim.tbl_extend("force", {
    bufnr = buf,
    filter = function(client)
      if have_nls then return client.name == "null-ls" end
      return client.name ~= "null-ls"
    end,
  }, opts))
end

M.format_on_save = function(disable)
  -- TODO: only if client has formatting
  if disable then return end
  local id = vim.api.nvim_create_augroup("format_on_save", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function() M.format { timeout_ms = O.format_on_save_timeout } end,
    group = id,
  })
end

vim.lsp.buf.cancel_formatting = function(bufnr)
  vim.schedule(function()
    bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
    for _, client in ipairs(vim.lsp.get_active_clients { bufnr = bufnr }) do
      for id, request in pairs(client.requests or {}) do
        if request.type == "pending" and request.bufnr == bufnr and request.method == "textDocument/formatting" then
          client.cancel_request(id)
        end
      end
    end
  end)
end

M.cb_on_attach = function(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

-- TODO: `:h lsp-on-list-handler`

return M
