return {
  legend = {
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
  },
  jumps = function(map)
    local prev_pre = "["
    local next_pre = "]"
    local function mapall(id, n, N, desc)
      n = n or id
      N = N or n:upper()
      map({ prev_pre, next_pre }, id, "left", "a" .. n, "a", desc .. "(a)")
      map({ prev_pre, next_pre }, id, "right", "a" .. N, "a", desc .. "(a)")
      map({ prev_pre, prev_pre }, id, "left", { n, N }, "i", desc)
      map({ next_pre, next_pre }, id, "right", { n, N }, "i", desc)
    end
    mapall("f", nil, nil, "Function")
    mapall("o", nil, nil, "Block")
    mapall("a", nil, nil, "Arg")
    mapall("c", nil, nil, "Call")
    mapall("t", nil, nil, "Tag")
  end,
  custom_surroundings = function()
    local ts_input = require("mini.surround").gen_spec.input.treesitter
    local tsi = function(id) return ts_input { outer = id .. ".outer", inner = id .. ".inner" } end

    return {
      -- With Spaces
      [")"] = { output = { left = "(", right = ")" } },
      ["}"] = { output = { left = "{", right = "}" } },
      ["]"] = { output = { left = "[", right = "]" } },

      c = { input = tsi "@call" },
      f = { input = tsi "@function" },
      B = { input = { "%b{}", "^.%s*().-()%s*.$" }, output = { left = "{ ", right = " }" } },

      -- TODO: jupyter cells
      -- o = {
      --   input = ts_input {
      --     outer = { "@block.outer", "@conditional.outer", "@loop.outer" },
      --     inner = { "@block.inner", "@conditional.inner", "@loop.inner" },
      --   },
      -- },
    }
  end,
  custom_textobjects = function(ai)
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
  end,
}
