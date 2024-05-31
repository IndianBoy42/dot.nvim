local M = {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdLineEnter" },
  dependencies = {
    --  { "kdheepak/cmp-latex-symbols",  }
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-calc",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-omni",
    "f3fora/cmp-spell",
    "petertriho/cmp-git",
    "chrisgrieser/cmp_yanky",
    "dmitmel/cmp-cmdline-history",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp-document-symbol",
    "lukas-reineke/cmp-rg",
    "amarakon/nvim-cmp-lua-latex-symbols",
    "hrsh7th/cmp-emoji",
    {
      "tzachar/cmp-fuzzy-buffer",
      dependencies = { "tzachar/fuzzy.nvim" },
    },
    {
      "tzachar/cmp-fuzzy-path",
      dependencies = { "tzachar/fuzzy.nvim" },
        },
"davidsierradz/cmp-conventionalcommits"
  },
}
M.default_sources = {
  { name = "luasnip", group_index = 1 },
  { name = "nvim_lsp", group_index = 1 },
  { name = "buffer", group_index = 1 },
  { name = "path", group_index = 2 }, -- TODO: fuzzy_path
  -- { name = "latex_symbols" , group_index = 2},
  { name = "calc", group_index = 2 },
  -- { name = "cmp_yanky", group_index = 2 },
  -- { name = "cmp_tabnine" , group_index = 2},
  { name = "lua-latex-symbols", group_index = 2 },
  {
    name = "omni",
    group_index = 2,
    option = {
      disable_omnifuncs = { "v:lua.vim.lsp.omnifunc" },
    },
  },
}
M.config = function(_, opts)
  local cmp = require "cmp"
  cmp.setup(opts)

  local compare = require "cmp.config.compare"

  -- `/` cmdline setup.
  cmp.setup.cmdline("/", {
    -- mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources {
      { name = "fuzzy_buffer" },
      { name = "fuzzy_path" },
      -- { name = "nvim_lsp_document_symbol" },
      -- { name = "buffer" },
      { name = "cmdline_history" },
    },
    sorting = {
      priority_weight = 2,
      comparators = {
        require "cmp_fuzzy_buffer.compare",
        compare.offset,
        compare.exact,
        compare.score,
        compare.recently_used,
        compare.kind,
        compare.sort_text,
        compare.length,
        compare.order,
      },
    },
  }) -- `:` cmdline setup.
  cmp.setup.cmdline(":", {
    -- mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources(
      -- { name = "path" },
      { {
        name = "cmdline",
        option = {
          ignore_cmds = { "Man", "!" },
        },
      } },
      { {
        name = "cmdline_history",
      } }
    ),
  })

  require("cmp").setup.filetype("DressingInput", {
    sources = cmp.config.sources { { name = "omni" } },
  })
end

