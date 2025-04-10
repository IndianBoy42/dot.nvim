_G.CONFIG_PATH = vim.fn.stdpath "config"
_G.DATA_PATH = vim.fn.stdpath "data"
_G.CACHE_PATH = vim.fn.stdpath "cache"
_G.PLUGIN_PATH = _G.DATA_PATH .. "site/pack/*/start/*"
_G.TERMINAL = vim.fn.expand "$TERMINAL"
_G.LSP_INSTALL_PATH = DATA_PATH .. "/lspinstall"

-- TODO: Cleanup this config struct
local O = {
  format_on_save = true,
  format_on_save_mod = {
    vim.fs.dirname(DATA_PATH),
    "~/git-builds/",
  },
  format_on_save_timeout = 1000,
  auto_close_tree = false,
  fold_columns = "0",
  fontsize = 10,
  bigfontsize = 13,
  auto_complete = true,
  colorcolumn = "99999",
  clipboard = "", -- "unnamedplus",
  hidden_files = true,
  wrap_lines = false,
  spell = false,
  spelllang = "en",
  number = false,
  relative_number = false,
  number_width = 2,
  shift_width = 4,
  tab_stop = 4,
  cmdheight = 0,
  cursorline = true,
  shell = "bash", -- shell is used for running scripts
  termshell = "fish", -- termshell is used for interactive terminals
  timeoutlen = 500,
  nvim_tree_disable_netrw = 0,
  ignore_case = true,
  smart_case = true,
  scrolloff = 10,
  lushmode = false,
  hl_search = true,
  inc_subs = "split",
  transparent_window = false,
  signcolumn = "number", -- "yes" for always
  notify = {
    timeout = 4000, -- 5000 default
    background_colo_r = "#FFFFFF",
    stages = "fade_in_slide_out",
  },
  input_border = "rounded",
  filetypes = {},
  python_interp = CONFIG_PATH .. "/.venv/bin/python3", -- TODO: make a venv for this

  leader_key = "<space>",
  multi_leader_key = "_",
  local_leader_key = "<bs>",
  goto_prefix = "<cr>",
  goto_next = "]",
  goto_previous = "[",
  goto_next_outer = ")",
  goto_previous_outer = "(",
  goto_next_end = "<leader>]", -- ")",
  goto_previous_end = "<leader>[", -- "(",
  goto_next_outer_end = "<leader>)", -- "))",
  goto_previous_outer_end = "<leader>)", -- "((",
  select = "&",
  select_dynamic = "v",
  select_dynamic_around = "am",
  select_remote = "r",
  select_remote_dynamic = "m",
  select_outer = "<M-S-7>", -- M-&
  select_less = "<C-S-7>", -- C-&
  select_next = "in",
  select_previous = "iN",
  select_next_outer = "an",
  select_previous_outer = "aN",
  -- USE: { }
  -- The below is used for most hint based navigation/selection (hop, hint_textobjects)
  -- hint_labels = "fdsahjklgvcxznmbyuiorewqtp",
  hint_labels = "jklfdsahgnmervcxzbuioyptwq",

  -- hint_labels = "hjklfdsagnmervcxzbuioyptwq",
  database = { save_location = "~/.config/nvim/.db", auto_execute = 1 },
  hover_key = "H",
  action_key = "K",
  action_key_vis = "K",
  -- TODO:?
  -- hover_key = "K",
  -- action_key = "co",
  -- action_key_vis = "C",
  commenting = {
    op = "yc",
    vi = "C",
    obj = "ic",
  },
}

do
  local c = O.commenting
  if c.vi == nil then c.vi = c.op end
  if c.line == nil then c.line = c.op .. c.op:sub(-1) end
  if c.obj == nil then c.obj = "i" .. c.op end

  if c.copy == nil then c.copy = {} end
  local cc = c.copy
  if cc.op == nil then cc.op = "<leader>" .. c.op end
  if cc.vi == nil then cc.vi = "<leader>" .. c.vi end
  if cc.line == nil then cc.line = "<leader>" .. c.line end
end

O.goto_prev = O.goto_previous
O.goto_prev_outer = O.goto_previous_outer
O.goto_prev_end = O.goto_previous_end -- "(",
O.goto_prev_outer_end = O.goto_previous_outer_end -- "((",
O.select_prev = O.select_previous
O.select_prev_outer = O.select_previous_outer

O.hint_labels_array = {}
for c in O.hint_labels:gmatch "." do
  vim.list_extend(O.hint_labels_array, { c })
end
vim.o.titleold = _G.TERMINAL

return setmetatable(O, {
  __index = O,
  __newindex = function(t, k, v) error("attempt to update a read-only table", 2) end,
})
