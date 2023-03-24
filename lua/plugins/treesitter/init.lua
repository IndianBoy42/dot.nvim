local M = {
  -- TODO: break this apart into separate definitions in navedit/
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        init = function()
          -- We only include this plugin for the queries for mini.ai and hop
          require("lazy.core.loader").disable_rtp_plugin "nvim-treesitter-textobjects"
        end,
      },
      "RRethy/nvim-treesitter-textsubjects",
      -- "nvim-treesitter/nvim-treesitter-refactor",
      {
        "andymass/vim-matchup",
        setup = function()
          -- may set any options here
          vim.g.matchup_matchparen_offscreen = { method = "popup" }
        end,
      },
    },
    opts = {
      ensure_installed = "all",
      ignore_install = {},
      matchup = {
        enable = true,
        -- disable = { "c", "ruby" },  -- list of language that will be disabled
        include_match_words = true,
        disable_virtual_text = false,
      },
      -- pairs = {
      --   enable = true,
      --   -- disable = {}, -- list of languages to disable
      --   highlight_pair_events = { "CursorMoved" }, -- e.g. {"CursorMoved"}, -- when to highlight the pairs, use {} to deactivate highlighting
      --   highlight_self = true, -- whether to highlight also the part of the pair under cursor (or only the partner)
      --   goto_right_end = false, -- whether to go to the end of the right partner or the beginning
      --   -- TODO: call matchup?
      --   -- fallback_cmd_normal = "call matchit#Match_wrapper('',1,'n')", -- What command to issue when we can't find a pair (e.g. "normal! %")
      --   -- fallback_cmd_normal = "normal! <Plug>(matchup-%)",
      --   fallback_cmd_normal = plugconf.matchup and "call matchup#motion#find_matching_pair(0, 1)" or "normal! %",
      --   keymaps = {
      --     goto_partner = "%",
      --   },
      -- },
      highlight = {
        enable = true, -- false will disable the whole extension
        additional_vim_regex_highlighting = { "latex" },
        disable = { "latex" },
      },
      context_commentstring = {
        enable = true,
        config = { css = "// %s" },
        enable_autocmd = false,
      },
      -- indent = {enable = true, disable = {"python", "html", "javascript"}},
      -- TODO seems to be broken
      indent = { enable = { "javascriptreact" } },
      autotag = { enable = true },
      textobjects = {},
      textsubjects = {
        enable = true,
        keymaps = {
          ["<Up>"] = "textsubjects-smart",
          ["."] = "textsubjects-container-outer",
          ["<Down>"] = "textsubjects-container-inner",
        },
      },
      playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
          toggle_query_editor = "o",
          toggle_hl_groups = "i",
          toggle_injected_languages = "t",
          toggle_anonymous_nodes = "a",
          toggle_language_display = "I",
          focus_language = "f",
          unfocus_language = "F",
          update = "R",
          goto_node = "<cr>",
          show_help = "?",
        },
      },
      rainbow = {
        enable = true,
        -- extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
        -- max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
      },
      refactor = {
        smart_rename = {
          enable = true,
          keymaps = {
            smart_rename = "<leader>rt", -- TODO: use my mini window UI for this
          },
        },
        highlight_definitions = { enable = false },
        navigation = {
          enable = false,
          keymaps = {
            goto_definition_lsp_fallback = "<F1>d",
            goto_definition = "<leader>lnd",
            list_definitions = "<leader>lnD",
            -- list_definitions_toc = "gO",
            goto_next_usage = "<leader>lnu",
            goto_previous_usage = "<leader>lnU",
          },
        },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<M-,>",
          node_incremental = "<leader>,",
          node_decremental = "<M-,>",
          scope_incremental = "grc",
        },
      },
    },
    config = function(_, opts)
      -- pcall(require("nvim-treesitter.install").update { with_sync = true })

      -- Custom parsers
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

      parser_config.just = {
        install_info = {
          -- url = "local-tree-sitter/start/tree-sitter-just", -- local path or git repo
          url = "https://github.com/IndianBoy42/tree-sitter-just", -- local path or git repo
          -- url = "~/.local/share/nvim/site/pack/tree-sitter-just", -- local path or git repo
          files = { "src/parser.c", "src/scanner.cc" },
          branch = "main",
        },
        -- filetype = "just", -- if filetype does not agrees with parser name
        -- used_by = {"bar", "baz"} -- additional filetypes that use this parser
        maintainers = { "@IndianBoy42" },
      }

      require("nvim-treesitter.configs").setup(opts)

      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    end,
  },
  {
    "nvim-treesitter/playground",
    cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
  },
}

return M
