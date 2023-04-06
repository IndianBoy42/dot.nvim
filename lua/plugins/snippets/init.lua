local M = {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
      },
    },
    config = function()
      local map = vim.keymap.set
      --  "<Plug>luasnip-expand-or-jump"
      -- map("i", "<C-h>", "<Plug>luasnip-expand-snippet", { silent = true })
      -- map("s", "<C-h>", "<Plug>luasnip-expand-snippet", { silent = true })

      local nvim_feedkeys = vim.api.nvim_feedkeys
      local termcode = vim.api.nvim_replace_termcodes
      local feedkeys = function(keys, o)
        if o == nil then o = "m" end
        nvim_feedkeys(termcode(keys, true, true, true), o, false)
      end
      local luasnip = require "luasnip"
      local cj = function()
        if luasnip.expand_or_jumpable() then
          feedkeys "<Plug>luasnip-jump-next"
        else
          feedkeys "<Plug>(Tabout)"
        end
      end
      local ck = function()
        if luasnip.expand_or_jumpable() then
          feedkeys "<Plug>luasnip-jump-prev"
        else
          feedkeys "<Plug>(TaboutBack)"
        end
      end

      map("i", "<M-n>", cj, { silent = true })
      map("s", "<M-n>", cj, { silent = true })
      map("i", "<M-p>", ck, { silent = true })
      map("s", "<M-p>", ck, { silent = true })
      -- map("i", "<C-u>", require "luasnip.extras.select_choice", { silent = true })
      -- map("i", "<M-n>", "<Plug>luasnip-next-choice", { silent = true })
      map("s", "<M-j>", "<Plug>luasnip-next-choice", { silent = true })
      -- map("i", "<M-p>", "<Plug>luasnip-prev-choice", { silent = true })
      map("s", "<M-k>", "<Plug>luasnip-prev-choice", { silent = true })
      -- map("i", "<C-y>", require("plugins.snippets.luasnips_choices").popup_close, { silent = true })
      map("s", "<M-h>", require("plugins.snippets.luasnips_choices").popup_close, { silent = true })

      map("n", "<M-s>", utils.operatorfunc_keys "<TAB>", { silent = true })
      for _, v in ipairs { "a", "b", "c" } do
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

      -- some shorthands...
      local ls = require "luasnip"
      local t = ls.text_node
      local f = ls.function_node
      local types = require "luasnip.util.types"
      local nl = t { "", "" }
      local function nlt(line) return t { "", line } end
      local function tnl(line) return t { line, "" } end

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
        -- local selected = env.TM_SELECT_TEXT or {}
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
          return dl(ji, lambda.TM_SELECTED_TEXT)
        else
          return lambda(lambda.TM_SELECTED_TEXT)
        end
        -- return f(sel_helper, vim.tbl_extend("force", {}, opts or {}))
      end
      local function dsel(opts)
        return f(function() return sn(nil, { i(1, sel_helper()) }) end, vim.tbl_extend("force", {}, opts or {}))
      end

      local function reg(rn, opts)
        return f(function() return vim.fn.getreg(rn or '"') end, vim.tbl_extend("force", {}, opts or {}))
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
      require("luasnip.loaders.from_lua").lazy_load { paths = _G.CONFIG_PATH .. "/luasnippets" }

      vim.api.nvim_create_user_command("EditSnippets", function(args)
        local args = args.args or "edit!"
        require("luasnip.loaders").edit_snippet_files {
          edit = function(f) vim.cmd(args .. " " .. f) end,
        }
      end, { nargs = "?" })
    end,
  },
  {
    "danymat/neogen",
    cmd = "Neogen",
    opts = {
      enabled = true,
      snippet_engine = "luasnip",
    },
  },
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
        "<leader>ns",
        function() require("SnippetGenie").finalize_snippet() end,
        mode = "n",
        desc = "Genie Finalize",
      },
    },
  },
  {
    "LudoPinelli/comment-box.nvim",
    -- TODO: configure this better
    keys = {
      { "<leader>nbl", "<cmd>CBlbox<r>", desc = "Left Box" },
      { "<leader>nbc", "<cmd>CBcbox<r>", desc = "Center Box" },
    },
    opts = {},
  },
}
return M
