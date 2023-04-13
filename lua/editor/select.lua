local legend = {
  [" "] = "Whitespace",
  ['"'] = 'Balanced "',
  ["'"] = "Balanced '",
  ["`"] = "Balanced `",
  ["("] = "Balanced (",
  [")"] = "Balanced ) including white-space",
  [">"] = "Balanced > including white-space",
  ["<lt>"] = "Balanced <",
  ["]"] = "Balanced ] including white-space",
  ["["] = "Balanced [",
  ["}"] = "Balanced } including white-space",
  ["{"] = "Balanced {",
  ["?"] = "User Prompt",
  _ = "Underscore",
  a = "Argument",
  b = "Balanced ), ], }",
  c = "Call",
  f = "Function",
  j = "Expression",
  k = "Block",
  q = "Quote `, \", '",
  t = "Tag",
}
local jump_mappings = function()
  local ai = require "mini.ai"
  local make_nN_pair = mappings.make_nN_pair
  local jump_mode = require "keymappings.jump_mode"
  local function mapall(id, desc, sym)
    desc = desc or legend[id] or ""
    id = id or id
    local move_cursor = ai.move_cursor
    local w = function() move_cursor("left", "i", id, { search_method = "next" }) end
    local e = function() move_cursor("right", "i", id, { search_method = "cover_or_next" }) end
    local b = function() move_cursor("left", "i", id, { search_method = "cover_or_prev" }) end
    local ge = function() move_cursor("right", "i", id, { search_method = "prev" }) end
    local W = function() move_cursor("left", "a", id, { search_method = "next" }) end
    local E = function() move_cursor("right", "a", id, { search_method = "cover_or_next" }) end
    local B = function() move_cursor("left", "a", id, { search_method = "cover_or_prev" }) end
    local gE = function() move_cursor("right", "a", id, { search_method = "prev" }) end
    local vi = function() ai.select_textobject("i", id, { search_method = "cover" }) end
    local va = function() ai.select_textobject("a", id, { search_method = "cover" }) end
    local vin = function() ai.select_textobject("i", id, { search_method = "next" }) end
    local van = function() ai.select_textobject("a", id, { search_method = "next" }) end
    local vip = function() ai.select_textobject("i", id, { search_method = "prev" }) end
    local vap = function() ai.select_textobject("a", id, { search_method = "prev" }) end
    jump_mode.repeatable(id, desc, { w, b, e, ge }, {})
    jump_mode.repeatable(
      id,
      desc,
      { W, B, E, gE },
      { body = { O.goto_next_outer, O.goto_previous_outer, O.goto_next_outer_end, O.goto_previous_outer_end } }
    )
    local hydra = jump_mode.move_by(
      O.goto_prefix .. id,
      jump_mode.move_by_suffixes,
      { w, b, e, ge, W, B, E, gE, vi, va, vin, vip, van, vap },
      desc,
      require("which-key").register({ [id] = desc }, {})
    )
    if sym then
      vim.keymap.set({ "n", "x" }, sym, function() return hydra[1]:activate() end, { desc = desc })
      vim.keymap.set("o", sym, function() return hydra[2]:activate() end, { desc = desc })
    end
  end
  mapall("f", nil, "|")
  mapall("k", nil, "=")
  mapall("a", nil, ",")
  mapall("j", nil, "_")
  mapall "t"
  mapall("b", nil, ")")
  -- mapall "p" -- TODO: paragraph movements
  -- TODO: subword movements
  require("which-key").register({}, {
    mode = "n", -- NORMAL mode
    prefix = O.goto_prefix,
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = false,
    -- silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = false, -- use `nowait` when creating keymaps
  })
