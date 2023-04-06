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
  "T", -- tags
  "q", -- quickfix
  "l", -- loclist
  "i", -- implementation
}
local lsp_lists = {}

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
    last = function() return last end,
    dir = function() return dir end,
  }
  local hint = [[
last: %{last} dir: %{dir}
]]

  local feedkeys = vim.api.nvim_feedkeys
  local termcodes = vim.api.nvim_replace_termcodes
  local function t(k) return termcodes(k, true, true, true) end

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
      function() feedkeys(t("vi" .. last), "m", false) end,
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

  local hydra = Hydra {
    heads = heads,
    name = "Navigate/Select",
    hint = hint,
    body = "<leader>H", -- <leader>j, <leader>k
    config = {
      color = "pink",
      invoke_on_body = true,
      timeout = 2000, -- millis
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

  vim.api.nvim_create_user_command("NaviSel", function() hydra:activate() end, {})
end

M.repeatable = function(ch, desc, fwdbwd, _opts)
  local fwd, bwd = unpack(fwdbwd)
  local feedkeys = vim.api.nvim_feedkeys
  local termcodes = vim.api.nvim_replace_termcodes
  local function t(k) return termcodes(k, true, true, true) end
  local function f(k, mode) return feedkeys(t(k), mode or "m", false) end

  local _opts = _opts or {}
  local opts = {
    name = "Navigate/Select",
    config = {
      color = "red",
      invoke_on_body = false,
      timeout = 2000, -- millis
      hint = {
        border = "rounded",
        type = "window",
        position = "top",
        show_name = false,
      },
    },
    mode = { "n" },
  }

  local fwdfn = type(fwd) == "string" and function() f(fwd, "m") end or fwd
  local bwdfn = type(bwd) == "string" and function() f(bwd, "m") end or bwd
  local c_ch = "<C-" .. ch .. ">"
  -- local c_ch = (ch:upper() == ch) and ch:lower() or ch:upper()
  local m_ch = "<M-" .. ch .. ">" -- add multi cursor at
  local mc_ch = "<M-C-" .. ch .. ">" -- add multi cursor at

  if type(ch) == "table" then
    c_ch = ch[2] or c_ch
    ch = ch[1]
  end
  if _opts.sel then
  end
  local prev_pre, next_pre = O.goto_prev, O.goto_next
  if _opts.body == false then
    prev_pre, next_pre = nil, nil
    _opts.body = nil
  elseif type(_opts.body) == "table" then
    prev_pre, next_pre = unpack(_opts.body)
  end
  utils.dump(_opts)

  -- TODO: use the opposite prefix to sticky reverse direction
  local hydra_fwd, hydra_bwd
  hydra_fwd = require "hydra"(vim.tbl_deep_extend("keep", _opts, {
    body = next_pre,
    on_enter = function() mappings.register_nN_repeat { fwd, bwd } end,
    heads = {
      { c_ch, bwd, { desc = "opposite", private = true } },
      { ch, fwd, { desc = desc } },
      prev_pre and { prev_pre, prev_pre .. ch, { desc = "opposite", private = true, exit_before = true } },
    },
  }, opts))
  hydra_bwd = require "hydra"(vim.tbl_deep_extend("keep", _opts, {
    body = prev_pre,
    on_enter = function() mappings.register_nN_repeat { fwd, bwd } end,
    heads = {
      { c_ch, fwd, { desc = "opposite", private = true } },
      { ch, bwd, { desc = desc } },
      next_pre and { next_pre, next_pre .. ch, { desc = "opposite", private = true, exit_before = true } },
    },
  }, opts))
  return hydra_fwd, hydra_bwd
end

return M
