local M = {
  {
    "chipsenkbeil/distant.nvim",
    config = function()
      local actions = require "distant.nav.actions"
      require("distant"):setup {
        ["*"] = {
          -- Apply these launch settings to all hosts
          launch = {
            -- Apply additional CLI options to the listening server, such as
            -- shutting down when there is no connection to it after 30 seconds
            extra_server_args = '"--shutdown-after 30"',
          },

          -- Specify mappings to apply on remote file buffers
          -- Presently, the only one you would want is some way to trigger
          -- file navigation
          file = {
            mappings = {
              ["-"] = actions.up,
            },
          },

          -- Specify mappings to apply on remote directory bufffers
          dir = {
            mappings = {
              ["<CR>"] = actions.edit,
              ["-"] = actions.up,
              ["K"] = actions.mkdir,
              ["N"] = actions.newfile,
              ["R"] = actions.rename,
              ["D"] = actions.remove,
            },
          },
        },
      }
    end,
    cmd = "DistantLaunch",
  },
  -- TODO: https://github.com/jbyuki/instant.nvim (collaborative editing)
  {
    "jbyuki/instant.nvim",
    cmd = {
      "InstantStartServer",
      "InstantStartSingle",
      "InstalJoinSingle",
      "InstantStartSession",
      "InstantJoinSession",
    },
  },
}
return {}
