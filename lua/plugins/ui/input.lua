-- Use a virtual window for 'inline' text input.
local M = {}

local feedkeys = vim.api.nvim_feedkeys
local termcodes = vim.api.nvim_replace_termcodes
local function t(k)
  return termcodes(k, true, true, true)
end

local function mini_window_setwidth(initwidth)
  local wid = 0
  local cword = vim.fn.expand "<cword>"
  if #cword == 0 then
    local cline = vim.fn.getline "."
    wid = #cline + 2
  else
    wid = #cword + 1 -- + vim.o.sidescrolloff
  end
  if wid > 2 then
    if wid > initwidth then
      vim.api.nvim_win_set_width(0, wid)
    end
  end
end

function M.inline_text_input(opts)
  local enter = opts.enter
  local escape = opts.escape

  local cur_pos = vim.api.nvim_win_get_cursor(0)
  if opts.at_begin then
    -- FIXME: this doesn't work (through vim.ui.input)
    vim.cmd [[normal! wb]]
  end
  if opts.init_cword then
    opts.initial = vim.fn.expand "<cword>"
  end
  if opts.initial == nil then
    opts.initial = ""
  end

  if not opts.border then
    opts.border = "none"
  end
  if opts.rel == nil then
    if opts.border == "none" then
      opts.rel = 0
    else
      opts.rel = -1
    end
  end
  if opts.prompt then
    if opts.border == "none" then
      -- TODO: use virtual text to the right of the input
    else
      -- TODO: show the prompt in the border
    end
  end

  if opts.minwidth then
    if "number" == type(opts.minwidth) then
      opts.initwidth = opts.minwidth
    else
      opts.initwidth = #opts.initial + 1
    end
  else
    opts.initwidth = 0
  end

  -- TODO: just use plenary.popup?
  local winopts = {
    relative = "cursor",
    row = opts.rel,
    col = opts.rel,
    width = opts.initwidth,
    height = 1,
    style = "minimal",
    -- border = O.lsp.border,
    border = opts.border,
    -- noautocmd = false
  }
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, winopts)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { opts.initial })
  vim.fn.prompt_setprompt(buf, opts.prompt)

  local function close_win(normally)
    -- feedkeys(t "<esc>", "n", false)
    -- vim.api.nvim_win_close(win, true)
    -- vim.api.nvim_buf_delete(buf, { force = true })
    vim.cmd [[stopinsert]]
    vim.cmd "q!"
    if escape and not normally then
      vim.defer_fn(function()
        vim.api.nvim_win_set_cursor(0, cur_pos)
        escape(value)
      end, 1)
    end
  end
  local function finish_cb()
    local value = vim.trim(vim.fn.getline ".")
    close_win(true)
    if enter then
      vim.defer_fn(function()
        vim.api.nvim_win_set_cursor(0, cur_pos)
        enter(value)
      end, 1)
    end
  end

  vim.opt_local.sidescrolloff = 0
  local map = vim.keymap.setl
  map("i", "<CR>", finish_cb, { buffer = buf })
  map("n", "<CR>", finish_cb, { buffer = buf })
  map("i", "<ESC>", "<NOP>", { buffer = buf, noremap = true })
  map("i", "<ESC><ESC>", "<ESC>", { buffer = buf, noremap = true })
  map("n", "<ESC>", close_win, { buffer = buf })
  map("n", "o", "<nop>", { buffer = buf, noremap = true })
  map("n", "O", "<nop>", { buffer = buf, noremap = true })
  if opts.startup then
    opts.startup()
  end
  if opts.insert then
    vim.cmd [[startinsert]]
  end

  vim.api.nvim_create_autocmd({ "InsertCharPre", "InsertLeave" }, {
    buffer = 0,
    callback = function()
      mini_window_setwidth(opts.initwidth)
    end,
  })
end

return M
