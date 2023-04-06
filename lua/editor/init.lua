-- TODO:  too big, split into files
return {
  {
    "ggandor/leap-spooky.nvim",
    opts = {
      affixes = {
        remote = { window = "r", cross_window = "R" },
        magnetic = { window = "<C-r>", cross_window = "<C-S-R>" },
      },
    },
    event = "VeryLazy",
  },
  -- TODO: https://github.com/gbprod/yanky.nvim
}
