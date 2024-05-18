-- TODO: https://github.com/b0o/incline.nvim
local M = {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    {
      "SmiteshP/nvim-navic",
      opts = {
        lsp = {
          auto_attach = true,
        },
        icons = {
          File = " ",
          Module = " ",
          Namespace = " ",
          Package = " ",
          Class = " ",
          Method = " ",
          Property = " ",
          Field = " ",
          Constructor = " ",
          Enum = " ",
          Interface = " ",
          Function = " ",
          Variable = " ",
          Constant = " ",
          String = " ",
          Number = " ",
          Boolean = " ",
          Array = " ",
          Object = " ",
          Key = " ",
          Null = " ",
          EnumMember = " ",
          Struct = " ",
          Event = " ",
          Operator = " ",
          TypeParameter = " ",
        },
      },
    },
    "marko-cerovac/material.nvim",
  },
}
M.config = function()
  local diagnostics = {
    "diagnostics",
    sources = { "nvim_diagnostic" }, -- nvim is the new more general
    sections = { "error", "warn", "info", "hint" },
    symbols = { error = "E", warn = "W", info = "I", hint = "H" },
  }
  local filename = {
    "filename",
    file_status = true, -- displays file status (readonly status, modified status)
    path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
  }
  local filetype = {
    "filetype",
    colored = true, -- displays filetype icon in color if set to `true`
  }
  local diff = {
    "diff",
    colored = true, -- displays diff status in color if set to true
    -- all colors are in format #rrggbb
    color_added = nil, -- changes diff's added foreground color
    color_modified = nil, -- changes diff's modified foreground color
    color_removed = nil, -- changes diff's removed foreground color
    symbols = { added = "+", modified = "~", removed = "-" }, -- changes diff symbols
  }

  local navic = require "nvim-navic"
  local navic_st = { function() return navic.get_location() end, cond = function() return navic.is_available() end }

  local function get_lsp_clients()
    local msg = "LSP Inactive"
    local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then return msg end
    local lsps = ""
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        -- print(client.name)
        if lsps == "" then
          -- print("first", lsps)
          lsps = client.name
        else
          lsps = lsps .. ", " .. client.name
          break -- Stop at 2 else the statusline explodes
          -- print("more", lsps)
        end
      end
    end
    if lsps == "" then
      return msg
    else
      return lsps
    end
  end

  local function Qmacro()
    -- TODO: get contents of dot register?
    local Q = vim.fn.getreg "q"
    local dot = vim.fn.getreg "."
    return "Q=<" .. Q .. ">, •='" .. dot:sub(1, 10) .. "'"
  end

  local function noice(name)
    local ok, m = pcall(require, "noice")
    if not ok then return end
    local i = m.api.status[name]
    return { function() return i.get_hl() end, cond = function() return i.has() end }
  end

  local luasnip_st = {
    function() return require("luasnip").choice_active() and "LS Choice Active" or "Not LS Choice" end,
    cond = function() return true end,
  }

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "visual_multi_start",
    callback = function() require("lualine").hide() end,
  })

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "visual_multi_exit",
    callback = function() require("lualine").hide { unhide = true } end,
  })

  require("lualine").setup {
    options = {
      icons_enabled = true,
      theme = "onedark",
      -- theme = O.theme,
      -- theme = "molokai",
      -- theme = "catppuccino",
      -- theme = "nebulous",
      -- theme = "onedark",
      -- theme = "tokyonight",
      -- component_separators = { "", "" },
      -- section_separators = { "", "" },
      disabled_filetypes = {},
      globalstatus = true,
    },
    tabline = {},
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        filename,
        navic_st,
      },
      -- lualine_c = { ts_statusline },
      lualine_c = { noice "ruler", noice "command", noice "mode", noice "search" },
      lualine_x = { diagnostics },
      lualine_y = { get_lsp_clients, filetype, "branch", diff },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_a = { filename },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = { diff, diagnostics },
    },
    -- tabline = {},
    extensions = {
      "nvim-tree",
      "fugitive",
    },
  }
end
return M
