local surround_mappings = {
  add = "ys", -- Add surrounding in Normal and Visual modes
  vadd = "s", -- Add surrounding in Normal and Visual modes
  delete = "ds", -- Delete surrounding
  find = "]s", -- Find surrounding (to the right)
  find_left = "[s", -- Find surrounding (to the left)
  highlight = "<leader>vs", -- Highlight surrounding
  replace = "cs", -- Replace surrounding
  update_n_lines = "<leader>T<leader>n", -- Update `n_lines`
}
local custom_surroundings = function()
  local ms = require "mini.surround"
  local ts_input = ms.gen_spec.input.treesitter
  local tsi = function(id) return ts_input { outer = id .. ".outer", inner = id .. ".inner" } end

  return {
    -- With Spaces
    [")"] = { output = { left = "(", right = ")" } },
    ["}"] = { output = { left = "{", right = "}" } },
    ["]"] = { output = { left = "[", right = "]" } },

    -- TODO: output
    c = {
      input = tsi "@call",
      output = function()
        local fun_name = MiniSurround.user_input "Function name"
        if fun_name == nil then return nil end
        return { left = ("%s("):format(fun_name), right = ")" }
      end,
    },
    f = { input = tsi "@function" },
    B = { input = { "%b{}", "^.%s*().-()%s*.$" }, output = { left = "{ ", right = " }" } },

    -- o = {
    --   input = ts_input {
    --     outer = { "@block.outer", "@conditional.outer", "@loop.outer" },
    --     inner = { "@block.inner", "@conditional.inner", "@loop.inner" },
    --   },
    -- },
    -- TODO: jupyter cells
  }
end
local M = {
  {
    "abecodes/tabout.nvim",
    event = "InsertEnter",
    config = function()
      local pairs = { "''", '""', "``", "()", "{}", "[]", "||" }
      local opts = {
        tabkey = "<C-l>", -- key to trigger tabout
        backwards_tabkey = "<C-A-l>", -- key to trigger tabout
        act_as_tab = true, -- shift content if tab out is not possible
        completion = true, -- if the tabkey is used in a completion pum
        tabouts = {},
        ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
        exclude = {}, -- tabout will ignore these filetypes
      }
      for i, v in ipairs(pairs) do
        opts.tabouts = vim.list_extend(opts.tabouts, { { open = v:sub(1, 1), close = v:sub(2) } })
      end
      require("tabout").setup(opts)
    end,
  },
  -- TODO: Switch to this?
  -- {
  --   "echasnovski/mini.pairs",
  --   event = "VeryLazy",
  --   config = function(_, opts)
  --     require("mini.pairs").setup(opts)
  --   end,
  -- },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require "nvim-autopairs"
      local R = require "nvim-autopairs.rule"

      npairs.setup {
        disable_filetype = { "tex" },
        ts_config = {
          lua = { "string" }, -- it will not add pair on that treesitter node
          javascript = { "template_string" },
          java = false, -- don't check treesitter on java
        },
        fast_wrap = {},
      }

      -- If you want insert `(` after select function or method item
      local cmp_autopairs = require "nvim-autopairs.completion.cmp"
      local cmp = require "cmp"
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })

      local ts_conds = require "nvim-autopairs.ts-conds"

      npairs.add_rules {
        -- R("%", "%", "lua"):with_pair(ts_conds.is_ts_node { "string", "comment" }),
        -- R("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node { "function" }),
        R("|", "|", "rust"),
        -- R("if ", " then\nend", "lua"):with_pair(ts_conds.is_not_ts_node { "comment", "string" }),
        -- R("for ", " in", "lua"):with_pair(ts_conds.is_not_ts_node { "comment", "string" }),
        -- R("in ", " do", "lua"):with_pair(ts_conds.is_not_ts_node { "comment", "string" }),
        -- R("do ", " end", "lua"):with_pair(ts_conds.is_not_ts_node { "comment", "string" }),
      }

      -- press % => %% is only inside comment or string
      -- TODO:move all of this to luasnip autosnippets cos why not?
      local texmods = {
        -- ["\\left"] = "\\right",
        -- ["\\big"] = "\\big",
        -- ["\\bigg"] = "\\bigg",
        -- ["\\Big"] = "\\Big",
        -- ["\\Bigg"] = "\\Bigg",
      }
      local texpairs = {
        ["|"] = "|",
        ["\\("] = "\\)",
        ["\\["] = "\\]",
        ["\\{"] = "\\}",
        ["\\|"] = "\\|",
        ["\\langle "] = "\\rangle",
        ["\\lceil "] = "\\rceil",
        ["\\lfloor "] = "\\rfloor",
      }
      local basicpairs = {
        ["("] = ")",
        ["["] = "]",
        ["{"] = "}",
        ["."] = "|",
      }
      local cond = require "nvim-autopairs.conds"
      for lm, rm in pairs(texmods) do
        for lp, rp in pairs(texpairs) do
          npairs.add_rule(R(lm .. lp, " " .. rm .. rp, "tex")) --:with_pair(cond.not_after_regex "%w")
        end
        for lp, rp in pairs(basicpairs) do
          npairs.add_rule(R(lm .. lp, " " .. rm .. rp, "tex")) --:with_pair(cond.not_after_regex "%w")
        end
      end
      for lp, rp in pairs(texpairs) do
        -- npairs.add_rule(R(lp, " " .. rp, "tex"))
        npairs.add_rule(R(lp, rp, "tex")) --:with_pair(cond.not_after_regex "%w")
      end
    end,
  },
  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      local mappings = {
        { surround_mappings.add, desc = "Add surrounding" },
        { surround_mappings.vadd, desc = "Add surrounding", mode = { "x" } },
        { surround_mappings.vadd2, desc = "Add surrounding", mode = { "x" } },
        { surround_mappings.delete, desc = "Delete surrounding" },
        { surround_mappings.find, desc = "Find right surrounding" },
        { surround_mappings.find_left, desc = "Find left surrounding" },
        { surround_mappings.highlight, desc = "Highlight surrounding" },
        { surround_mappings.replace, desc = "Replace surrounding" },
        { surround_mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m) return m[1] and #m[1] > 0 end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = function()
      return {
        custom_surroundings = custom_surroundings(),
        mappings = surround_mappings,
        n_lines = 9999,
      }
    end,
    config = function(_, opts)
      require("mini.surround").setup(opts)
      -- Remap adding surrounding to Visual mode selection
      local map = vim.keymap.set
      vim.api.nvim_del_keymap("x", opts.mappings.add)
      map("x", opts.mappings.vadd, [[:<C-u>lua MiniSurround.add('visual')<CR>]], { noremap = true, silent = true })
      if opts.mappings.vadd2 then
        map("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { noremap = true, silent = true })
      end
      -- map("x", "(", opts.mappings.vadd .. [[(]], { remap = true, silent = true })
      -- map("x", "{", opts.mappings.vadd .. [[{]], { remap = true, silent = true })
      -- map("x", "[", opts.mappings.vadd .. [[[]], { remap = true, silent = true })
      -- map("x", '"', opts.mappings.vadd .. [["]], { remap = true, silent = true })
      -- map("x", "'", opts.mappings.vadd .. [[']], { remap = true, silent = true })

      -- Make special mapping for "add surrounding for line"
      map("n", "yss", "ysil", { remap = true, silent = true })
    end,
  },
  -- require("plugins.pairs.sandwich").spec,
}

return M
