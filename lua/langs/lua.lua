return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- Library items can be absolute paths
            -- "~/projects/my-awesome-lib",
            -- Or relative, which means they will be resolved as a plugin
            -- "LazyVim",
            -- When relative, you can also provide a path to the library in the plugin dir
            "luvit-meta/library", -- see below
          },
        },
        config = function(_, opts)
          require("lazydev").setup(opts)
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "lua",
            callback = function()
              require("langs.complete").sources {
                {
                  name = "lazydev",
                  group_index = 0, -- set group index to 0 to skip loading LuaLS completions
                },
              }
            end,
          })
        end,
        dependencies = {
          { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
        },
      },
    },
    opts = {
      servers = {
        lua_ls = {
          -- cmd = { "ra-multiplex", "--ra-mux-server", "lua-language-server" },
          -- mason = false, -- set to false if you don't want this server to be installed with mason
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Both",
                keywordSnippet = "Both",
              },
              codeLens = { enable = false },
              hint = {
                enable = true,
                setType = false,
                arrayIndex = "Disable",
              },
            },
          },
        },
      },
    },
  },
  -- TODO: which is the best nvim-lua REPL?
  {
    "bfredl/nvim-luadev",
    cmd = "Luadev",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        callback = function()
          local map = vim.keymap.setl
          map("n", "<localleader>xx", "<Plug>(Luadev-RunLine)") --	Execute the current line
          map("n", "<localleader>x", "<Plug>(Luadev-Run)") --	Operator to execute lua code over a movement or text object.
          map("n", "<localleader>xw", "<Plug>(Luadev-RunWord)") --	Eval identifier under cursor, including table.attr
          -- map("n", "<localleader>x", "<Plug>(Luadev-Complete)") --
        end,
      })
    end,
  },
  {
    "ii14/neorepl.nvim",
    opts = {},
    cmd = "Repl",
    init = function()
      vim.api.nvim_create_user_command("NeoRepl", function()
        -- get current buffer and window
        local buf = vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_get_current_win()
        -- create a new split for the repl
        vim.cmd "split"
        -- spawn repl and set the context to our buffer
        require("neorepl").new {
          buffer = buf,
          window = win,
        }
        -- resize repl window and make it fixed height
        vim.cmd "resize 10"
        vim.wo.winfixheight = true
      end, {})
    end,
    config = function(_, opts) end,
    keys = {
      { "g:", "<cmd>NeoRepl<cr>", desc = "NeoRepl" },
    },
  },
  {
    "rafcamlet/nvim-luapad",
    opts = { context = {
      utils = utils,
    } },
    cmd = { "Luapad", "LuaRun", "LuaAttach", "LuaDetach", "LuaEval" },
    config = function(_, opts)
      require("luapad").setup(opts)
      local cmd = function(name, fn, opts)
        vim.api.nvim_create_user_command(
          name,
          function(args) require("luapad")[fn](type(opts) == "function" and opts(args) or opts) end,
          { nargs = "*" }
        )
      end
      cmd("LuaAttach", "attach", {})
      cmd("LuaDetach", "detach", {})
      vim.api.nvim_create_user_command("LuaEval", function(args) require("luapad.state").current():eval() end, {})
    end,
  },
}
