return {
  "ThePrimeagen/refactoring.nvim",
  opts = {},
  config = function(_, opts)
    require("telescope").load_extension "refactoring"
    require("refactoring").setup(opts)
  end,
  cmd = { "Refactor" },
  keys = {
    {
      "<localleader>ef",
      ":Refactor extract ",
      desc = "Extract function",
      mode = "x",
    },
    {
      "<localleader>ev",
      ":Refactor extract_var ",
      desc = "Extract function",
      mode = "x",
    },
    {
      "<localleader>eF",
      ":Refactor extract_to_file ",
      desc = "Extract function to file",
      mode = "x",
    },
    {
      "<localleader>ef",
      ":Refactor extract_block ",
      desc = "Extract block to file",
      mode = "n",
    },
    {
      "<localleader>eF",
      ":Refactor extract_block_to_file ",
      desc = "Extract block to file",
      mode = "n",
    },
    {
      "<localleader>ei",
      ":Refactor inline_var",
      desc = "Inline variable",
      mode = { "n", "x" },
    },
  },
}
