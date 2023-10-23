local M = {}
local meta_M = {}
M = setmetatable(M, meta_M)
M.opts = {
  default_textobject = "",
}
M.setup = function(opts)
  if opts then M.opts = vim.tbl_deep_extend("force", M.opts, opts) end
end
local termcodes = vim.api.nvim_replace_termcodes
local function t(k) return termcodes(k, true, true, true) end
local c_v = t "<C-v>"
local esc = t "<Esc>"
local function sort_pos(a, b)
  if a[1] == b[1] then
    if a[2] <= b[2] then
      return a, b
    else
      return b, a
    end
  elseif a[1] < b[1] then
    return a, b
  else
    return b, a
  end
end
local function getpos(expr)
  local p = vim.fn.getpos(expr)
  if not p then error "No position" end
  p = { p[2], p[3] }
  return p
end
local function setpos(expr, pos) vim.fn.setpos(expr, { 0, pos[1], pos[2], 0 }) end
M.intersect = function(opts)
  opts = vim.tbl_deep_extend("keep", opts, M.opts)
  -- TODO: handle modes properly
  -- TODO: handle virtualedit
  local mode = vim.api.nvim_get_mode().mode
  local vis = false
  local start, finis
  if mode == "v" or mode == "V" or mode == c_v then
    vis = true
    start = getpos "v"
    finis = getpos "."
  else
    start = getpos "'<"
    finis = getpos "'>"
  end
  function _G.__intersect_opfunc(type)
    local a, b = getpos "'[", getpos "']"
    a = sort_pos(a, start)
    b = sort_pos(b, finis)

    setpos("'<", a)
    setpos("'>", b)
    vim.cmd "normal! '<v'>"
  end
  vim.go.operatorfunc = "v:lua.__intersect_opfunc"
  vim.api.nvim_feedkeys((vis and esc or "") .. "g@" .. opts.default_textobject, "n", false)
end

return M
