return {
  -- TODO: https://github.com/Goose97/timber.nvim
  {
    "andrewferrier/debugprint.nvim",
    opts = { create_keymaps = false },
    -- TODO: use a hydra?
    keys = {
      { "dpp", utils.lazy_require("debugprint").debugprint, desc = "DbgPrnt Line", expr = true },
      {
        "dPP",
        utils.partial(utils.lazy_require("debugprint").debugprint, { above = true }),
        desc = "DbgPrnt Line abv",
        expr = true,
      },
      {
        "dpv",
        utils.partial(utils.lazy_require("debugprint").debugprint, { variable = true }),
        desc = "DbgPrnt Var",
        expr = true,
      },
      {
        "dPV",
        utils.partial(
          utils.lazy_require("debugprint").debugprint,
          { variable = true, above = true }
        ),
        desc = "DbgPrnt Var abv",
        expr = true,
      },
      {
        "<leader>dp",
        utils.partial(utils.lazy_require("debugprint").debugprint, { variable = true }),
        desc = "DbgPrnt Var",
        mode = "x",
        expr = true,
      },
      {
        "<leader>dP",
        utils.partial(
          utils.lazy_require("debugprint").debugprint,
          { variable = true, above = true }
        ),
        desc = "DbgPrnt Var abv",
        mode = "x",
        expr = true,
      },
    },
  },
}
