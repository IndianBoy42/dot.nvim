return {
  "subnut/nvim-ghost.nvim",
  build = ":call nvim_ghost#installer#install()",
  config = function()
    -- " Autocommand for a single website (i.e. stackoverflow.com)
    -- au nvim_ghost_user_autocommands User www.stackoverflow.com set filetype=markdown
    --
    -- " Autocommand for a multiple websites
    -- au nvim_ghost_user_autocommands User www.reddit.com,www.github.com set filetype=markdown
    --
    -- " Autocommand for a domain (i.e. github.com)
    -- au nvim_ghost_user_autocommands User *github.com set filetype=markdown
    --
    -- " Multiple autocommands can be specified like so -
    -- augroup nvim_ghost_user_autocommands
    --   au User www.reddit.com,www.stackoverflow.com set filetype=markdown
    --   au User www.reddit.com,www.github.com set filetype=markdown
    --   au User *github.com set filetype=markdown
    -- augroup END
    vim.api.nvim_create_user_command("Ghost", function() end, {})
  end,
  cmd = "Ghost",
}
