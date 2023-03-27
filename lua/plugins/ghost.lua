return {
  "subnut/nvim-ghost.nvim",
  -- build = ":call nvim_ghost#installer#install()",
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
    vim.api.nvim_create_user_command("Ghost", function()
      local id = vim.api.nvim_create_augroup("Ghost_autocmds", {})
      local function au(sites, ft, cb)
        vim.api.nvim_create_autocmd("User", {
          pattern = sites,
          callback = function(args)
            if ft then vim.bo.filetype = ft end
            if cb then cb(args, sites, ft) end
          end,
          group = id,
        })
      end

      au({ "*reddit.com", "*github.com", "*stackoverflow.com" }, "markdown")
    end, {})
  end,
  cmd = "Ghost",
}
