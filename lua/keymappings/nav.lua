local M = {}

-- Helper to choose the mode of a keymap
local n = function(o)
  o[3].mode = "n"
  return o
end
local v = function(o)
  o[3].mode = "s"
  return o
end

local textobjs = {
  "f", -- function
  "o", -- block
  "c", -- call
  "a", -- arg
  "b", -- parens, etc
  "t", -- tag
}
local moves = {
  "p", -- paragraph
  "d", -- diags
  "u", -- usages
  "e", -- error
  "T", -- error
}

M.setup = function()
  local Hydra = require "hydra"

  local last = ""
  local dir = "]"
  local odir = function()
    if dir == "[" then
      return "]"
    else
      return "["
    end
  end

  local hintfuncs = {
    last = function()
      return last
    end,
    dir = function()
      return dir
    end,
  }
  local hint = [[
last: %{last} dir: %{dir}
]]

  local feedkeys = vim.api.nvim_feedkeys
  local termcodes = vim.api.nvim_replace_termcodes
  local function t(k)
    return termcodes(k, true, true, true)
  end

  local heads = {
    {
      "/",
      function()
        local last_ = last
        last = "/"
        if last_ == "/" then
          return "n"
        else
          return "/"
        end
      end,
      { expr = true, desc = "search" },
    },
    {
      "h/",
      function()
        last = "/"
        return "<leader>h/"
      end,
      { expr = true, desc = false },
    },
    {
      "?",
      function()
        local last_ = last
        last = "/"
        if last_ == "/" then
          return "N"
        else
          return "?"
        end
      end,
      { expr = true, desc = "search" },
    },
    {
      ",",
      function()
        -- TODO: do this more smart with mini.ai.find_textobject
        -- dir = odir()
        if dir == "]" then
          feedkeys(t("vi" .. last .. "<esc>"), "m", false)
        else
          feedkeys(t("vi" .. last .. "o<esc>"), "m", false)
        end
      end,
      { desc = "toggle" },
    },
    {
      ".",
      function()
        -- dir = odir()
        feedkeys(t("vi" .. last), "m", false)
      end,
      { desc = "toggle" },
    },

    -- TODO: Edits:
    { "mc", "c", { desc = false } },

    -- TODO: Selection:
    {
      "v",
      function()
        feedkeys(t("vi" .. last), "m", false)
      end,
      { desc = "visual" },
    },

    { "q", nil, { exit = true, nowait = true, desc = "exit" } },
    { "<ESC>", nil, { exit = true, nowait = true, desc = "exit" } },
  }
  for _, ch in ipairs(textobjs) do
    -- TODO: call the function directly rather than using feedkeys
    table.insert(heads, {
      ch,
      function()
        last = ch
        dir = "["
        feedkeys(t(dir .. last), "m", false)
      end,
      { desc = ch .. "↓" },
    })
    table.insert(heads, {
      ch,
      function()
        last = ch
        dir = "]"
        feedkeys(t(dir .. last), "m", false)
      end,
      { desc = ch .. "↑" },
    })
  end
  for _, ch in ipairs(moves) do
    table.insert(heads, {
      ch,
      function()
        last = ch
        feedkeys(t(dir .. ch), "m", false)
      end,
      { desc = ch },
    })
  end
  for _, ch in ipairs(require "plugins.navedit.hops") do
    ch = ch[1]
    table.insert(heads, {
      "h" .. ch,
      function()
        last = ch
        feedkeys(t("<leader>h" .. ch), "m", false)
      end,
      { desc = false },
    })
  end

  local hydra = Hydra {
    heads = heads,
    name = "Navigate/Select",
    hint = hint,
    body = "<leader>j", -- <leader>j, <leader>k
    config = {
      color = "pink",
      invoke_on_body = true,
      hint = {
        border = "rounded",
        type = "window",
        position = "top",
        show_name = false,
        funcs = hintfuncs,
      },
    },
    mode = { "n" },
  }

  vim.api.nvim_create_user_command("NaviSel", function()
    hydra:activate()
  end, {})
end

return M
