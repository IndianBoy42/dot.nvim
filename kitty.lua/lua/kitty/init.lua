local K = {}
local defaults = {
  title = "Kitty.nvim",
}
K.setup = function(cfg)
  cfg = vim.tbl_extend("keep", cfg or {}, defaults)
  local Term = require "kitty.term"
  local KT
  if cfg.from_current_win then
    local CW = require("kitty.current_win").setup()
    KT = CW:sub_window(cfg, cfg.from_current_win)
  else
    KT = Term:new(cfg)
  end

  -- Create the illusion of the global singleton, so can use . rather than :
  setmetatable(K, {
    __index = function(m, k)
      local ret = KT[k]
      if type(ret) == "function" then
        local f = function(...)
          return ret(KT, ...)
        end
        m[k] = f
        return f
      else
        return ret
      end
    end,
  })
  return K
end
return K
