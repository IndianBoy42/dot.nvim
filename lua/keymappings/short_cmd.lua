-- eg <Key>wa => :wa<cr>
local nvim_feedkeys = vim.api.nvim_feedkeys
local t = vim.keycode
local function feedkeys(keys, o)
  if o == nil then o = "m" end
  nvim_feedkeys(t(keys), o, false)
end
local getcompl = vim.fn.getcompletion
local aliases = {
  bd = ":Bdelete<cr>",
  bc = ":bdelete<cr>",
  qq = ":quitall<cr>",
  ww = ":writeall<cr>",
  en = ":enew<cr>",
  te = ":Telescope",
  k = function()
    local c = vim.fn.getcharstr()
    return ":k " .. c
  end,
}
local function short_cmd(exlm)
  exlm = exlm or ""
  return function()
    local esc = t "<esc>"
    local cr = t "<cr>"
    local c = ":"
    local e = 0
    local N = 3
    -- TODO: how can I add !
    for i = 1, N do
      -- TODO: timeout?
      local k = vim.fn.getcharstr()
      if k == esc then return end
      c = c .. k
      print(c) -- TODO: better popup? can we use noice.nvim?
      if k == cr then break end
      if i > 1 then
        -- 1  for match with start of a command
        -- 2  full match with a command
        -- 3  matches several user commands
        e = aliases[c:sub(2)] or vim.fn.exists(c)
        if e == 3 then
          -- Continue
        elseif (i > 1 and e ~= 0) or (i == 1 and e == 2) then
          if type(e) == "string" then
            feedkeys(e .. exlm .. "<cr>", "n")
          elseif type(e) == "function" then
            feedkeys(e(exlm), "n")
          else
            feedkeys(c .. exlm .. "<cr>", "n")
          end
          return
        else -- e == 0
          if c == c:lower() then
            -- Try upper the first char
            local c2 = c:gsub("^%l", string.upper)
            e = vim.fn.exists(c2)
            if e == 1 or e == 2 then
              feedkeys(c2 .. exlm .. "<cr>", "n")
              return
            end
          else
            -- TODO: Fuzzy search all possible commands?
          end
        end
      end
    end
    -- Ambiguous after N chars
    -- Let the user complete it manually
    if e == 3 then
      vim.print "Multiple matches"
      feedkeys(c, "n")
    end
  end
end
-- eg <Key>wa => :wa<cr>
return short_cmd
