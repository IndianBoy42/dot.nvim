return {
  -- { "liangxianzhe/nap.nvim" },
  {
    "zdcthomas/yop.nvim",
    config = function()
      local function sort(lines, opts)
        -- We don't care about anything non alphanumeric here
        local sort_without_leading_space = function(a, b)
          -- true = a then b
          -- false = b then a
          local pattern = [[^%W*]]
          return string.gsub(a, pattern, "") < string.gsub(b, pattern, "")
        end
        if #lines == 1 then
          -- If only looking at 1 line, sort that line split by some char gotten from imput
          local delimeter = utils.get_input "Delimeter: "
          local split = vim.split(lines[1], delimeter, { trimempty = true })
          -- Remember! `table.sort` mutates the table itself
          table.sort(split, sort_without_leading_space)
          return { utils.join(split, delimeter) }
        else
          -- If there are many lines, sort the lines themselves
          table.sort(lines, sort_without_leading_space)
          return lines
        end
      end

      -- require("yop").op_map({ "n", "v" }, "gs", sort)
    end,
    keys = {
      -- { mode = { "n", "v" }, "gs" },
    },
  },

  {
    "max397574/better-escape.nvim",
    opts = {
      mapping = { "jk", "kj", ";;" },
      keys = "<Esc>",
    },
    event = "InsertEnter",
  },
  "nvimtools/hydra.nvim",
  {
    "indianboy42/keymap-amend.nvim",
    dev = true,
    config = function()
      local a = require "keymap-amend"
      vim.keymap.amend = a.amend
      vim.keymap.get = a.get
    end,
    lazy = false,
  },
}
