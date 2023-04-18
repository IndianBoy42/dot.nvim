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
      open = "current",
      focus = "first",
    },
  },
}
