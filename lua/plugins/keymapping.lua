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
    opts = function()
      local kj = {
        j = {
          -- These can all also be functions
          k = "<Esc>",
          j = "<Esc>",
        },
        k = { j = "<Esc>" },
      }
      return {
        default_mappings = false,
        mappings = {
          i = kj,
          c = kj,
          t = kj,
          -- TODO: investigate if double-esc can be done here
        },
      }
    end,
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
  {
    "tris203/hawtkeys.nvim",
    opts = {
      -- an empty table will work for default config
      --- if you use functions, or whichkey, or lazy to map keys
      --- then please see the API below for options
    },
    cmd = { "Hawtkeys", "HawtkeysAll" },
  },
}
