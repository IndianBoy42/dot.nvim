return {
  "s1n7ax/nvim-window-picker",
  main = "window-picker",
  -- FYI: local picked_window_id = require('window-picker').pick_window()
  opts = {
    -- selection_chars = O.hint_labels:upper(),
    -- selection_chars = O.hint_labels,
    -- use_winbar = "smart", -- FIXME: this conflicts with virtual text at the top of the window
    show_prompt = false,
  },
  pick = function(cb, opts)
    cb = cb or vim.api.nvim_set_current_win
    local id = require("window-picker").pick_window(opts)
    if id then return cb(id) end
  end,
  pick_or_create = function(cb, opts)
    cb = cb or vim.api.nvim_set_current_win
    local id = require("window-picker").pick_or_create(opts)
    if id then return cb(id) end
  end,
  leap = function(opts, cb) -- kinda meh
    cb = cb or vim.api.nvim_set_current_win

    local setwin = vim.api.nvim_set_current_win
    local getwin = vim.api.nvim_get_current_win
    local curr_win = getwin()
    local hspl = vim.cmd.split
    local vspl = vim.cmd.vsplit
    local make = function(w, spl, new)
      return function()
        setwin(w.winid)
        spl()
        local id = new and getwin() or w.winid
        setwin(curr_win)
        return id
      end
    end
    local floor = math.floor

    local target_windows = require("leap.util").get_enterable_windows()
    local targets = {}
    for _, win in ipairs(target_windows) do
      local w = vim.fn.getwininfo(win)[1]
      table.insert(targets, { pos = { w.topline, 1 }, wininfo = w, winid = w.winid }) -- this window
      -- table.insert(targets, {
      --   pos = { w.topline, floor(w.width / 2) },
      --   wininfo = w,
      --   winid = make(w, hspl, false),
      -- }) -- new window up
      -- table.insert(targets, {
      --   pos = { w.botline, floor(w.width / 2) },
      --   wininfo = w,
      --   winid = make(w, hspl, true),
      -- }) -- new window down
      -- table.insert(targets, {
      --   pos = { floor((w.botline + w.topline) / 2), 1 },
      --   wininfo = w,
      --   winid = make(w, vspl, false),
      -- }) -- new window left
      -- table.insert(targets, {
      --   pos = { floor((w.botline + w.topline) / 2), w.width - 2 },
      --   wininfo = w,
      --   winid = make(w, vspl, true),
      -- }) -- new window right
    end

    require("leap").leap {
      target_windows = target_windows,
      targets = targets,
      action = function(target)
        if type(target.winid) == "function" then target.winid = target.winid() end
        cb(target.winid)
      end,
    }
  end,
}
