return {
  { -- "anuvyklack/pretty-fold.nvim",
    "anuvyklack/pretty-fold.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      sections = {
        left = { "content" },
        right = { " ", "number_of_folded_lines", " " },
      },
      fill_char = " ",
    },
  },
  { -- "kevinhwang91/nvim-ufo",
    -- TODO: figure out why this is so janky
    "kevinhwang91/nvim-ufo",
    cond = false,
    config = function()
      vim.o.foldcolumn = "0" -- '0' is not bad
      vim.o.foldlevel = 9999 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 9999
      vim.o.foldenable = true

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
        -- provider_selector = function() return { "treesitter", "indent" } end,
        fold_virt_text_handler = handler,
      }
      vim.api.nvim_create_autocmd({ "WinNew", "VimEnter" }, {
        pattern = "*",
        callback = function() vim.w.ufo_foldlevel = 1 end,
      })
      vim.keymap.set("n", "zM", function()
        vim.w.ufo_foldlevel = 0
        ufo.closeFoldsWith(vim.w.ufo_foldlevel)
      end)
      vim.keymap.set("n", "zR", function()
        vim.w.ufo_foldlevel = 5
        ufo.closeFoldsWith(vim.w.ufo_foldlevel)
      end)
      vim.keymap.set("n", "zr", function()
        vim.w.ufo_foldlevel = vim.w.ufo_foldlevel + 1
        ufo.closeFoldsWith(vim.w.ufo_foldlevel)
      end)
      vim.keymap.set("n", "zm", function()
        vim.w.ufo_foldlevel = math.max(vim.w.ufo_foldlevel - 1, 0)

        ufo.closeFoldsWith(vim.w.ufo_foldlevel)
      end)
      vim.keymap.set("n", "]z", ufo.goNextClosedFold, { desc = "Closed Fold" })
      vim.keymap.set("n", "[z", ufo.goPreviousClosedFold, { desc = "Closed Fold" })
      vim.keymap.set("n", "zp", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if winid then
          local bufnr = vim.api.nvim_win_get_buf(winid)
          local keys = { "a", "i", "o", "A", "I", "O", "gd", "gr" }
          for _, k in ipairs(keys) do
            -- Add a prefix key to fire `trace` action,
            -- if Neovim is 0.8.0 before, remap yourself
            vim.keymap.set("n", k, "<CR>" .. k, { noremap = false, buffer = bufnr })
          end
        else
          -- coc.nvim
          vim.fn.CocActionAsync "definitionHover"
          -- nvimlsp
          vim.lsp.buf.hover()
        end
      end, { desc = "peekFoldedLinesUnderCursor" })
    end,
    dependencies = "kevinhwang91/promise-async",
    event = { "BufReadPost", "BufNewFile" },
  },
}
