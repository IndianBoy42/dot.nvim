function FocusMe()
  if vim.g.neovide then
    pcall(vim.cmd.NeovideFocus)
  else
    require("kitty.current_win").focus()
  end
end

local function FNV_hash(s)
  local prime = 1099511628211
  local hash = 14695981039346656037
  for i = 1, #s do
    hash = require("bit").bxor(hash, s:byte(i))
    hash = hash * prime
  end
  return hash
end

return {
  "willothy/flatten.nvim",
  lazy = false,
  priority = 1001,
  cond = not vim.g.kitty_scrollback,
  opts = {
    _pipe_path = function()
      -- If running in a Kitty terminal, all tabs/windows/os-windows in the same instance of kitty will open in the first neovim instance
      if vim.env.NVIM then return vim.env.NVIM end

      local addr

      -- If running in a Kitty terminal, all tabs/windows/os-windows in the same instance of kitty will open in the first neovim instance
      if vim.env.KITTY_PID then addr = ("%s/kitty.nvim-%s"):format(vim.fn.stdpath "run", vim.env.KITTY_PID) end

      -- TODO: better cwd-based nesting
      if not addr then addr = ("%s/nvim-%s"):format(vim.fn.stdpath "run", FNV_hash(vim.loop.cwd())) end

      if addr then
        local ok = pcall(vim.fn.serverstart, addr)
        return addr
      end
    end,
    -- <String, Bool> dictionary of filetypes that should be blocking
    block_for = {
      gitcommit = true,
    },
    one_per = {
      kitty = true,
      wezterm = true,
    },
    -- Window options
    window = {
      open = "current",
      -- open = function(bufs, argv)
      --   if vim.tbl_contains(argv, "-s") then
      --   end
      --   vim.api.nvim_win_set_buf(0, bufs[1])
      -- end,
      focus = "first",
    },
    nest_if_no_args = false,
    callbacks = {
      ---@param argv table a list of all the arguments in the nested session
      should_block = function(argv)
        -- Note that argv contains all the parts of the CLI command, including
        -- Neovim's path, commands, options and files.
        -- See: :help v:argv

        if argv[1] == "nvimb" then return true end

        -- In this case, we would block if we find the `-b` flag
        -- This allows you to use `nvim -b file1` instead of `nvim --cmd 'let g:flatten_wait=1' file1`
        if vim.tbl_contains(argv, "-b") then return true end

        -- Alternatively, we can block if we find the diff-mode option
        -- return vim.tbl_contains(argv, "-d")
        if vim.tbl_contains(argv, "-d") then return true end
        if vim.tbl_contains(argv, "--diff") then return true end

        return false
      end,
      should_nest = function(host)
        if vim.env.NVIM ~= nil then return false end

        if vim.tbl_contains(vim.v.argv, "__focus") then return false end

        -- If in a wezterm or kitty split, only open files in the first neovim instance
        -- if their working directories are the same.
        -- This allows you to open a new instance in a different cwd, but open files from the active cwd in your current session.
        local call = "return vim.fn.getcwd(-1)"
        local ok, host_cwd = pcall(vim.rpcrequest, host, "nvim_exec_lua", call, {})

        -- Yield to default behavior if RPC call fails
        if not ok then return false end

        ---@diagnostic disable-next-line: param-type-mismatch
        return not vim.startswith(vim.fn.getcwd(-1), host_cwd)
      end,

      no_files = function()
        -- TODO: this seems to open minifiles?
        pcall(FocusMe)
      end,
      guest_args = { wid = vim.env.KITTY_WINDOW_ID },
      post_open = function(bufnr, winnr, filetype)
        -- Called after a file is opened
        -- Passed the buf id, win id, and filetype of the new window

        -- Switch kitty window
        FocusMe()

        -- If the file is a git commit, create one-shot autocmd to delete its buffer on write
        -- If you just want the toggleable terminal integration, ignore this bit
        if ft == "gitcommit" or ft == "gitrebase" then
          vim.api.nvim_create_autocmd("BufWritePost", {
            buffer = bufnr,
            once = true,
            callback = vim.schedule_wrap(function() vim.api.nvim_buf_delete(bufnr, {}) end),
          })
        end
      end,
      block_end = function(ft, state)
        -- Called when a file is open in blocking mode, after it's done blocking
        -- (after bufdelete, bufunload, or quitpre for the blocking buffer)
        -- TODO: refocus the previous window
        vim.notify "hello"
        if state and state.wid then require("kitty.term").new({ attach_to_win = state.wid }):focus() end
      end,
    },
  },
}
