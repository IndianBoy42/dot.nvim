local aucmd = vim.api.nvim_create_autocmd
local augrp = function(name, fn)
  local group = vim.api.nvim_create_augroup(name, {})
  fn(function(evt, opts)
    if type(opts) == "function" then opts = { callback = opts } end
    aucmd(evt, vim.tbl_extend("force", { group = group }, opts))
  end)
end
return {
  grp = augrp,
  defaults = function()
    -- Open help window in a vertical split to the right.
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = vim.api.nvim_create_augroup("help_window_right", {}),
      pattern = { "*.txt" },
      callback = function()
        if vim.o.filetype == "help" then vim.cmd.wincmd "L" end
      end,
    })

    augrp("_general_settings", function(au)
      au("TextYankPost", function() vim.highlight.on_yank { higroup = "Search", timeout = 200 } end)
      local formatoptions = function()
        vim.opt.formatoptions:remove "c"
        vim.opt.formatoptions:remove "o"
        -- vim.opt.formatoptions:remove("r")
      end
      au({ "BufWinEnter", "BufNewFile", "BufRead" }, formatoptions)
      au({ "BufWinEnter", "BufNewFile", "BufRead" }, function() vim.o.hlsearch = true end)
    end)

    augrp("_terminal_insert", function(au)
      if true then return end
      au("BufEnter", {
        pattern = "term://*",
        callback = function() vim.cmd.startinsert() end,
      })
      au("BufLeave", { pattern = "term://*", callback = function() vim.cmd.stopinsert() end })
    end)

    augrp("_auto_reload", function(au)
      au({ "BufEnter", "CursorHold" }, {
        callback = function() vim.cmd.checktime() end,
      })
    end)

    -- augrp("_auto_resize", function(au)
    --   au( "VimResized" , {
    --     callback = function() vim.cmd.wincmd = "=" end,
    --   })
    -- end)
    augrp("_focus_lost", function(au)
      au({ "FocusLost", "WinLeave", "TabLeave" }, function()
        if vim.bo.buftype == "" then pcall(vim.cmd.update) end
      end)
      -- au("FocusLost", function() f "<C-\\><C-n>" end)
      au({ "WinLeave", "TabLeave" }, function() vim.cmd.stopinsert() end)
    end)

    do
      local timer = nil
      vim.api.nvim_create_autocmd("RecordingEnter", {
        callback = function()
          timer = vim.defer_fn(function()
            timer = nil
            local reg = vim.fn.reg_recording()
            if reg then
              vim.notify(("You've been recording that macro %s for a loooong time"):format(reg), vim.log.levels.WARN)
            end
          end, 5000)
        end,
      })
      vim.api.nvim_create_autocmd("RecordingLeave", {
        callback = function()
          if timer then
            timer:stop()
            timer = nil
          end
        end,
      })
    end

    augrp("quickfix_window_fix", function(au)
      au("QuickFixCmdPost", {
        pattern = "[^l]*",
        callback = function()
          vim.cmd "vert cwindow"
          vim.cmd.wincmd "p"
          vim.cmd.wincmd "="
        end,
      })
    end)

    augrp("_auto_cd", function(au)
      local api = vim.api
      local lsp = vim.lsp
      local fs = vim.fs

      -- Automatically change to project root directory using either LSP or configured root patterns
      local root_patterns = { ".git", "Makefile", "CMakeLists.txt", "Justfile", "Cargo.toml" }

      local function get(args)
        if args.event == "VimEnter" then
          if vim.fn.argc() == 1 then
            local arg = vim.fn.argv(0)
            local stat = vim.loop.fs_stat(arg)
            if stat and stat.type == "directory" then return arg end
          end
        end

        do
          local clients = lsp.get_clients { bufnr = 0 }

          local lsp_dir
          for _, client in ipairs(clients) do
            local dir = client.config.root_dir
            -- TODO: choose the highest cwd
            if dir and dir ~= "." then return dir end
          end
        end

        do
          local bufname = api.nvim_buf_get_name(0)
          local path
          if vim.fn.isdirectory(bufname) == 1 then
            path = bufname
          elseif bufname:sub(1, #"oil://") == "oil://" then
            path = bufname:sub(#"oil://" + 1)
          else
            path = fs.dirname(bufname)
          end

          local root_pattern_match = fs.find(root_patterns, { path = path, upward = true })[1]

          if root_pattern_match ~= nil then return fs.dirname(root_pattern_match) end
        end
      end

      local function autocd(args)
        local dir = get(args)
        if dir then
          -- vim.notify("[" .. args.event .. "] CD: " .. dir)
          if pcall(api.nvim_set_current_dir, dir) then return true end
        end
      end

      au({ "VimEnter", "BufEnter", "BufReadPost", "LspAttach" }, {
        callback = autocd,
        desc = "Automatically change current directory",
      })
    end)
    -- utils.write_on_idle("noau_write_idle", 1000)

    -- utils.lsp.auto_hover()

    -- FIXME: doesn't interact with remember-me correctly
    if false then
      augrp("startup", function(au)
        au("VimEnter", {
          callback = function()
            -- From mini.starter
            -- Don't open Starter buffer if Neovim is opened to show something. That is
            -- when at least one of the following is true:
            -- - There are files in arguments (like `nvim foo.txt` with new file).
            if vim.fn.argc() > 0 then return true end

            -- - Several buffers are listed (like session with placeholder buffers). That
            --   means unlisted buffers (like from `nvim-tree`) don't affect decision.
            local listed_buffers = vim.tbl_filter(
              function(buf_id) return vim.fn.buflisted(buf_id) == 1 end,
              vim.api.nvim_list_bufs()
            )
            if #listed_buffers > 1 then return true end

            -- - Current buffer is meant to show something else
            if vim.bo.filetype ~= "" then return true end

            -- - Current buffer has any lines (something opened explicitly).
            -- NOTE: Usage of `line2byte(line('$') + 1) < 0` seemed to be fine, but it
            -- doesn't work if some automated changed was made to buffer while leaving it
            -- empty (returns 2 instead of -1). This was also the reason of not being
            -- able to test with child Neovim process from 'tests/helpers'.
            local n_lines = vim.api.nvim_buf_line_count(0)
            if n_lines > 1 then return true end
            local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]
            if string.len(first_line) > 0 then return true end

            local bufnr = vim.api.nvim_get_current_buf()
            if bufnr == nil or not vim.api.nvim_buf_is_valid(bufnr) then
              bufnr = vim.api.nvim_create_buf(false, true)
            end

            -- Open README if it exists:
            local options = {
              file = function()
                local files = vim.fs.find({
                  "README",
                  "README.md",
                  "README.txt",
                  "init.lua",
                  "main.rs",
                  "lib.rs",
                  "main.c",
                  "main.cpp",
                }, { upward = false, limit = 3 })
                if #files > 0 then
                  for _, file in ipairs(files) do
                    vim.cmd.edit(file)
                  end
                  return true
                end
                return false
              end,
              minifiles = function()
                MiniFiles.open()
                return true
              end,
              telescope = function()
                vim.cmd.Telescope "find_files"
                return true
              end,
            }

            for _, v in pairs(options) do
              if v() then return end
            end
          end,
        })
      end)
    end

    -- TODO: there is a better way with Plug continuations, hydra style
    if false then -- wiggle keys
      local buflen = 4
      local buf = {}
      for i = 1, buflen do
        buf[i] = ""
      end
      local pattern_builder = {}
      local state_root = {}
      for lhs, rhs in pairs(pattern_builder) do
        local P = state_root
        for i = 1, #lhs - 1 do
          local c = lhs:sub(i, i)
          if not P[c] then P[c] = {} end
          P = P[c]
        end
        P[lhs:sub(#lhs)] = rhs
      end

      local state = state_root

      local function reset()
        buf = {}
        state = state_root
      end
      local function timeout()
        vim.defer_fn(function() reset() end, vim.o.timeoutlen)
      end

      -- Limitations: on_key gets the keys after mappings
      local ns = vim.on_key(function(k)
        if vim.api.nvim_get_mode().mode ~= "n" then return end

        -- Circular buffer
        for i = 2, buflen do
          buf[i - 1] = buf[i]
        end
        buf[buflen] = k

        local act = state[k]
        if not act then
          reset()
        else
          if type(act) == "table" then
            state = act
            timeout()
          else
            if type(act) == "string" then vim.cmd.normal { bang = true, act } end
            if type(act) == "function" then act() end
            reset()
          end
        end
      end, nil)
    end
  end,
}
