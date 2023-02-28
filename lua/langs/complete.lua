local default_sources = {
  { name = "luasnip" },
  { name = "nvim_lsp" },
  { name = "copilot" },
  -- { name = "buffer" },
  { name = "path" },
  -- { name = "latex_symbols" },
  { name = "calc" },
  -- { name = "cmp_tabnine" },
}

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
    "dmitmel/cmp-cmdline-history",
    "saadparwaiz1/cmp_luasnip",
  },
}
M.config = function(_, opts)
  local cmp = require "cmp"
  cmp.setup(opts)

  -- `/` cmdline setup.
  cmp.setup.cmdline("/", {
    -- mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    },
  }) -- `:` cmdline setup.
  cmp.setup.cmdline(":", {
    -- mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      {
        name = "cmdline",
        option = {
          ignore_cmds = { "Man", "!" },
        },
      },
    }),
  })
end

function M.supertab(when_cmp_visible)
  local cmp = require "cmp"
  local luasnip = require "luasnip"

  local function t(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  local feedkeys = vim.api.nvim_feedkeys
  local function check_back_space()
    local col = vim.fn.col "." - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match "%s" ~= nil
  end

  return function()
    if cmp.visible() then
      when_cmp_visible()
    elseif luasnip.expand_or_jumpable() then
      feedkeys(t "<Plug>luasnip-expand-or-jump", "", false)
    else
      local ok, neogen = pcall(require, "neogen")
      if ok and neogen.jumpable() then
        feedkeys(t "<cmd>lua require'neogen'.jump_next()<cr>", "", false)
      elseif check_back_space() then
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
    return cmp.mapping(function()
      if cmp.visible() then
        visible()
      else
        invisible()
      end
    end, {
      "i",
      "s",
      "c",
    })
  end

  local function autocomplete()
    cmp.complete { reason = cmp.ContextReason.Auto }
  end

  local function complete_or(mapping)
    return double_mapping(autocomplete, mapping)
  end

  return {
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    completion = {
      completeopt = "menu,menuone,noinsert",
      -- autocomplete = true,
    },
    preselect = cmp.PreselectMode.None,
    -- confirmation = { default_behavior = cmp.ConfirmBehavior.Replace },
    -- experimental = { ghost_text = true },

    window = {
      documentation = cmp.config.window.bordered {
        border = "single",
        winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
        max_width = 120,
        min_width = 60,
        max_height = math.floor(vim.o.lines * 0.3),
        min_height = 1,
      },
    },
    -- TODO: better mapping setup for enter, nextitem and close window
    mapping = {
      ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
      ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
      -- ["<C-p>"] = cmp.mapping.select_prev_item(),
      -- ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-p>"] = complete_or(cmp.select_prev_item),
      ["<C-n>"] = complete_or(cmp.select_next_item),
      ["<Down>"] = cmp.mapping {
        i = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
        c = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
      },
      ["<Up>"] = cmp.mapping {
        i = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
        c = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
      },
      ["<M-l>"] = complete_or(function()
        cmp.confirm(cmdline_confirm)
      end),
      ["<C-space>"] = cmp.mapping {
        i = function()
          cmp.complete()
        end,
      },
      -- TODO: overload this with Luasnip close choice node
      ["<M-h>"] = cmp.mapping(cmp.mapping.close(), { "i", "c" }),
      -- ["<Esc>"] = cmp.mapping(cp.mapping.close(), { "c" }),
      -- ["<Esc>"] = cmp.mapping(cmp.mapping.close(), { "i", "c" }),
      -- ["<Left>"] = cmp.mapping.close(confirmopts),
      -- ["<Right>"] = cmp.mapping {
      --   c = cmp.mapping.confirm(cmdline_confirm),
      -- },
      ["<CR>"] = cmp.mapping {
        -- i = cmp.mapping.confirm(confirmopts),
        i = cmp.mapping.confirm(cmdline_confirm),
        -- c = cmp.mapping.confirm(cmdline_confirm),
      },
      ["<Tab>"] = cmp.mapping {
        c = cmp.mapping.confirm(cmdline_confirm),
        -- i = cmp.mapping.confirm(confirmopts),
        i = M.supertab(cmp.select_next_item),
      },
      ["<S-TAB>"] = cmp.mapping {
        c = function()
          if cmp.visible() then
            cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
          else
            autocomplete()
          end
        end,
        i = M.supertab(cmp.select_prev_item),
      },
    },
    -- You should specify your *installed* sources.
    sources = cmp.config.sources(default_sources),
  }
end

function M.autocomplete(enable)
  require("cmp").setup.buffer { completion = { autocomplete = enable } }
end

function M.sources(list)
  local cmp = require "cmp"
  cmp.setup.buffer { sources = cmp.config.sources(unpack(list)) }
end

function M.add_sources(highprio, lowprio)
  M.sources(vim.list_extend(vim.list_extend({ highprio }, default_sources), { lowprio }))
end

return M
