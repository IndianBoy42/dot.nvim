return function()
  ---  HELPERS  ---
  local cmd = vim.cmd
  local opt = vim.opt

  ---  VIM ONLY COMMANDS  ---

  cmd "filetype plugin on"
  cmd "set iskeyword+=-"
  cmd "set sessionoptions+=globals"
  cmd "set whichwrap+=<,>,[,],h,l"
  if vim.g.nvui then cmd "NvuiFrameless v:false" end
  if O.transparent_window then
    cmd "au ColorScheme * hi Normal ctermbg=none guibg=none"
    cmd "au ColorScheme * hi SignColumn ctermbg=none guibg=none"
  end

  -- Set leader keys
  local map = vim.keymap.set
  local function t(k) return vim.api.nvim_replace_termcodes(k, true, true, true) end
  map("n", O.leader_key, "<NOP>")
  vim.g.mapleader = t(O.leader_key)
  map("n", O.local_leader_key, "<NOP>")
  vim.g.maplocalleader = t(O.local_leader_key)
  map(
    { "n", "x", "o" },
    O.local_leader_key,
    function() require("which-key").show(vim.g.maplocalleader, { mode = "n" }) end
  )

  ---  SETTINGS  ---
  -- https://github.com/tpope/vim-sensible/blob/master/plugin/sensible.vim
  opt.shell = O.shell
  -- opt.shell = O.termshell
  opt.inccommand = "nosplit" -- Incremental substitution style
  opt.backspace = "indent,eol,start"
  opt.backup = false -- creates a backup file
  opt.clipboard = O.clipboard -- allows neovim to access the system clipboard
  opt.cmdheight = O.cmdheight -- more space in the neovim command line for displaying messages
  opt.colorcolumn = O.colorcolumn
  opt.completeopt = { "menuone", "noselect" }
  opt.conceallevel = 0 -- so that `` is visible in markdown files
  opt.fileencoding = "utf-8" -- the encoding written to a file
  opt.hidden = O.hidden_files -- required to keep multiple buffers and open multiple buffers
  opt.hlsearch = O.hl_search -- highlight all matches on previous search pattern
  opt.ignorecase = O.ignore_case -- ignore case in search patterns
  opt.mouse = "nvhr" -- allow the mouse to be used in neovim
  opt.mousemoveevent = true
  opt.pumheight = 10 -- pop up menu height
  opt.showmode = false -- we don't need to see things like -- INSERT -- anymore
  opt.showtabline = 2 -- always show tabs
  opt.smartcase = O.smart_case -- smart case
  opt.smartindent = true -- make indenting smarter again
  opt.splitbelow = true -- force all horizontal splits to go below current window
  opt.splitright = true -- force all vertical splits to go to the right of current window
  opt.splitkeep = "screen" -- keeps the same screen lines when splitting
  opt.swapfile = false -- creates a swapfile
  opt.termguicolors = true -- set term gui colors (most terminals support this)
  opt.timeoutlen = O.timeoutlen -- time to wait for a mapped sequence to complete (in milliseconds)
  opt.title = true -- set the title of window to the value of the titlestring
  opt.titlestring = "%<%F%=%l/%L - nvim" -- what the title of the window will be set to
  vim.g.cursorhold_updatetime = 300
  opt.updatetime = vim.g.cursorhold_updatetime
  opt.writebackup = false -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  opt.expandtab = true -- convert tabs to spaces
  opt.shiftwidth = O.shift_width -- the number of spaces inserted for each indentation
  opt.shortmess = "aoOF"
  opt.tabstop = O.tab_stop -- insert 4 spaces for a tab
  opt.cursorline = O.cursorline -- highlight the current line
  opt.number = O.number -- set numbered lines
  opt.relativenumber = false
  opt.numberwidth = 2
  opt.signcolumn = "yes"
  opt.wrap = O.wrap_lines -- display lines as one long line
  opt.linebreak = true -- dont linebreak in the middle of words
  opt.spell = O.spell
  opt.spelllang = O.spelllang
  opt.scrolloff = O.scrolloff -- Scrolloffset to block the cursor from reaching the top/bottom
  opt.breakindent = true -- Apply indentation for wrapped lines
  opt.breakindentopt = "sbr" -- Apply indentation for wrapped lines
  opt.pastetoggle = "<F3>" -- Enter Paste Mode with
  opt.foldlevelstart = 99 -- Don't fold on startup
  opt.foldcolumn = O.fold_columns -- Add fold indicators to number column
  opt.foldmethod = "indent" -- Set default fold method as indent, although will be overriden by treesitter soon anyway
  -- opt.lazyredraw = true -- When running macros and regexes on a large file, lazy redraw tells neovim/vim not to draw the screen, which greatly speeds it up, upto 6-7x faster
  opt.autowriteall = true -- auto write on focus lost
  opt.sidescroll = 1
  opt.sidescrolloff = 10
  opt.listchars = { extends = ">", precedes = "<", trail = "_" }
  vim.g.python3_host_prog = O.python_interp
  opt.confirm = true

  if vim.env.NVIM_VERBOSE ~= nil then
    -- opt.verbosefile = "$HOME/.cache/nvim/verbose.log"
    vim.cmd [[set verbosefile=~/.cache/nvim/verbose.log]]
    opt.verbose = 15
  end

  -- opt.undodir = CACHE_PATH .. "/undo" -- set an undo directory
  local undodir = "/tmp/.undodir_" .. vim.env.USER
  if not vim.fn.isdirectory(undodir) then vim.fn.mkdir(undodir, "", 0700) end
  opt.undodir = undodir
  opt.undofile = true -- enable persistent undo

  -- neovide settings
  -- vim.g.neovide_cursor_vfx_mode = "pixiedust"
  -- vim.g.neovide_refresh_rate=120
  vim.g.neovide_window_floating_opacity = 0
  vim.g.neovide_floating_blur = 0
  vim.g.neovide_window_floating_blur = 0
  -- require("utils").set_guifont(O.fontsize, "FiraCode Nerd Font")
  require("utils").set_guifont(O.fontsize, "Iosevka Term SS05 Md Ex")

  if vim.g.kitty_scrollback then
    opt.signcolumn = "no" -- TODO: more stuff?
    -- opt.virtualedit = "all"
  end
end