end
local custom_textobjects = function(ai)
  local s = ai.gen_spec
  local ts = s.treesitter

  return {
    k = ts({
      a = { "@function.outer", "@block.outer", "@class.outer", "@conditional.outer", "@loop.outer" },
      i = { "@function.inner", "@block.inner", "@class.inner", "@conditional.inner", "@loop.inner" },
    }, {}),
    j = ts({
      a = { "@parameter.outer", "@statement.outer", "@call.outer" },
      i = { "@parameter.inner", "@statement.inner", "@call.inner" },
    }, {}),
    -- a = ts({ a = "@parameter.outer", i = "@parameter.inner" }, {}),
    f = ts({ a = "@function.outer", i = "@function.inner" }, {}),
    -- C = ts({ a = "@class.outer", i = "@class.inner" }, {}),
    c = ts({ a = "@call.outer", i = "@call.inner" }, {}),
    -- c = s.function_call(),
    -- line textobject
    L = function(ai_type)
      local line_num = vim.fn.line "."
      local line = vim.fn.getline(line_num)
      -- Select `\n` past the line for `a` to delete it whole
      local from_col, to_col = 1, line:len() + 1
      if ai_type == "i" then
        if line:len() == 0 then
          -- Don't remove empty line
          from_col, to_col = 0, 0
        else
          -- Ignore indentation for `i` textobject and don't remove `\n` past the line
          from_col = line:match "^%s*()"
          to_col = line:len()
        end
      end
      return { from = { line = line_num, col = from_col }, to = { line = line_num, col = to_col } }
    end,
    e = function(ai_type) return { from = { line = line_num, col = from_col }, to = { line = line_num, col = to_col } } end,
    B = { "%b{}", "^.%s*().-()%s*.$" },
    -- B = function(ai_type)
    --   local n_lines = vim.fn.line "$"
    --   local start_line, end_line = 1, n_lines
    --   if ai_type == "i" then
    --     -- Skip first and last blank lines for `i` textobject
    --     local first_nonblank, last_nonblank = vim.fn.nextnonblank(1), vim.fn.prevnonblank(n_lines)
    --     start_line = first_nonblank == 0 and 1 or first_nonblank
    --     end_line = last_nonblank == 0 and n_lines or last_nonblank
    --   end
    --
    --   local to_col = math.max(vim.fn.getline(end_line):len(), 1)
    --   return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
    -- end,
    C = function(ai_type)
      local line_num = vim.fn.line "."
      local first_line = 1
      local last_line = vim.fn.line "$"
      local line = vim.fn.getline(line_num)
      local cond = function(l)
        if l:len() > 3 then
          if l:sub(1, 4) == "# %%" then return true end
        end
        return false
      end
      local found_up = true

      -- Find first line in cell
      while not cond(line) do
        line_num = line_num - 1
        line = vim.fn.getline(line_num)
        if line_num == 1 then
          found_up = false
          break
        end
      end

      if not found_up then
        local cur_pos = vim.api.nvim_win_get_cursor(0)
        return {
          from = { line = cur_pos[1], col = cur_pos[2] + 1 },
        }
      end

      -- If inside, not include cell delimiter
      if ai_type == "i" then
        first_line = line_num + 1
      else
        first_line = line_num
      end

      -- Find last line in cell
      line_num = vim.fn.line "."
      line = vim.fn.getline(line_num)
      local found_down = true
      while not cond(line) do
        if line_num == last_line then
          found_down = false
          break
        end
        line_num = line_num + 1
        line = vim.fn.getline(line_num)
      end
      local last_col = line:len()
      if found_down then
        last_line = line_num - 1
        line = vim.fn.getline(last_line)
        last_col = math.max(line:len(), 1)
      else
        last_col = math.max(last_col, 1)
      end
      return { from = { line = first_line, col = 1 }, to = { line = last_line, col = last_col } }
    end,
  }
end

return {
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      return {
        n_lines = 500,
        custom_textobjects = custom_textobjects(require "mini.ai"),
        search_method = "cover",
        mappings = {
          around = "a",
          inside = "i",
          around_next = O.select_next, -- TODO: select_first.lua and repeatable
          inside_next = O.select_next_outer,
          around_last = O.select_previous,
          inside_last = O.select_previous_outer,
          goto_left = "",
          goto_right = "",
        },
      }
    end,
    config = function(_, opts)
      local ai = require "mini.ai"
      ai.setup(opts)

      jump_mappings()

      local i = legend

      local a = vim.deepcopy(i)
      for k, v in pairs(a) do
        a[k] = v:gsub(" including.*", "")
      end

      local ic = vim.deepcopy(i)
      local ac = vim.deepcopy(a)
      for key, name in pairs { n = "Next", l = "Last" } do
        i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
        a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
      end
      require("which-key").register {
        mode = { "o", "x" },
        i = i,
        a = a,
      }
    end,
  },
  {
    "camilledejoye/nvim-lsp-selection-range",
    opts = function()
      local lsr_client = require "lsp-selection-range.client"
      return {
        get_client = lsr_client.select_by_filetype(lsr_client.select),
      }
    end,
  },
  {
    "ggandor/leap-ast.nvim",
    keys = {
      -- {
      --   "m",
      --   function() require("leap-ast").leap() end,
      --   mode = { "n", "x", "o" },
      -- },
    },
  },
  { -- TODO:? remove for leap-ast once double sided labelling is implemented
    "mfussenegger/nvim-treehopper",
    config = function() require("tsht").config.hint_keys = O.hint_labels_array end,
    -- event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "m", [[:<C-U>lua require('tsht').nodes()<CR>]], mode = "o" },
      { "m", [[:lua require('tsht').nodes()<CR>]], mode = "x" },
    },
    -- module = "tsht",
  },
}
