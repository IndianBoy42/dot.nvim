local ufo = true
local function jump_closed_fold(dir)
  local cmd = "norm! z" .. dir
  local view = vim.fn.winsaveview()
  local l0, l, open = 0, view.lnum, true
  while l ~= l0 and open do
    vim.api.nvim_command(cmd)
    l0, l = l, vim.fn.line "."
    open = vim.fn.foldclosed(l) < 0
  end
  if open then vim.fn.winrestview(view) end
end
return {
  {
    "chrisgrieser/nvim-origami", -- Fold unfold automatically using h/l
    event = "LazyFile", -- later or on keypress would prevent saving folds
    opts = true, -- needed even when using default config
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      capabilities = {
        textDocument = {
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
        },
      },
    },
  },
  { -- "kevinhwang91/nvim-ufo",
    -- TODO: figure out why this is so janky
    "kevinhwang91/nvim-ufo",
    cond = ufo,
    dependencies = "kevinhwang91/promise-async",
    event = "LazyFile",
    init = function()
      --vim.o.foldcolumn = "0" -- '0' is not bad
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
        pattern = "*",
        callback = function()
          vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
          vim.o.foldlevelstart = 99
          vim.o.foldenable = true
        end,
      })
    end,
    config = function()
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ("  %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end

      local ufo = require "ufo"
      ufo.setup {
        -- provider_selector = function() return { "treesitter", "indent" } end, -- If we only use Treesitter
        -- fold_virt_text_handler = handler,
      }
      vim.api.nvim_create_autocmd({ "WinNew", "VimEnter" }, {
        callback = function() vim.w.ufo_foldlevel = 1 end,
      })

      local map = vim.keymap.set
      map("n", "zm", function()
        vim.w.ufo_foldlevel = 0
        ufo.closeFoldsWith(vim.w.ufo_foldlevel)
      end)
      map("n", "zr", function()
        vim.w.ufo_foldlevel = 5
        ufo.openAllFolds()
      end)
      require "hydra" {
        name = "Folds",
        hint = "see [m]ore, [r]educe",
        config = {
          color = "pink",
          invoke_on_body = false,
          hint = {
            float_opts = { border = "rounded" },
            offset = -1,
          },
        },
        mode = "n",
        body = "z",
        heads = {
          {
            "M",
            function()
              if vim.w.ufo_foldlevel == nil then
                vim.w.ufo_foldlevel = 1
              else
                vim.w.ufo_foldlevel = math.max(vim.w.ufo_foldlevel - 1, 0)
              end
              ufo.closeFoldsWith(vim.v.count or vim.w.ufo_foldlevel)
            end,
            { desc = "Close More" },
          },
          {
            "R",
            function()
              if vim.w.ufo_foldlevel == nil then
                vim.w.ufo_foldlevel = 1
              else
                vim.w.ufo_foldlevel = vim.w.ufo_foldlevel + 1
              end
              ufo.closeFoldsWith(vim.v.count or vim.w.ufo_foldlevel)
            end,
            { desc = "Open More" },
          },
          { "h", "zc", { desc = "Close this line" } },
          { "l", "zo", { desc = "Open this line" } },
          { "]", ufo.goNextClosedFold, { desc = "Next Fold" } },
          { "[", ufo.goPreviousClosedFold, { desc = "Previous Fold" } },
          {
            "p",
            function()
              local winid = require("ufo").peekFoldedLinesUnderCursor()
              if winid then
                local bufnr = vim.api.nvim_win_get_buf(winid)
                local keys = { "a", "i", "o", "A", "I", "O", "gd", "gr" }
                for _, k in ipairs(keys) do
                  -- Add a prefix key to fire `trace` action,
                  map("n", k, O.localleader .. k, { noremap = false, buffer = bufnr })
                end
              else
                -- nvimlsp
                vim.lsp.buf.hover()
              end
            end,
          },
        },
      }
      mappings.repeatable("z", "Fold", {
        ufo.goNextClosedFold,
        ufo.goPreviousClosedFold,
      })
    end,
  },
}
