local function load_all()
  require("luasnip.loaders.from_lua").lazy_load()
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip.loaders.from_snipmate").lazy_load()
end
-- TODO https://github.com/TwIStOy/luasnip-snippets/tree/master
local M = {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      { "rafamadriz/friendly-snippets" },
      {
        "benfowler/telescope-luasnip.nvim",
        config = function() require("telescope").load_extension "luasnip" end,
        keys = {
          { "<leader>sP", "<cmd>Telescope luasnip<cr>", desc = "Snippets" },
        },
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
      local jump_next = function()
        if luasnip.expand_or_jumpable() then
          feedkeys "<Plug>luasnip-jump-next"
        else
          feedkeys "<Plug>(Tabout)"
        end
      end
      local jump_prev = function()
        if luasnip.expand_or_jumpable() then
          feedkeys "<Plug>luasnip-jump-prev"
        else
          feedkeys "<Plug>(TaboutBack)"
        end
      end

      map({ "i", "s" }, "<M-n>", jump_next, { silent = true })
      map({ "i", "s" }, "<M-p>", jump_prev, { silent = true })
      -- map("i", "<C-u>", require "luasnip.extras.select_choice", { silent = true })
      -- map("i", "<M-n>", "<Plug>luasnip-next-choice", { silent = true })
      map({ "i", "s" }, "<M-j>", "<Plug>luasnip-next-choice", { silent = true })
      -- map("i", "<M-p>", "<Plug>luasnip-prev-choice", { silent = true })
      map({ "i", "s" }, "<M-k>", "<Plug>luasnip-prev-choice", { silent = true })
      -- map("i", "<C-y>", require("plugins.snippets.luasnips_choices").popup_close, { silent = true })
      if false then
        map("s", "n", jump_next, { silent = true })
        map("s", "p", jump_prev, { silent = true })
        map("s", "j", "<Plug>luasnip-next-choice", { silent = true })
        map("s", "h", require("plugins.snippets.luasnips_choices").popup_close, { silent = true })
        map("s", "k", "<Plug>luasnip-prev-choice", { silent = true })
      end

      map("x", "<M-s>", "S<ESC>", { silent = true })
      map("n", "<M-s>", utils.operatorfunc_keys "<M-s>", { silent = true, expr = true })
      for _, v in ipairs { "a", "b", "c" } do
        map(
          "v",
          "<M-f>" .. v,
          '"' .. v .. "<cmd>lua require('luasnip.extras.otf').on_the_fly('" .. v .. "')<cr>",
          { silent = true, desc = "On the fly: " .. v }
        )

        map(
          "i",
          "<M-f>" .. v,
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
        store_selection_keys = "<Plug>(luasnip-store-selection)",

        ext_opts = {
          [types.choiceNode] = {
            active = { virt_text_pos = "inline", virt_text = { { "●", "GlyphPalette2" } } },
            passive = { virt_text_pos = "inline", virt_text = { { "●", "GlyphPalette2" } } },
          },
          [types.insertNode] = {
            active = { virt_text_pos = "inline", virt_text = { { "●", "GlyphPalette4" } } },
            passive = { virt_text_pos = "inline", virt_text = { { "●", "GlyphPalette4" } } },
          },
          [types.snippet] = {
            active = { virt_text_pos = "inline", virt_text = { { "●", "GlyphPalette4" } } },
            passibe = { virt_text_pos = "inline", virt_text = { { "●", "GlyphPalette4" } } },
          },
        },

        -- https://github.com/L3MON4D3/LuaSnip/blob/master/lua/luasnip/config.lua#L22
        snip_env = {
          sel = sel,
          tnl = tnl,
          nlt = nlt,
          nl = nl,
          reg = reg,
          dsel = dsel,
          ins_generate = function(nodes)
            return setmetatable(nodes or {}, {
              __index = function(table, key)
                local indx = tonumber(key)
                if indx then
                  local val = ls.i(indx)
                  rawset(table, key, val)
                  return val
                end
              end,
            })
          end,
        },
        -- parser_nested_assembler = require "lv-luasnips.nested",
      }

      require("plugins.snippets.luasnips_choices").config()
      -- friendly-snippets - enable standardized comments snippets
      require("luasnip").filetype_extend("typescript", { "tsdoc" })
      require("luasnip").filetype_extend("javascript", { "jsdoc" })
      require("luasnip").filetype_extend("lua", { "luadoc" })
      require("luasnip").filetype_extend("python", { "python-docstring" })
      require("luasnip").filetype_extend("rust", { "rustdoc" })
      require("luasnip").filetype_extend("cs", { "csharpdoc" })
      require("luasnip").filetype_extend("java", { "javadoc" })
      require("luasnip").filetype_extend("sh", { "shelldoc" })
      require("luasnip").filetype_extend("c", { "cdoc" })
      require("luasnip").filetype_extend("cpp", { "cppdoc" })
      require("luasnip").filetype_extend("php", { "phpdoc" })
      require("luasnip").filetype_extend("kotlin", { "kdoc" })
      require("luasnip").filetype_extend("ruby", { "rdoc" })
      load_all()

      vim.api.nvim_create_user_command("EditSnippets", function(args)
        local args = args.args or "edit!"
        require("luasnip.loaders").edit_snippet_files {
          -- format = function(file, source_name)
          --   if source_name == "lua" then
          --     return nil
          --   else
          --     return file:gsub(vim.fn.stdpath "config" .. "/luasnippets", "$LuaSnip")
          --   end
          -- end,
        }
      end, { nargs = "?" })
      vim.api.nvim_create_user_command("ReloadSnippets", function(args) load_all() end, {})
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
    "LudoPinelli/comment-box.nvim",
    -- TODO: configure this better
    keys = {
      { "<leader>nbl", "<cmd>CBlbox<r>", desc = "Left Box" },
      { "<leader>nbc", "<cmd>CBcbox<r>", desc = "Center Box" },
    },
    opts = {},
  },
  -- TODO: https://github.com/chrisgrieser/nvim-scissors
}
return M
