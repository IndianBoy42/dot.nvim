local M = {}

local feedkeys = vim.api.nvim_feedkeys
local termcodes = vim.api.nvim_replace_termcodes
local function t(k) return termcodes(k, true, true, true) end
local function f(k, mode) return feedkeys(t(k), mode or "m", false) end

M.repeatable = function(ch, desc, fwdbwd, _opts)
  local fwd, bwd, fwdend, bwdend = unpack(fwdbwd)

  _opts = _opts or {}
  local opts = {
    name = desc,
    config = {
      color = "red",
      invoke_on_body = false,
      timeout = 5000, -- millis
      hint = {
        border = "rounded",
        type = "window",
        position = "top",
        show_name = true,
      },
    },
    mode = { "n", "x", "o" },
  }

  local c_ch, s_ch, cs_ch
  -- local c_ch = (ch:upper() == ch) and ch:lower() or ch:upper()

  if type(ch) == "table" then
    ch, s_ch, c_ch, cs_ch = unpack(ch)
  else
    c_ch = "<C-" .. ch .. ">"
    s_ch = ch:upper()
    cs_ch = "<C-S-" .. ch .. ">"
  end
  local prev_pre, next_pre, prev_end, next_end
  prev_pre, next_pre, prev_end, next_end = O.goto_previous, O.goto_next, O.goto_previous_end, O.goto_next_end
  if _opts.body == false then
    prev_pre, next_pre, prev_end, next_end = nil, nil, nil, nil
    _opts.body = nil
  elseif type(_opts.body) == "table" then
    next_pre, prev_pre, next_end, prev_end = unpack(_opts.body)
    _opts.body = nil
  end
  if not fwdend then next_end = nil end
  if not bwdend then prev_end = nil end

  local cfg = {
    on_enter = function() mappings.register_nN_repeat(fwdbwd) end,
    on_key = function() vim.wait(50) end,
  }

  local hydra_fwd, hydra_bwd, hydra_fwd_end, hydra_bwd_end
  local hydra = require "hydra"

  -- TODO: use the opposite prefix to sticky reverse direction
  hydra_fwd = hydra(vim.tbl_deep_extend("keep", _opts, {
    body = next_pre,
    config = cfg,
    heads = {
      { s_ch, bwd, { desc = "opposite", private = true } },
      { ch, fwd, { desc = desc } },
      fwdend and { c_ch, fwdend, { desc = "end", private = true } },
      bwdend and { cs_ch, bwdend, { desc = "opp end", private = true } },
    },
  }, opts))
  hydra_bwd = hydra(vim.tbl_deep_extend("keep", _opts, {
    body = prev_pre,
    config = cfg,
    heads = {
      { s_ch, fwd, { desc = "opposite", private = true } },
      { ch, bwd, { desc = desc } },
      fwdend and { c_ch, bwdend, { desc = "end", private = true } },
      bwdend and { cs_ch, fwdend, { desc = "opp end", private = true } },
    },
  }, opts))
  hydra_fwd_end = fwdend
    and hydra(vim.tbl_deep_extend("keep", _opts, {
      body = next_end,
      config = cfg,
      heads = {
        { s_ch, bwdend, { desc = "opposite", private = true } },
        { ch, fwdend, { desc = desc } },
        { cs_ch, bwd, { desc = "opp begin", private = true } },
        { c_ch, fwd, { desc = "begin", private = true } },
      },
    }, opts))
  hydra_bwd_end = bwdend
    and hydra(vim.tbl_deep_extend("keep", _opts, {
      body = prev_end,
      config = cfg,
      heads = {
        { cs_ch, fwdend, { desc = "opposite", private = true } },
        { ch, bwdend, { desc = desc } },
        { cs_ch, fwd, { desc = "opp begin", private = true } },
        { c_ch, bwd, { desc = "begin", private = true } },
      },
    }, opts))
  return hydra_fwd, hydra_bwd, hydra_fwd_end, hydra_bwd_end
end

-- M.word_suffixes = { "w", "b", "e", "ge", "W", "B", "E", "gE", "v", "&", "n", "N", "f", "F" }
M.word_suffixes = { "w", "b", "e", "ge", "W", "B", "E", "gE", "vi", "va", "vj", "vk", "vh", "vl" }
M.move_by_descs = M.word_suffixes
M.move_by_suffixes = M.word_suffixes
M.word_suffixes2 = { "w", "b", "e", "<C-e>", "W", "B", "E", "<C-S-e>" }
M.hjkl_suffixes = { "l", "h", "j", "k", "L", "H", "J", "K", "v", ",", "n", "N", "f", "F" }
M.sym_suffixes = {
  O.goto_next,
  O.goto_previous,
  O.goto_next_end,
  O.goto_previous_end,
  "a" .. O.goto_next,
  "a" .. O.goto_previous,
  "a" .. O.goto_next,
  "a" .. O.goto_previous,
  O.select,
  O.select_outer,
  O.select_next,
  O.select_previous,
  "a" .. O.select_next,
  "a" .. O.select_previous,
}

-- TODO: more of this, better selection mappings for repeats
M.move_by = function(prefix, suffixes, actions, desc, o)
  o = o or {}

  local descs = o.descs or M.move_by_descs
  local opts = {
    name = desc,
    config = {
      color = "red",
      invoke_on_body = false,
      -- timeout = 5000, -- millis
      hint = {
        border = "rounded",
        type = "window",
        position = "top",
        show_name = true,
      },
      on_enter = function() mappings.register_nN_repeat(actions) end,
      on_key = function() vim.wait(50) end,
    },
    mode = { "n", "x" },
  }

  local hydras = {}
  if #prefix == 0 or prefix == false then prefix = nil end
  local heads = {}
  for j, suffix in ipairs(suffixes) do
    heads[j] = {
      suffix,
      actions[j],
      { desc = descs[j], private = false },
    }
  end
  local Hydra = require "hydra"

  hydras[1] = Hydra(vim.tbl_extend("keep", {
    body = (#prefix > 0) and prefix,
    heads = heads,
  }, opts))

  hydras[2] = Hydra(vim.tbl_extend("keep", {
    body = (#prefix > 0) and prefix,
    heads = vim.tbl_map(function(x)
      local a = x[2]
      x[2] = function()
        vim.cmd "normal! v"
        a()
      end
      return x
    end, heads),
    mode = "o",
  }, opts))

  return hydras
end

return M
