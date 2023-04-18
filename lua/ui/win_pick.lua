local M = {
  "IndianBoy42/nvim-window-picker",
  main = "window-picker",
  -- FYI: local picked_window_id = require('window-picker').pick_window()
  opts = {
    -- selection_chars = O.hint_labels:upper(),
    -- selection_chars = O.hint_labels,
    -- use_winbar = "smart",
    show_prompt = false,
  },
  pick = function(cb, opts)
    local id = require("window-picker").pick_window(opts)
    if id and type(cb) == "function" then
      return cb(id)
    else
      return id
    end
  end,
  pick_or_create = function(cb, opts)
    local id = require("window-picker").pick_or_create(opts)
    if id and type(cb) == "function" then
      return cb(id)
    else
      return id
    end
  end,
}

M.init = function()
  local function cmd_in_picked(cmd, trans)
    return function(args)
      return M.pick_or_create(function(id)
        vim.api.nvim_set_current_win(id)
        if #args.args > 0 then vim.cmd(trans and trans(args) or args.args) end
      end, {})
    end
  end
  vim.api.nvim_create_user_command("WP", cmd_in_picked(), { nargs = "*" })
  vim.api.nvim_create_user_command(
    "Help",
    cmd_in_picked(function(args) return "help " .. args.args end),
    { nargs = "?" }
  )
end

return M
