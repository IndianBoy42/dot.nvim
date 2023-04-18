return {
  "willothy/flatten.nvim",
  lazy = false,
  priority = 1001,
  opts = {
    -- <String, Bool> dictionary of filetypes that should be blocking
    block_for = {
      gitcommit = true,
    },
    -- Window options
    window = {
      -- open = "current",
      open = function(bufs, argv)
        if vim.tbl_contains(argv, "-s") then
        end
        vim.api.nvim_win_set_buf(0, bufs[1])
      end,
      focus = "first",
    },
    callbacks = {
      should_block = function(argv)
        -- Note that argv contains all the parts of the CLI command, including
        -- Neovim's path, commands, options and files.
        -- See: :help v:argv

        -- In this case, we would block if we find the `-b` flag
        -- This allows you to use `nvim -b file1` instead of `nvim --cmd 'let g:flatten_wait=1' file1`
        return vim.tbl_contains(argv, "-b")

        -- Alternatively, we can block if we find the diff-mode option
        -- return vim.tbl_contains(argv, "-d")
      end,
    },
  },
}
