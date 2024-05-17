local M = {}
local feedkeys = vim.api.nvim_feedkeys
local termcodes = vim.api.nvim_replace_termcodes
local function t(k) return termcodes(k, true, true, true) end

Au.grp("lazy_filetype", function(au)
  au("Filetype", {
    pattern = "lazy",
    callback = function() utils.lsp.toggle_diag_lines() end,
  })
end)

M.use_lazy_file = true
M.lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }
-- Properly load file based plugins without blocking the UI
function M.lazy_file()
  M.use_lazy_file = M.use_lazy_file and vim.fn.argc(-1) > 0

  -- Add support for the LazyFile event
  local Event = require "lazy.core.handler.event"

  -- This autocmd will only trigger when a file was loaded from the cmdline.
  -- It will render the file as quickly as possible.
  vim.api.nvim_create_autocmd("BufReadPost", {
    once = true,
    callback = function(event)
      -- Skip if we already entered vim
      if vim.v.vim_did_enter == 1 then return end

      -- Try to guess the filetype (may change later on during Neovim startup)
      local ft = vim.filetype.match { buf = event.buf }
      if ft then
        -- Add treesitter highlights and fallback to syntax
        local lang = vim.treesitter.language.get_lang(ft)
        if not (lang and pcall(vim.treesitter.start, event.buf, lang)) then vim.bo[event.buf].syntax = ft end

        -- Trigger early redraw
        vim.cmd [[redraw]]
      end
    end,
  })
  -- We'll handle delayed execution of events ourselves
  Event.mappings.LazyFile = { id = "LazyFile", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
  Event.mappings["User LazyFile"] = Event.mappings.LazyFile

  local events = {} ---@type {event: string, buf: number, data?: any}[]

  local function load()
    if #events == 0 then return end
    vim.api.nvim_del_augroup_by_name "lazy_file"

    ---@type table<string,string[]>
    local skips = {}
    for _, event in ipairs(events) do
      skips[event.event] = skips[event.event] or Event.get_augroups(event.event)
    end

    vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile", modeline = false })
    for _, event in ipairs(events) do
      Event.trigger {
        event = event.event,
        exclude = skips[event.event],
        data = event.data,
        buf = event.buf,
      }
      if vim.bo[event.buf].filetype then
        Event.trigger {
          event = "FileType",
          buf = event.buf,
        }
      end
    end
    vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })
    events = {}
  end

  -- schedule wrap so that nested autocmds are executed
  -- and the UI can continue rendering without blocking
  load = vim.schedule_wrap(load)

  vim.api.nvim_create_autocmd(M.lazy_file_events, {
    group = vim.api.nvim_create_augroup("lazy_file", { clear = true }),
    callback = function(event)
      table.insert(events, event)
      load()
    end,
  })
end

M.lazy_file()

return {
  defaults = {
    lazy = true,
    config = true,
    -- TODO:
    -- cond = function(plugin)
    --   if os.getenv "NVIM" ~= nil then
    --     if plugin[1] ~= "willothy/flatten.nvim" then return false end
    --     return true
    --   end
    --   return true
    -- end,
  },
  install = { colorscheme = { "onedark", "torte" } },
  checker = {
    enabled = true,
  },
  change_detection = {
    enabled = false,
  },
  dev = {
    path = "~/plugins.nvim/",
    filter = { "IndianBoy42" },
  },
  ui = {
    border = "rounded",
    custom_keys = {
      ["<localleader>l"] = false,
      ["<localleader>t"] = {
        desc = "Open in new Kitty",
        function(plugin) require("kitty.terms").new_os_window { open_cwd = plugin.dir } end,
      },
      ["<localleader>g"] = {
        desc = "Open gitui in new Kitty",
        function(plugin) require("kitty.terms").new_os_window({ open_cwd = plugin.dir }, "gitui") end,
      },
      ["<localleader>m"] = {
        desc = "Open in Smerge",
        function(plugin) vim.cmd("!smerge " .. plugin.dir) end,
      },
      ["<localleader>h"] = {
        desc = "Open in github browser",
        function(plugin)
          vim.cmd("!gh repo view --web " .. plugin[1])
          -- require("kitty").new_os_window({ open_cwd = plugin.dir }, "gitui")
        end,
      },
      ["<localleader>n"] = { desc = "Next plugin", function() feedkeys(t "/[○●]", "m", false) end },
    },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "gzip",
        "zip",
        "zipPlugin",
        "tar",
        "tarPlugin",
        "getscript",
        "getscriptPlugin",
        "vimball",
        "vimballPlugin",
        "2html_plugin",
        "logipat",
        "rrhelper",
        "spellfile_plugin",
        "matchit",
      },
    },
  },
  diff = {
    cmd = "diffview.nvim",
  },
}
