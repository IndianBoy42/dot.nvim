local M = {
  -- TODO: break this apart into separate definitions in navedit/
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "theHamsta/nvim-treesitter-pairs",
      "RRethy/nvim-treesitter-textsubjects",
      "nvim-treesitter/nvim-treesitter-refactor",
    },
    config = function()
      -- pcall(require("nvim-treesitter.install").update { with_sync = true })
      local tsconfig = O.treesitter
      local plugconf = O.plugin

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

      local make_nN_pair = mappings.make_nN_pair
      -- local element_nN = make_nN_pair {
      --   require("ts-textobjects/actions").goto_next_element,
      --   require("ts-textobjects/actions").goto_prev_element,
      -- }
      -- local scope_nN = make_nN_pair {
      --   require("ts-textobjects/actions").goto_next_scope,
      --   require("ts-textobjects/actions").goto_prev_scope,
      -- }
      -- local outer_scope_nN = make_nN_pair {
      --   require("ts-textobjects/actions").incremental_outer_scope,
      --   "<cmd>normal! <C-o><cr>",
      -- }

      -- Custom text objects
      -- TODO: Should move the keymappings to keymappings.lua for cleanliness??
      -- TODO: Optimize this
      local textobj_prefixes = tsconfig.textobj_prefixes
      local textobj_suffixes = tsconfig.textobj_suffixes
      local other_suffixes = tsconfig.other_suffixes
      local textobj_sel_keymaps = {}
      local textobj_swap_keymaps = {
        next = { [textobj_prefixes.swap_next .. other_suffixes.element[1]] = "TS Element" },
        previous = { [textobj_prefixes.swap_prev .. other_suffixes.element[1]] = "TS Element" },
      }
      local textobj_move_keymaps = {
        enable = not not plugconf.ts_textobjects,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          -- [textobj_prefixes.goto_next .. other_suffixes.scope[2]] = { outer_scope_nN[1], "Outer Scope" },
          -- [textobj_prefixes.goto_next .. other_suffixes.scope[1]] = { scope_nN[1], "Scope" },
          -- [textobj_prefixes.goto_next .. other_suffixes.element[1]] = { element_nN[1], "TS Element" },
        },
        goto_next_end = {},
        goto_previous_start = {
          -- [textobj_prefixes.goto_next .. other_suffixes.scope[1]] = { scope_nN[2], "Scope" },
          -- [textobj_prefixes.goto_next .. other_suffixes.element[1]] = { element_nN[2], "TS Element" },
        },
        goto_previous_end = {},
      }
      local textobj_move_wrap = true
      for obj, suffix in pairs(textobj_suffixes) do
        local inner = "@" .. obj .. ".inner"
        local outer = "@" .. obj .. ".outer"
        local inners = make_nN_pair {
          function()
            require("nvim-treesitter.textobjects.move").goto_next_start(inner)
          end,
          function()
            require("nvim-treesitter.textobjects.move").goto_previous_start(inner)
          end,
        }
        local outers = make_nN_pair {
          function()
            require("nvim-treesitter.textobjects.move").goto_next_start(outer)
          end,
          function()
            require("nvim-treesitter.textobjects.move").goto_previous_start(outer)
          end,
        }
        local inner_next = { inners[1], "@" .. obj .. ".inner" }
        local inner_prev = { inners[2], "@" .. obj .. ".inner" }
        local outer_next = { outers[1], "@" .. obj .. ".outer" }
        local outer_prev = { outers[2], "@" .. obj .. ".outer" }

        if textobj_prefixes.goto_next ~= nil then
          textobj_move_keymaps.goto_next_start[textobj_prefixes.goto_next .. suffix[1]] = inner_next
          textobj_move_keymaps.goto_next_start[textobj_prefixes.goto_next .. suffix[2]] = outer_next
        end
        if textobj_prefixes.goto_previous ~= nil then
          textobj_move_keymaps.goto_previous_start[textobj_prefixes.goto_previous .. suffix[1]] = inner_prev
          textobj_move_keymaps.goto_previous_start[textobj_prefixes.goto_previous .. suffix[2]] = outer_prev
        end

        if textobj_prefixes.inner ~= nil then
          textobj_sel_keymaps[textobj_prefixes.inner .. suffix[1]] = "@" .. obj .. ".inner"
        end
        if textobj_prefixes.outer ~= nil then
          textobj_sel_keymaps[textobj_prefixes.outer .. suffix[1]] = "@" .. obj .. ".outer"
        end

        if textobj_prefixes.swap_next ~= nil then
          textobj_swap_keymaps.next[textobj_prefixes.swap_next .. suffix[1]] = "@" .. obj .. ".inner"
        end
        if textobj_prefixes.swap_prev ~= nil then
          textobj_swap_keymaps.previous[textobj_prefixes.swap_prev .. suffix[1]] = "@" .. obj .. ".inner"
        end
      end

      -- Add which key menu entries
      local status, wk = pcall(require, "which-key")
      if status then
        local normal = { mode = "n" } -- Normal mode
        local operators = { mode = "o" } -- Operator mode
        local register = wk.register
        register(textobj_sel_keymaps, operators)
        register({
          [plugconf.ts_hintobjects.key] = "Hint Objects",
          ["a" .. other_suffixes.scope[1]] = "Outer Scope",
          ["i" .. other_suffixes.element[1]] = "TS Element",
          ["a" .. other_suffixes.element[1]] = "TS Element",
          ["i" .. other_suffixes.subject[1]] = "Textsubject",
          ["a" .. other_suffixes.subject[1]] = "Textsubject-big",
        }, operators)
        register(textobj_swap_keymaps.next, normal)
        register(textobj_swap_keymaps.previous, normal)
        register({
          -- [textobj_prefixes.swap_next] = "Swap next",
          -- [textobj_prefixes.goto_next] = "Jump [",
          -- [textobj_prefixes.goto_previous] = "Jump ]"
        }, normal)
        register(textobj_move_keymaps.goto_next_start, normal)
        register(textobj_move_keymaps.goto_next_end, normal)
        register(textobj_move_keymaps.goto_previous_start, normal)
        register(textobj_move_keymaps.goto_previous_end, normal)
        if textobj_move_wrap then
          textobj_move_keymaps.goto_next_start = nil
          textobj_move_keymaps.goto_next_end = nil
          textobj_move_keymaps.goto_previous_start = nil
          textobj_move_keymaps.goto_previous_end = nil
        end
      end

      require("nvim-treesitter.configs").setup {
        ensure_installed = tsconfig.ensure_installed, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        ignore_install = tsconfig.ignore_install,
        matchup = {
          enable = not not plugconf.matchup,
          -- disable = { "c", "ruby" },  -- list of language that will be disabled
        },
        pairs = {
          enable = not not plugconf.ts_matchup,
          -- disable = {}, -- list of languages to disable
          highlight_pair_events = { "CursorMoved" }, -- e.g. {"CursorMoved"}, -- when to highlight the pairs, use {} to deactivate highlighting
          highlight_self = false, -- whether to highlight also the part of the pair under cursor (or only the partner)
          goto_right_end = false, -- whether to go to the end of the right partner or the beginning
          -- TODO: call matchup?
          -- fallback_cmd_normal = "call matchit#Match_wrapper('',1,'n')", -- What command to issue when we can't find a pair (e.g. "normal! %")
          -- fallback_cmd_normal = "normal! <Plug>(matchup-%)",
          fallback_cmd_normal = plugconf.matchup and "call matchup#motion#find_matching_pair(0, 1)" or "normal! %",
          keymaps = {
            goto_partner = "%",
          },
        },
        highlight = {
          enable = not not tsconfig.active, -- false will disable the whole extension
          additional_vim_regex_highlighting = tsconfig.additional_vim_regex_highlighting,
          disable = { "latex" },
        },
        context_commentstring = {
          enable = not not plugconf.ts_context_commentstring,
          config = { css = "// %s" },
          enable_autocmd = false,
        },
        -- indent = {enable = true, disable = {"python", "html", "javascript"}},
        -- TODO seems to be broken
        indent = { enable = { "javascriptreact" } },
        autotag = { enable = not not plugconf.ts_autotag },
        textobjects = {
          swap = {
            enable = not not plugconf.ts_textobjects,
            swap_next = textobj_swap_keymaps.next,
            swap_previous = textobj_swap_keymaps.previous,
          },
          move = textobj_move_keymaps,
          select = {
            enable = not not plugconf.ts_textobjects,
            keymaps = textobj_sel_keymaps,
          },
        },
        textsubjects = {
          enable = not not plugconf.ts_textsubjects,
          keymaps = {
            ["i" .. other_suffixes.subject[1]] = "textsubjects-smart",
            ["a" .. other_suffixes.subject[1]] = "textsubjects-container-outer",
          },
        },
        playground = {
          enable = not not plugconf.ts_playground,
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
          enable = not not plugconf.ts_rainbow,
          extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
          max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
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
            enable = true,
            keymaps = {
              goto_definition_lsp_fallback = "gd",
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
        element_textobject = {
          enable = not not plugconf.ts_textobjects,
          keymaps = {
            [textobj_prefixes.swap_next .. other_suffixes.element[1]] = "swap_next_element",
            [textobj_prefixes.swap_prev .. other_suffixes.element[1]] = "swap_prev_element",
            ["i" .. other_suffixes.element[1]] = "inner_element",
            ["a" .. other_suffixes.element[1]] = "an_element", -- around
          },
          set_jumps = true,
        },
        scope_textobject = {
          enable = not not plugconf.ts_textobjects,
          keymaps = {
            ["a" .. other_suffixes.scope[1]] = "a_scope",
          },
          set_jumps = true,
        },
      }

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
