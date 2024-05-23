return {
  {
    "MagicDuck/grug-far.nvim",
    opts = {
      keymaps = {
        close = "<C-c>",
      },
    },
    cmd = { "GrugFar" },
    keys = {
      { "<leader>rp", "<cmd>GrugFar<cr>", desc = "GrugFar Project" },
      {
        "<leader>rr*",
        function() require("grug-far").grug_far { prefills = { search = vim.fn.expand "<cword>" } } end,
        desc = "Last search",
      },
      {
        "<leader>rr/",
        function() require("grug-far").grug_far { prefills = { search = vim.fn.getreg "/" } } end,
        desc = "Last search",
      },
      {
        "<leader>rr+",
        function() require("grug-far").grug_far { prefills = { search = vim.fn.getreg "+" } } end,
        desc = "Last yank",
      },
      {
        "<leader>rr.",
        function() require("grug-far").grug_far { prefills = { search = vim.fn.getreg "." } } end,
        desc = "Last insert",
      },
      {
        "<Plug>(GrugFarFile)",
        function() require("grug-far").grug_far { prefills = { flags = vim.fn.expand "%" } } end,
        desc = "GrugFar File",
      },
    },
  },
  {
    "windwp/nvim-spectre",
    keys = {},
    opts = {
      find_engine = {
        -- rg is map with finder_cmd
        ["rg"] = {
          cmd = "rg",
          -- default args
          args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--no-config",
          },
          options = {
            ["ignore-case"] = {
              value = "--ignore-case",
              icon = "[I]",
              desc = "ignore case",
            },
            ["hidden"] = {
              value = "--hidden",
              desc = "hidden file",
              icon = "[H]",
            },
            ["multiline"] = {
              value = "--multiline",
              desc = "multiline search",
              icon = "[M]",
            },
            -- you can put any option you want here it can toggle with
            -- show_option function
          },
        },
      },
      mapping = {
        ["toggle_line"] = {
          map = "d",
          cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
          desc = "toggle current item",
        },
        ["enter_file"] = {
          map = "<cr>",
          cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
          desc = "goto current file",
        },
        -- TODO: ["open_window_picker"] = {
        --   map = "<M-CR>",
        --   cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
        --   desc = "goto current file in",
        -- },
        ["send_to_qf"] = {
          map = "<localleader>q",
          cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
          desc = "send all item to quickfix",
        },
        ["replace_cmd"] = {
          map = "<localleader>c",
          cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
          desc = "input replace vim command",
        },
        ["show_option_menu"] = {
          map = "<localleader>o",
          cmd = "<cmd>lua require('spectre').show_options()<CR>",
          desc = "show option",
        },
        ["run_replace"] = {
          map = "<localleader><localleader>",
          cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
          desc = "replace all",
        },
        ["run_current_replace"] = {
          map = "<localleader>r",
          cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
          desc = "replace current line",
        },
        ["change_view_mode"] = {
          map = "<localleader>v",
          cmd = "<cmd>lua require('spectre').change_view()<CR>",
          desc = "change result view mode",
        },
        ["toggle_ignore_case"] = {
          map = "<localleader>i",
          cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
          desc = "toggle ignore case",
        },
        ["toggle_multiline"] = {
          map = "<localleader>m",
          cmd = "<cmd>lua require('spectre').change_options('multiline')<CR>",
          desc = "toggle search hidden",
        },
        ["toggle_ignore_hidden"] = {
          map = "<localleader>h",
          cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
          desc = "toggle search hidden",
        },
        ["toggle_live_update"] = {
          map = "<localleader>u",
          cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
          desc = "update change when vim write file.",
        },
        -- you can put your mapping here it only use normal mode
        ["refresh"] = {
          map = "<localleader>R",
          cmd = "mzggjjA<ESC>'z",
          desc = "refresh the results",
        },
        ["resume_last_search"] = {
          map = "<localleader>l",
          cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
          desc = "resume last search before close",
        },
      },
      live_update = true,
    },
    config = function(_, opts)
      require("spectre").setup(opts)

      local actions = require "spectre.actions"
      local state = require "spectre.state"
      local Path = require "plenary.path"
      local get_file_path = function(filename)
        -- use default current working directory if state.cwd is nil or empty string
        --
        if state.cwd == nil or state.cwd == "" then state.cwd = vim.fn.getcwd() end

        return vim.fn.expand(state.cwd) .. Path.path.sep .. filename
      end
      function actions.get_file_entry(filename)
        local entries = {}
        for _, item in pairs(state.total_item) do
          if not item.disable and item.filename == filename then
            local t = vim.deepcopy(item)
            t.filename = get_file_path(item.filename)
            table.insert(entries, t)
          end
        end
        return entries
      end
      -- TODO: add support for run replace on file
      actions.run_current_replace_todo = function()
        local entry = actions.get_current_entry()
        if entry then
          M.run_replace { entry }
        else
          local entries = actions.get_file_entry(filename)
          if #entries > 0 then
            M.run_replace(entries)
          else
            vim.notify "Not found any entry to replace."
          end
        end
      end
    end,
  },
  {
    "cshuaimin/ssr.nvim",
    -- Calling setup is optional.
    opts = {
      border = "rounded",
      min_width = 50,
      min_height = 5,
      max_width = 120,
      max_height = 25,
      keymaps = {
        close = "<C-q>",
        next_match = "n",
        prev_match = "N",
        replace_confirm = "<cr>",
        replace_all = "<localleader><cr>",
      },
    },
    keys = {
      {
        "<leader>rr",
        function() require("ssr").open() end,
        mode = { "n", "x" },
        desc = "Treesitter SSR",
      },
    },
  },
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    keys = {
      {
        "<leader>rn",
        function() return ":IncRename " .. vim.fn.expand "<cword>" end,
        expr = true,
        desc = "Rename",
      },
      {
        "rn",
        function() return ":IncRename " .. vim.fn.expand "<cword>" end,
        expr = true,
        desc = "Lsp Rename",
      },
    },
    config = true,
  },
  {
    "AckslD/muren.nvim",
    opts = {},
    keys = {
      { "<leader>rm", function() require("muren.api").toggle_ui() end, desc = "Multi Replace" },
      { "<M-m>", "<cr><cmd>MurenUnique<cr>", mode = "c", desc = "Multi Replace" },
    },
  },
  {
    "gabrielpoca/replacer.nvim",
    keys = {
      { "<leader>rq", utils.lazy_require("replacer").run, desc = "Replace from quickfix" },
      -- TODO: full suite of keymaps
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        callback = function() vim.keymap.setl("n", "i", utils.lazy_require("replacer").run, { desc = "Replacer" }) end,
      })
    end,
  },
}
