local M = {}
function M.au_unconceal(level)
  vim.opt_local.conceallevel = level
  utils.define_augroups {
    _lightspeed_unconceal = {
      { "User", "LightspeedEnter", "setlocal conceallevel=0" },
      { "User", "LightspeedExit", "setlocal conceallevel=" .. level },
    },
  }
end

return M
