local M = {}
local meta_M = {}
M.setup = function(...)
  return require "hydra" {

    name = "Scroll",
    hint = "",
    config = {
      invoke_on_body = false,
      hint = {
        border = "rounded",
        offset = -1,
      },
    },
    mode = "n",
    body = "z",
    heads = {
      { "h", "zh" },
      { "l", "zl" },
      { "H", "zH" },
      { "L", "zL" },
      { "^", "ze" },
      { "$", "zs" },
      { "j", "<C-y>" },
      { "k", "<C-e>" },
      { "J", "<C-d>" },
      { "K", "<C-u>" },
      { "z", nil, { exit = true, nowait = true, desc = "exit" } },
    },
  }
end
return setmetatable(M, meta_M)
