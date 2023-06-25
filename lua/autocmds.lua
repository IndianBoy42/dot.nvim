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
    local feedkeys = vim.api.nvim_feedkeys
    local termcodes = vim.api.nvim_replace_termcodes
    local function t(k) return termcodes(k, true, true, true) end
    local function f(a, mode) return feedkeys(t(a), mode or "n", false) end

    augrp("_focus_lost", function(au)
      au({ "FocusLost", "WinLeave", "TabLeave" }, function()
        if vim.bo.buftype == "" then pcall(vim.cmd.update) end
      end)
      au("FocusLost", function() f "<C-\\><C-n>" end)
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
      local root_patterns = { ".git", "Makefile", "CMakeLists.txt", "Justfile" }

      local function get(args)
        if args.event == "VimEnter" then
          if vim.fn.argc() == 1 then
            local arg = vim.fn.argv(0)
            local stat = vim.loop.fs_stat(arg)
            if stat and stat.type == "directory" then return arg end
          end
        end

        do
          local clients = lsp.get_active_clients { bufnr = 0 }

          for _, client in ipairs(clients) do
            local dir = client.config.root_dir
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
  end,
}
