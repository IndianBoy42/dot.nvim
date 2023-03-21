_G.CONFIG_PATH = vim.fn.stdpath "config"
_G.DATA_PATH = vim.fn.stdpath "data"
_G.CACHE_PATH = vim.fn.stdpath "cache"
_G.PLUGIN_PATH = _G.DATA_PATH .. "site/pack/*/start/*"
_G.TERMINAL = vim.fn.expand "$TERMINAL"
_G.LSP_INSTALL_PATH = DATA_PATH .. "/lspinstall"

-- TODO: Cleanup this config struct
local O = {
  format_on_save = true,
  format_on_save_timeout = 1000,
  auto_close_tree = false,
  fold_columns = "0",
  theme = "Nebulous",
  -- theme = "Material",
  lighttheme = "Paper", -- Paper is good but incompatible with notify.nvim
  -- lighttheme = "Zenbones",
  fontsize = 10,
  bigfontsize = 13,
  auto_complete = true,
  colorcolumn = "99999",
  clipboard = "unnamedplus",
  hidden_files = true,
  wrap_lines = false,
  spell = false,
  spelllang = "en",
  number = false,
  relative_number = false,
  number_width = 2,
  shift_width = 4,
  tab_stop = 4,
  cmdheight = 2,
  cursorline = true,
  shell = "bash", -- shell is used for running scripts
  termshell = "fish", -- termshell is used for interactive terminals
  timeoutlen = 300,
  nvim_tree_disable_netrw = 0,
  ignore_case = true,
  smart_case = true,
  scrolloff = 10,
  lushmode = false,
  hl_search = true,
  inc_subs = "split",
  transparent_window = false,
  leader_key = "space",
  local_leader_key = ",",
  signcolumn = "number", -- "yes" for always
  notify = {
    timeout = 2000, -- 5000 default
    background_colo_r = "#FFFFFF",
    stages = "fade_in_slide_out",
  },
  breakpoint_sign = { text = "🛑", texthl = "LspDiagnosticsSignError", linehl = "", numhl = "" },
  input_border = "rounded",
  lsp = {
    document_highlight = true,
    autoecho_line_diagnostics = false,
    live_codelens = true,
    -- none, single, double, rounded, solid, shadow, array(fullcustom)
    border = "rounded",
    rename_border = "none",
    diagnostics = {
      virtual_text = { spacing = 4, prefix = "", severity_limit = "Warning" },
      -- virtual_text = false,
      signs = true,
      underline = true,
      severity_sort = true,
      update_in_insert = true,
    },
    codeLens = {
      virtual_text = { spacing = 0, prefix = "" },
      signs = true,
      underline = true,
      severity_sort = true,
    },
    flags = {
      debounce_text_changes = 150,
    },
    parameter_hints_prefix = "« ",
    -- default: "<-"
    -- parameter_hints_prefix = "❰❰ ",
    other_hints_prefix = "∈ ",
    -- default: "=>"
    -- other_hints_prefix = ":: ",
  },
  filetypes = {
    extension = {
      kbd = "kmonad",
      fish = "fish",
      just = "just",
    },
    literal = {
      Justfile = "just",
      justfile = "just",
    },
  },
  python_interp = CONFIG_PATH .. "/.venv/bin/python3.9", -- TODO: make a venv for this
  goto_next = "]",
  goto_previous = "[",
  -- The below is used for most hint based navigation/selection (hop, hint_textobjects)
  -- hint_labels = "fdsahjklgvcxznmbyuiorewqtp",
  hint_labels = "hjklfdsanmevcxzwuio",
  database = { save_location = "~/.config/nvim/.db", auto_execute = 1 },
}
vim.cmd('let &titleold="' .. _G.TERMINAL .. '"')

return O
