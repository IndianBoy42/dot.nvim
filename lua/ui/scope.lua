local sethl = vim.api.nvim_set_hl
local highlights = {
  RainbowRed = "#E06C75",
  RainbowYellow = "#E5C07B",
  RainbowBlue = "#61AFEF",
  RainbowOrange = "#D19A66",
  RainbowGreen = "#98C379",
  RainbowViolet = "#C678DD",
  RainbowCyan = "#56B6C2",
}
local function sethls()
  for k, v in pairs(highlights) do
    sethl(0, k, { fg = v })
  end
end

return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "LazyFile",
    opts = { highlight = highlights },
    config = function(_, opts) require "rainbow-delimiters.setup"(opts) end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    --https://github.com/lukas-reineke/indent-blankline.nvim/pull/612
    event = "LazyFile",
    version = "*",
    -- branch = "v3",
    main = "ibl",
    opts = {
      indent = {
        highlight = vim.tbl_keys(highlights),
      },
      exclude = {
        filetypes = { "help", "dashboard", "terminal" },
        buftypes = { "terminal", "nofile" },
      },
    },
    config = function(_, opts)
      local hooks = require "ibl.hooks"
      -- hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
      hooks.register(hooks.type.HIGHLIGHT_SETUP, sethls)

      require("ibl").setup(opts)
    end,
  },
  {
    "HampusHauffman/block.nvim",
    cmd = { "Block", "BlockOn", "BlockOff" },
    opts = { percent = 1.06, depth = 10, automatic = true },
    -- event = "LazyFile",
  },
  -- TODO: https://github.com/shellRaining/hlchunk.nvim
}
