local prefix = "<localleader>"
local function spectre(name, ...)
  local table = { ... }
  return function() require("spectre")[name](unpack(table)) end
end
return {
  {
    "gbprod/substitute.nvim",
    opts = {},
    keys = function()
      -- Replace selection with register
      local substitute = function(fn, opts)
        return function()
          local substitute = require "substitute"
          substitute[fn](opts)
        end
      end
      -- Replace all in range
      local substitute_range = function(fn, opts)
        opts = vim.tbl_extend("keep", { group_substituted_text = true }, opts or {})
        return function()
          local range = require "substitute.range"
          range[fn](opts)
        end
      end
      local exchange = function(fn, opts)
        return function()
          local exchange = require "substitute.exchange"
          exchange[fn](opts)
        end
      end

      return {
        { "r", substitute "operator", mode = "n", desc = "Replace" },
        {
          "rr",
          substitute "line",
          mode = "n",
          desc = "Replace Line",
        },
        {
          "R",
          substitute "eol",
          mode = "n",
          desc = "Replace EOL",
        },
        { "r", substitute("visual", { yank_substituted_text = true }), mode = "x", desc = "Replace" },
        {
          "<leader>c",
          substitute_range "operator",
          mode = "n",
          desc = "All (motion1) in (motion2)",
        },
        {
          "<leader>C",
          substitute_range("operator", { motion2 = "ie" }),
          mode = "n",
          desc = "All (motion) in file",
        },
        {
          "co",
          -- substitute_range("operator", { motion1 = "iw" }),
          substitute_range "word",
          mode = "n",
          desc = "All iw in (motion)",
        },
        {
          "<leader>rw",
          -- substitute_range("operator", { motion1 = "iw" }),
          substitute_range("word", { motion2 = "ie" }),
          mode = "n",
          desc = "All iw in file",
        },
        {
          "<leader>c",
          substitute_range("visual", {}),
          mode = "x",
          desc = "All (sel) in (motion)",
        },
        {
          "<leader>C",
          substitute_range("visual", { motion2 = "ie" }),
          mode = "x",
          desc = "All (sel) in file",
        },
        { "cx", exchange "operator", mode = "n", desc = "Exchange" },
        { "cxx", exchange "line", mode = "n", desc = "Exchange Line" },
        { "X", exchange "visual", mode = "x", desc = "Exchange" },
        { "cX", exchange "cancel", mode = "n", desc = "Exchange Cancel" },
      }
    end,
  },
  {
    "windwp/nvim-spectre",
    keys = {
      { "<leader>rp", function() require("spectre").open() end, desc = "Project" },
      { "<leader>rf", function() require("spectre").open_file_search { select_word = true } end, desc = "File" },
      { "<leader>rr*", function() require("spectre").open_visual { select_word = true } end, desc = "cword" },
      {
        "<leader>rr/",
        function() require("spectre").open { search_text = vim.fn.getreg "/" } end,
        desc = "Last search",
      },
      {
        "<leader>rr+",
        function() require("spectre").open { search_text = vim.fn.getreg "+" } end,
        desc = "Last yank",
      },
      {
        "<leader>rr.",
        function() require("spectre").open { search_text = vim.fn.getreg "." } end,
        desc = "Last insert",
      },
    },
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
          map = prefix .. "q",
          cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
          desc = "send all item to quickfix",
        },
        ["replace_cmd"] = {
          map = prefix .. "c",
          cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
          desc = "input replace vim command",
        },
        ["show_option_menu"] = {
          map = prefix .. "o",
          cmd = "<cmd>lua require('spectre').show_options()<CR>",
          desc = "show option",
        },
        ["run_replace"] = {
          map = prefix .. prefix,
          cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
          desc = "replace all",
        },
        ["run_current_replace"] = {
          map = prefix .. "r",
          cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
          desc = "replace current line",
        },
        ["change_view_mode"] = {
          map = prefix .. "v",
          cmd = "<cmd>lua require('spectre').change_view()<CR>",
          desc = "change result view mode",
        },
        ["toggle_ignore_case"] = {
          map = prefix .. "i",
          cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
          desc = "toggle ignore case",
        },
        ["toggle_multiline"] = {
          map = prefix .. "m",
          cmd = "<cmd>lua require('spectre').change_options('multiline')<CR>",
          desc = "toggle search hidden",
        },
        ["toggle_ignore_hidden"] = {
          map = prefix .. "h",
          cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
          desc = "toggle search hidden",
        },
        ["toggle_live_update"] = {
          map = prefix .. "u",
          cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
          desc = "update change when vim write file.",
        },
        -- you can put your mapping here it only use normal mode
        ["refresh"] = {
          map = prefix .. "R",
          cmd = "mzggjjA<ESC>'z",
          desc = "refresh the results",
        },
        ["resume_last_search"] = {
          map = prefix .. "l",
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
        close = "q",
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
        mode = { "n", "v" },
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
        function()
          require "inc_rename"
          return ":IncRename " .. vim.fn.expand "<cword>"
        end,
        expr = true,
        desc = "Rename",
      },
    },
    config = true,
  },
}
