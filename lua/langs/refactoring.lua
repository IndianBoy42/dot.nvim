return {
  "ThePrimeagen/refactoring.nvim",
  opts = {},
  config = function(_, opts)
    require("telescope").load_extension "refactoring"
    require("refactoring").setup(opts)
  end,
}
