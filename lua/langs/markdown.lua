return {
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    -- "previm/previm",
    init = function()
      vim.g.mkdp_markdown_css = CONFIG_PATH .. "lua/langs/markdown.css"
    end,
    ft = "markdown",
    disable = not O.plugin.markdown_preview,
  },
  { "ellisonleao/glow.nvim", config = true, cmd = "Glow" },
  { "dkarter/bullets.vim" },
}
