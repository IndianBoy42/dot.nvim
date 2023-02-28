local K = {}
-- Use this to control the window that neovim is inside
function K.current_win_listen_on()
  return vim.env.KITTY_LISTEN_ON
end
local defaults = {
  title = "Kitty.nvim",
  match_arg = "id:1",
  cmd_prefix = "Kitty",
  open_cmds = {
    [""] = "",
    IPy = "ipython",
    Bash = "bash",
    Zsh = "zsh",
    Fish = "fish",
    Live = {
      cmd = function(self)
        return "nvim scatch." .. self:repl().file_ending .. ' -c "SnipLive"'
      end,
    },
  },
  send_cmds = {
    [""] = {
      fun = function(self, args)
        self:send(args.args .. "\r")
      end,
    },
    ["Cell"] = "send_cell",
    ["CLine"] = { desc = "Current Line", fun = "send_current_line" },
    ["Word"] = { desc = "Current Word", fun = "send_current_word" },
    ["Lines"] = { fun = "send_range" },
    ["Sel"] = { desc = "Selection", fun = "send_selection" },
    ["File"] = { fun = "send_file" },
  },
}
K.setup = function(cfg)
  cfg = vim.tbl_extend("keep", cfg or {}, defaults)
  cfg.open_cmds = vim.tbl_extend("force", cfg.open_cmds or {}, cfg.user_open_cmds or {})
  cfg.send_cmds = vim.tbl_extend("force", cfg.send_cmds or {}, cfg.user_send_cmds or {})

  local KT = require("kitty.term"):new(cfg)
  KT:setup()

  setmetatable(K, {
    __index = function(m, k)
      local ret = KT[k]
      if type(ret) == "function" then
        m[k] = function(...)
          return ret(KT, ...)
        end
        return m[k]
      else
        return k
      end
    end,
  })
  return K
end
return K
