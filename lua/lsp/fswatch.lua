-- https://github.com/neovim/neovim/issues/23291#issuecomment-1687088266
local FSWATCH_EVENTS = {
  Created = 1,
  Updated = 2,
  Removed = 3,
  -- Renamed
  OwnerModified = 2,
  AttributeModified = 2,
  MovedFrom = 1,
  MovedTo = 3,
  -- IsFile
  -- IsDir
  -- IsSymLink
  -- Link
  -- Overflow
}

--- @param data string
--- @param opts table
--- @param callback fun(path: string, event: integer)
local function fswatch_output_handler(data, opts, callback)
  local d = vim.split(data, "%s+")
  local cpath = d[1]

  for i = 2, #d do
    if d[i] == "IsDir" or d[i] == "IsSymLink" or d[i] == "PlatformSpecific" then return end
  end

  if opts.include_pattern and opts.include_pattern:match(cpath) == nil then return end

  if opts.exclude_pattern and opts.exclude_pattern:match(cpath) ~= nil then return end

  for i = 2, #d do
    local e = FSWATCH_EVENTS[d[i]]
    if e then callback(cpath, e) end
  end
end

local function fswatch(path, opts, callback)
  local obj = vim.system({
    "fswatch",
    "--recursive",
    "--event-flags",
    "--exclude",
    "/.git/",
    path,
  }, {
    stdout = function(_, data)
      for line in vim.gsplit(data, "\n", { plain = true, trimempty = true }) do
        fswatch_output_handler(line, opts, callback)
      end
    end,
  })

  return function() obj:kill(2) end
end

local ok, wf = pcall(require, "vim.lsp._watchfiles")
return {
  setup = function()
    if ok and vim.fn.executable "fswatch" == 1 then
      wf._watchfunc = fswatch
    end
  end,
  nowatch = function()
    -- https://github.com/neovim/neovim/pull/23500
    if ok then
      -- disable lsp watcher. Too slow on linux
      wf._watchfunc = function()
        return function() end
      end
    end
  end,
}
