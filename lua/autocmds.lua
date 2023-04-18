return function()
  -- Open help window in a vertical split to the right.
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("help_window_right", {}),
    pattern = { "*.txt" },
    callback = function()
      if vim.o.filetype == "help" then vim.cmd.wincmd "L" end
    end,
  })

  local _general_settings = require("utils").augroup "_general_settings"
  _general_settings.TextYankPost(function() vim.highlight.on_yank { higroup = "Search", timeout = 200 } end)

  local formatoptions = ""
  formatoptions = formatoptions .. "formatoptions-=c"
  -- formatoptions = formatoptions .. "formatoptions-=r"
  formatoptions = formatoptions .. "formatoptions-=o"
  _general_settings.BufWinEnter("setlocal " .. formatoptions)
  _general_settings.BufNewFile("setlocal " .. formatoptions)
  _general_settings.BufRead = function()
    vim.cmd("setlocal " .. formatoptions)
    vim.cmd "set hlsearch"
  end
  -- _general_settings.Filetype.qf = "set nobuflisted"

  -- Default autocommands
  -- TODO: Reorganize this into lua api
  require("utils").define_augroups {
    _buffer_bindings = { { "FileType", "dashboard", "nnoremap <silent> <buffer> q :q<CR>" } },
    _terminal_insert = { { "BufEnter", "term://*", "startinsert" }, { "BufLeave", "term://*", "stopinsert" } },
    -- will check for external file changes on cursor hold
    _auto_reload = { { "CursorHold", "*", "silent! checktime" } },
    -- will cause split windows to be resized evenly if main window is resized
    _auto_resize = { { "VimResized", "*", "wincmd =" } },
    _mode_switching = {
      -- will switch between absolute and relative line numbers depending on mode
      {
        "InsertEnter",
        "*",
        "if &relativenumber | let g:ms_relativenumberoff = 1 | setlocal number norelativenumber | endif",
      },
      { "InsertLeave", "*", 'if exists("g:ms_relativenumberoff") | setlocal relativenumber | endif' },
      --[[ { "InsertEnter", "*", "if &cursorline | let g:ms_cursorlineoff = 1 | setlocal nocursorline | endif" },
    { "InsertLeave", "*", 'if exists("g:ms_cursorlineoff") | setlocal cursorline | endif' }, ]]
    },
    _focus_lost = {
      { "FocusLost,TabLeave,BufLeave", "*", [[if &buftype == '' | :update | endif]] },
      -- { "FocusLost", "*", [[silent! call feedkeys("\<C-\>\<C-n>")]] },
      -- { "TabLeave,BufLeave", "*", [[if &buftype == '' | :stopinsert | endif]] }, -- FIXME: This breaks compe
    },
    -- Add position to jump list on cursorhold -- FIXME: slightly buggy
    _hold_jumplist = require("utils").hold_jumplist_aucmd,
  }

  do
    local timer = nil
    vim.api.nvim_create_autocmd("RecordingEnter", {
      callback = function()
        timer = vim.defer_fn(function()
          timer = nil
          vim.notify("You've been recording that macro for a loooong time", vim.log.levels.WARN)
        end, 5000)
      end,
    })
    vim.api.nvim_create_autocmd("RecordingLeave", {
      callback = function()
        timer = vim.defer_fn(function()
          timer:stop()
          timer = nil
        end, 5000)
      end,
    })
  end

  -- utils.write_on_idle("noau_write_idle", 1000)
end
