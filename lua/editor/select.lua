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
  o = "Block, conditional, loop",
  q = "Quote `, \", '",
  t = "Tag",
}
local jump_mappings = function()
  local ai = require "mini.ai"
  local prev_pre = "["
  local next_pre = "]"
  local make_nN_pair = mappings.make_nN_pair
  -- TODO: collapse inner/outer/left/right into one keymap
  local function mapall(desc, id, n, N)
    n = n or id
    N = N or n:upper()
    local ia = "i"
    -- map({ prev_pre, next_pre }, id, "left", { n, N }, "i", desc)
    -- map({ prev_pre, next_pre }, id, "right", { n, N }, "i", desc)
    local lf = function() ai.move_cursor("left", ia, id, { search_method = "cover_or_prev" }) end
    local rf = function() ai.move_cursor("right", ia, id, { search_method = "cover_or_next" }) end
    -- local nf, pf = unpack(make_nN_pair { rf, lf })
    -- vim.keymap.set({ "n", "x", "o" }, prev_pre .. n, pf, { desc = desc })
    -- vim.keymap.set({ "n", "x", "o" }, next_pre .. n, nf, { desc = desc })
    mappings.repeatable(n, desc, { rf, lf }, {})
  end
  mapall("Function", "f", nil, nil)
  mapall("Block", "o", nil, nil)
  mapall("Arg", "a", nil, nil)
  mapall("Call", "c", nil, nil)
  mapall("Tag", "t", nil, nil)
end
local custom_textobjects = function(ai)
  local s = ai.gen_spec
  local ts = s.treesitter

  return {
    ["/"] = ts({ a = "@comment.outer", i = "@comment.inner" }, {}),
    o = ts({
      a = { "@block.outer", "@conditional.outer", "@loop.outer" },
      i = { "@block.inner", "@conditional.inner", "@loop.inner" },
    }, {}),
    -- a = ts({ a = "@parameter.outer", i = "@parameter.inner" }, {}),
    f = ts({ a = "@function.outer", i = "@function.inner" }, {}),
    -- C = ts({ a = "@class.outer", i = "@class.inner" }, {}),
    c = ts({ a = "@call.outer", i = "@call.inner" }, {}),
    -- c = s.function_call(),
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
    -- keys = {
    --   {
    --     "",
    --     function()
    --       require("leap-ast").leap()
    --     end,
    --     mode = { "n", "x", "o" },
    --   },
    -- },
  },
  {
    "mfussenegger/nvim-treehopper",
    config = function()
      local labels = {}
      O.hint_labels:gsub(".", function(c) vim.list_extend(labels, { c }) end)
      require("tsht").config.hint_keys = labels -- Requires https://github.com/mfussenegger/nvim-ts-hint-textobject/pull/2
    end,
    -- event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "m", [[:<C-U>lua require('tsht').nodes()<CR>]], mode = "o" },
      { "m", [[:lua require('tsht').nodes()<CR>]], mode = "x" },
    },
    -- module = "tsht",
  },
}
