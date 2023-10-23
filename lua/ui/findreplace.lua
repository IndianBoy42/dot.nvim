local prefix = "<localleader>"
local function spectre(name, ...)
  local table = { ... }
  return function() require("spectre")[name](unpack(table)) end
end
return {
  {
    "gbprod/substitute.nvim",
    dev = true,
    opts = {
      on_substitute = require("yanky.integration").substitute(),
    },
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
        -- TODO: Could use 'yr' for this
        { "r", substitute "operator", mode = "n", desc = "Replace" },
        { "rr", substitute "line", mode = "n", desc = "Replace Line" },
        -- { "R", substitute "eol", mode = "n", desc = "Replace EOL" },
        -- { "r", substitute("visual", { yank_substituted_text = true }), mode = "x", desc = "Replace" },
        -- TODO: fuck these, just use vim-visual-multi?
        {
          "<leader>rI",
          substitute_range "operator",
          mode = "n",
          desc = "Replace all (motion1) in (motion2)",
        },
        {
          "<leader>rA",
          substitute_range("operator", { range = "%" }),
          mode = "n",
          desc = "Replace all (motion) in file",
        },
        {
          "ri",
          substitute_range("visual", {}),
          mode = "x",
          desc = "Replace all (sel) in (motion)",
        },
        -- {
        --   "cr",
        --   substitute_range("visual_range", {
        --     -- text1 = { last_search = true },
        --   }),
        --   mode = { "x", "n" },
        --   desc = "Replace all (motion) in (sel)",
        -- },
        {
          "ra",
          substitute_range("visual", { range = "%" }),
          mode = "x",
          desc = "Replace all (sel) in file",
        },
        {
          "<leader>ro",
          substitute_range "word",
          mode = "n",
          desc = "Replace all iw in (motion)",
        },
        {
          "<leader>rO",
          substitute_range("word", { range = "%" }),
          mode = "n",
          desc = "Replace all iw in file",
        },
        { "cx", exchange "operator", mode = "n", desc = "Exchange" },
        { "cxx", exchange "line", mode = "n", desc = "Exchange Line" },
        { "x", exchange "visual", mode = "x", desc = "Exchange" },
        -- { "<leader>X", exchange "cancel", mode = "n", desc = "Cancel Exchange" },
      }
    end,
  },
  {
    "windwp/nvim-spectre",
    keys = {
      { "<leader>rp", function() require("spectre").open() end, desc = "Spectre Project" },
      {
        "<leader>rf",
        function() require("spectre").open_file_search { select_word = true } end,
        desc = "Spectre File",
      },
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
        function()
          require "inc_rename"
          return ":IncRename " .. vim.fn.expand "<cword>"
        end,
        expr = true,
        desc = "Rename",
      },
      {
        "ru",
        function()
          require "inc_rename"
          return ":IncRename " .. vim.fn.expand "<cword>"
        end,
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
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        callback = function() vim.keymap.setl("n", "i", utils.lazy_require("replacer").run, { desc = "Replacer" }) end,
      })
    end,
  },
  {
    "eugen0329/vim-esearch",
    keys = {
      { "<leader>re", desc = "Esearch", "<Plug>(esearch)" },
      { "<leader>R", desc = "Esearch (op)", "<Plug>(operator-esearch-prefill)" },
    },
    init = function()
      vim.g.esearch = {
        -- default_mappings = 0,
        live_update = 1,
        prefill = { "hlsearch", "last", "clipboard" },
        win_map = {
          { "n", "<C-q>", "<cmd>bdelete<cr>" },
          -- yf    | Yank a hovered file absolute path.
          { "n", "yf", ":call setreg(esearch#util#clipboard_reg(), b:esearch.filename())<cr>" },
          -- t     | Use a custom command to open the file in a tab.
          { "n", "t", ':call b:esearch.open("NewTabdrop")<cr>' },
          -- +     | Render [count] more lines after a line with matches. Ex: + adds 1 line, 10+ adds 10.
          { "n", "<localleader>+", ":call esearch#init(extend(b:esearch, AddAfter(+v:count1)))<cr>" },
          -- -     | Render [count] less lines after a line with matches. Ex: - hides 1 line, 10- hides 10.
          { "n", "<localleader>-", ":call esearch#init(extend(b:esearch, AddAfter(-v:count1)))<cr>" },
          -- gq    | Populate QuickFix list using results of the current pattern search.
          { "n", "<localleader>q", ':call esearch#init(extend(copy(b:esearch), {"out": "qflist"}))<cr>' },
          -- gsp   | Sort the results by path. NOTE that it's search util-specific.
          { "n", "<localleader>sp", ":call esearch#init(extend(b:esearch, esearch_sort_by_path))<cr>" },
          -- gsd   | Sort the results by modification date. NOTE that it's search util-specific.
          { "n", "<localleader>sd", ":call esearch#init(extend(b:esearch, esearch_sort_by_date))<cr>" },
        },
      }
      vim.g.esearch_sort_by_path = { adapters = { rg = { options = "--sort path" } } }
      vim.g.esearch_sort_by_date = { adapters = { rg = { options = "--sort modified" } } }
      vim.cmd [[ let g:AddAfter = {n -> {'after': b:esearch.after + n, 'backend': 'system'}} ]]
    end,
  },
}
