local M = {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    config = function()
      local map = vim.keymap.set
      --  "<Plug>luasnip-expand-or-jump"
      -- map("i", "<C-h>", "<Plug>luasnip-expand-snippet", { silent = true })
      -- map("s", "<C-h>", "<Plug>luasnip-expand-snippet", { silent = true })

      local feedkeys_ = vim.api.nvim_feedkeys
      local termcode = vim.api.nvim_replace_termcodes
      local feedkeys = function(keys, o)
        if o == nil then
          o = "m"
        end
        feedkeys_(termcode(keys, true, true, true), o, false)
      end
      local luasnip = require "luasnip"
      local cj = function()
        if luasnip.expand_or_jumpable() then
          feedkeys "<Plug>luasnip-jump-next"
        else
          feedkeys "<Plug>(Tabout)"
        end
      end
      map("i", "<C-j>", cj, { silent = true })
      map("s", "<C-j>", cj, { silent = true })
      map("i", "<C-u>", require "luasnip.extras.select_choice", { silent = true })
      map("i", "<C-k>", "<Plug>luasnip-jump-prev", { silent = true })
      map("s", "<C-k>", "<Plug>luasnip-jump-prev", { silent = true })
      map("i", "<M-j>", "<Plug>luasnip-next-choice", { silent = true })
      map("s", "<M-j>", "<Plug>luasnip-next-choice", { silent = true })
      map("i", "<M-k>", "<Plug>luasnip-prev-choice", { silent = true })
      map("s", "<M-k>", "<Plug>luasnip-prev-choice", { silent = true })
      map("i", "<C-y>", require("plugins.snippets.luasnips_choices").popup_close, { silent = true })
      map("s", "<C-y>", require("plugins.snippets.luasnips_choices").popup_close, { silent = true })
      local operatorfunc_keys = require("utils").operatorfunc_keys
      map("n", "<M-s>", operatorfunc_keys("luasnip_select", "<TAB>"), { silent = true })
      for _, v in ipairs { "a", "b", "c" } do
        -- vnoremap <c-f>a  "ac<cmd>lua require('luasnip.extras.otf').on_the_fly()<cr>
        -- inoremap <c-f>a  <cmd>lua require('luasnip.extras.otf').on_the_fly("a")<cr>
        map(
          "v",
          "<C-f>" .. v,
          "\"ac<cmd>lua require('luasnip.extras.otf').on_the_fly()<cr>",
          { silent = true, desc = "On the fly: " .. v }
        )

        map(
          "i",
          "<C-f>" .. v,
          "<cmd>lua require('luasnip.extras.otf').on_the_fly('" .. v .. "')<cr>",
          { silent = true, desc = "On the fly: " .. v }
        )
      end
      vim.api.nvim_create_user_command(
        "LuaSnipEdit",
        require("luasnip.loaders").edit_snippet_files,
        { desc = "Edit LuaSnip Files" }
      )

      -- some shorthands...
      local ls = require "luasnip"
      local t = ls.text_node
      local f = ls.function_node
      local types = require "luasnip.util.types"
      local nl = t { "", "" }
      local function nlt(line)
        return t { "", line }
      end
      local function tnl(line)
        return t { line, "" }
      end

      -- Shorthands for lambdas
      local lambda = require("luasnip.extras").lambda
      lambda.sel = lambda.TM_SELECTED_TEXT
      lambda.re1 = lambda.LS_CAPTURE_1
      lambda.re2 = lambda.LS_CAPTURE_2
      lambda.re3 = lambda.LS_CAPTURE_3
      lambda.re4 = lambda.LS_CAPTURE_4
      lambda.post = lambda.POSTFIX_MATCH

      local function sel_helper(_, snip)
        return snip.env.TM_SELECTED_TEXT or ""
        -- local res, env = {}, snip.env
        -- local selected = env.TM_SELECT_TEXT
        -- if false and (selected == nil or selected == "" or selected == {}) then
        --   res = vim.split(vim.fn.getreg '"', "\n")
        -- else
        --   for _, ele in ipairs(selected) do
        --     table.insert(res, ele)
        --   end
        -- end
        -- return res
      end
      local function sel(ji)
        -- TODO: make this an insert node
        if ji then
          return dl(ji, l.TM_SELECTED_TEXT)
        else
          return l(l.TM_SELECTED_TEXT)
        end
        -- return f(sel_helper, vim.tbl_extend("force", {}, opts or {}))
      end
      local function dsel(opts)
        return f(function()
          return sn(nil, { i(1, sel_helper()) })
        end, vim.tbl_extend("force", {}, opts or {}))
      end

      local function reg(rn, opts)
        return f(function()
          return vim.fn.getreg(rn or '"')
        end, vim.tbl_extend("force", {}, opts or {}))
      end

      require("luasnip").setup {
        history = true,
        enable_autosnippets = true,
        update_events = "TextChanged,TextChangedP,TextChangedI",
        -- region_check_events = "CursorMoved,CursorHold,InsertEnter",
        region_check_events = "CursorMoved,CursorMovedI,InsertEnter",
        -- delete_check_events = "TextChangedI,TextChangedP,TextChanged",
        delete_check_events = "InsertLeave,InsertEnter",
        -- treesitter-hl has 100, use something higher (default is 200).
        ext_base_prio = 300,
        -- minimal increase in priority.
        ext_prio_increase = 1,
        store_selection_keys = "<tab>",

        ext_opts = {
          [types.choiceNode] = { active = { virt_text = { { "●", "GlyphPalette2" } } } },
          [types.insertNode] = { active = { virt_text = { { "●", "GlyphPalette4" } } } },
        },

        snip_env = {
          sel = sel,
          tnl = tnl,
          nlt = nlt,
          nl = nl,
          reg = reg,
          dsel = dsel,
        },
        -- parser_nested_assembler = require "lv-luasnips.nested",
      }

      require("plugins.snippets.luasnips_choices").config()
      require("luasnip.loaders.from_lua").load { paths = _G.CONFIG_PATH .. "/luasnippets" }

      vim.api.nvim_create_user_command("EditSnippets", function()
        require("luasnip.loaders").edit_snippet_files {
          edit = function(f)
            print("edit!" .. f)
            vim.cmd("edit! " .. f)
          end,
        }
      end, {})
    end,
  },
  { import = "plugins.snippets.docs" },
  {
    "ziontee113/SnippetGenie",
    opts = {
      regex = [[-\+ Snippets goes here]],
      -- A line that matches this regex looks like:
      ------------------------------------------------ Snippets goes here

      -- this must be configured
      snippets_directory = _G.CONFIG_PATH .. "/luasnippets/",

      -- let's say you're creating a snippet for Lua,
      -- SnippetGenie will look for the file at `/path/to/my/LuaSnip/snippet/folder/lua/generated.lua`
      -- and add the new snippet there.
      file_name = "generated",
    },
    keys = {
      {
        "<CR>",
        function()
          require("SnippetGenie").create_new_snippet_or_add_placeholder()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "x", true)
        end,
        mode = "x",
      },
      {
        "<leader>S",
        function()
          require("SnippetGenie").finalize_snippet()
        end,
        mode = "n",
        desc = "Genie Finalize",
      },
    },
  },
}
return M
