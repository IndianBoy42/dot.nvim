return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim" },
  config = function()
    local focused = true
    vim.api.nvim_create_autocmd("FocusGained", {
      callback = function() focused = true end,
    })
    vim.api.nvim_create_autocmd("FocusLost", {
      callback = function() focused = false end,
    })
    require("noice").setup {
      cmdline = {
        format = {
          -- execute shell command (!command)
          filter = { pattern = "^:%s*!", icon = "$", ft = "sh" },

          -- replace file content with shell command output (%!command)
          f_filter = { pattern = "^:%s*%%%s*!", icon = " $", ft = "sh" },

          -- replace selection with shell command output (%! command on visual selection)
          v_filter = { pattern = "^:%s*%'<,%'>%s*!", icon = " $", ft = "sh" },

          substitute = {
            pattern = "^:%%?s/",
            icon = " ",
            ft = "regex",
            opts = {
              border = {
                text = {
                  top = " sub (old/new/) ",
                },
              },
            },
          },
        },
      },
      lsp = {
        progress = { enabled = false }, -- Using fidget so...
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = "rounded", -- add a border to hover docs and signature help
      },
      messages = {
        enabled = true, -- enables the Noice messages UI
        view = "mini", -- default view for messages
        -- view_error = "notify", -- view for errors
        -- view_warn = "notify", -- view for warnings
        -- view_history = "messages", -- view for :messages
        -- view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
      },
      popupmenu = {
        backend = "cmp",
      },
      views = {
        cmdline_popup = {
          position = {
            row = 3,
            col = "50%",
          },
          size = {
            min_width = 60,
            width = "auto",
            height = "auto",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = 6,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
            max_height = 15,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "NoiceCmdlinePopupBorder" },
          },
        },
        popup = {
          relative = "editor",
          position = {
            row = 6,
            col = "50%",
          },
          size = {
            width = "auto",
            height = "auto",
            -- max_height = 15,
            -- max_height = 99999,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "NoiceCmdlinePopupBorder" },
          },
        },
        mini = {
          align = "message-left",
          position = {
            col = 0,
          },
        },
      },
      routes = {
        { -- Desktop Notification if unfocused
          filter = {
            cond = function() return not focused end,
          },
          view = "notify_send",
          opts = { stop = false },
        },
        { -- written message
          filter = {
            event = "msg_show",
            find = "%d+L, %d+B",
          },
          view = "mini",
        },
        { -- FIXME: map command
          filter = { event = "msg_how ", cmdline = "%w*map" },
          view = "popup",
        },
      },
    }

    require("telescope").load_extension "noice"
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(event)
        vim.schedule(function() require("noice.text.markdown").keys(event.buf) end)
      end,
    })
  end,
  -- stylua: ignore
  keys = {
    {
      "<S-Enter>",
      function()
        require("noice").redirect(vim.fn.getcmdline(), { { view = "messages", filter = { event = "msg_show" } } })
      end,
      mode = "c",
      desc = "Redirect Cmdline",
    },
    -- { "<C-Enter>",   function() require("noice").redirect(vim.fn.getcmdline()) end,                  mode = "c",                 desc = "Redirect Cmdline" },
    {
      "<leader>sm",
      function()
        require("noice").cmd "telescope"
      end,
      desc = "Noice Telescope",
    },
    {
      "<leader>snl",
      function()
        require("noice").cmd "last"
      end,
      desc = "Noice Last Message",
    },
    {
      "<leader>snh",
      function()
        require("noice").cmd "history"
      end,
      desc = "Noice History",
    },
    {
      "<leader>sna",
      function()
        require("noice").cmd "all"
      end,
      desc = "Noice All",
    },
    {
      "<c-f>",
      function()
        if not require("noice.lsp").scroll(4) then
          return "<c-f>"
        end
      end,
      silent = true,
      expr = true,
      desc = "Scroll forward",
      mode = { "i", "n", "s" },
    },
    {
      "<c-b>",
      function()
        if not require("noice.lsp").scroll(-4) then
          return "<c-b>"
        end
      end,
      silent = true,
      expr = true,
      desc = "Scroll backward",
      mode = { "i", "n", "s" },
    },
  },
}