local function t(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end
local feedkeys = vim.api.nvim_feedkeys

-- FIXME: is this wrong?
function M.supertab(when_cmp_visible)
  local cmp = require "cmp"
  local function check_back_space()
    local col = vim.fn.col "." - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match "%s" ~= nil
  end

  return function()
    if cmp.visible() then
      when_cmp_visible()
    elseif require("luasnip").expand_or_jumpable() then
      feedkeys(t "<Plug>luasnip-expand-or-jump", "", false)
    else
      -- local ok, neogen = pcall(require, "neogen")
      -- if ok and neogen.jumpable() then
      -- require'neogen'.jump_next()
      --   feedkeys(t "<cmd>lua require'neogen'.jump_next()<cr>", "", false)
      -- else
      if check_back_space() then
        feedkeys(t "<tab>", "n", false)
      else
        feedkeys(t "<Plug>(Tabout)", "", false)
        -- fallback()
      end
    end
  end
end

M.opts = function()
  local cmp = require "cmp"

  local confirmopts = {
    select = false,
  }
  local cmdline_confirm = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  }

  local function double_mapping(invisible, visible)
    return function()
      if cmp.visible() then
        visible()
      else
        invisible()
      end
    end, {
      "i",
      "s",
      "c",
    }
  end

  local function autocomplete() cmp.complete { reason = cmp.ContextReason.Auto } end

  local function complete_or(mapping) return double_mapping(cmp.complete, mapping) end
  local function next_item()
    if cmp.visible() then
      cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
    elseif require("luasnip").choice_active() then
      feedkeys(t "<Plug>luasnip-next-choice", "", false)
    else
      autocomplete()
    end
  end

  local function prev_item()
    if cmp.visible() then
      cmp.select_prev_item { behavior = cmp.SelectBehavior.Select }
    elseif require("luasnip").choice_active() then
      feedkeys(t "<Plug>luasnip-prev-choice", "", false)
    else
      autocomplete()
    end
  end
  local maps = {

    ["<M-d>"] = cmp.mapping {
      c = cmp.mapping.scroll_docs(-4),
      i = function()
        if not require("noice.lsp").scroll(-4) then cmp.scroll_docs(-4) end
      end,
      s = function()
        if not require("noice.lsp").scroll(-4) then cmp.scroll_docs(-4) end
      end,
    },
    ["<M-u>"] = cmp.mapping {
      c = cmp.mapping.scroll_docs(4),
      i = function()
        if not require("noice.lsp").scroll(4) then cmp.scroll_docs(4) end
      end,
      s = function()
        if not require("noice.lsp").scroll(4) then cmp.scroll_docs(4) end
      end,
    },
    ["<M-k>"] = cmp.mapping {
      i = prev_item,
      c = complete_or(cmp.select_prev_item),
    },
    ["<M-j>"] = cmp.mapping {
      i = next_item,
      c = complete_or(cmp.select_next_item),
    },
    ["<Down>"] = cmp.mapping {
      i = next_item,
      -- c = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
    },
    ["<Up>"] = cmp.mapping {
      i = prev_item,
      -- c = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
    },
    -- ["<M-l>"] = complete_or(function() cmp.confirm(cmdline_confirm) end),
    ["<M-l>"] = cmp.mapping {
      i = function()
        if cmp.visible() then
          cmp.confirm(confirmopts, function() return "<m-l>" end)
        elseif require("luasnip").choice_active() then
          require("plugins.snippets.luasnips_choices").popup_close()
        else
          cmp.complete()
        end
      end,
      c = complete_or(cmp.mapping.confirm(cmdline_confirm, function() return "<m-l>" end)),
    },
    ["<M-h>"] = cmp.mapping {
      i = function()
        if cmp.visible() then cmp.close() end
        if require("luasnip").choice_active() then require("plugins.snippets.luasnips_choices").popup_close() end
      end,
      c = cmp.mapping.close(),
    },
    ["<F1>"] = cmp.mapping {
      i = function()
        if cmp.visible() then
          cmp.confirm(confirmopts, function() return "<m-l>" end)
        elseif require("luasnip").choice_active() then
          require("plugins.snippets.luasnips_choices").popup_close()
        else
          if check_back_space() then
            feedkeys(t "<tab>", "n", false)
          else
            feedkeys(t "<Plug>(Tabout)", "", false)
          end
        end
      end,
      c = cmp.mapping.confirm(cmdline_confirm, function() return "<tab>" end),
      -- i = M.supertab(cmp.mapping.confirm(confirmopts, function() return "<tab>" end)),
    },
    ["<S-TAB>"] = cmp.mapping {
      c = function()
        if cmp.visible() then
          cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
        else
          cmp.complete()
        end
      end,
      i = M.supertab(cmp.select_prev_item),
    },
  }
  maps["<C-j>"] = maps["<M-j>"]
  maps["<C-k>"] = maps["<M-k>"]
  maps["<C-d>"] = maps["<M-d>"]
  maps["<C-u>"] = maps["<M-u>"]
  maps["<C-h>"] = maps["<M-h>"]
  maps["<C-l>"] = maps["<M-l>"]
  maps["<tab>"] = maps["<M-l>"]

  return {
    snippet = {
      expand = function(args) require("luasnip").lsp_expand(args.body) end,
    },
    completion = {
      completeopt = "menu,menuone,noinsert",
      -- autocomplete = true,
    },
    preselect = cmp.PreselectMode.None,
    confirmation = { default_behavior = cmp.ConfirmBehavior.Replace },
    experimental = { ghost_text = true },

    window = {
      documentation = cmp.config.window.bordered {
        border = "rounded",
        winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
        max_width = 120,
        min_width = 60,
        max_height = math.floor(vim.o.lines * 0.3),
        min_height = 1,
      },
    },
    mapping = maps,
    sources = M.default_sources,
  }
end

function M.autocomplete(enable) require("cmp").setup.buffer { completion = { autocomplete = enable } } end

function M.sources(list)
  local cmp = require "cmp"
  if not list then return M.default_sources end
  cmp.setup.buffer { sources = list }
end

return M
