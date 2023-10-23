return {
  {
    "ziontee113/selectease",
    opts = {
      queries = {
        lua = [[
            ;; query
            ((identifier) @cap)
            ("string_content" @cap)
            ((true) @cap)
            ((false) @cap)
        ]],
        python = [[
            ;; query
            ((identifier) @cap)
            ((string) @cap)
        ]],
        rust = [[
            ;; query

            ((string_literal) @cap)

            ; Identifiers
            ((identifier) @cap)
            ((field_identifier) @cap)
            ((field_expression) @cap)
            ((scoped_identifier) @cap)
            ((unit_expression) @cap)

            ; Types
            ((reference_type) @cap)
            ((primitive_type) @cap)
            ((type_identifier) @cap)
            ((generic_type) @cap)

            ; Calls
            ((call_expression) @cap)
  ]],
      },
    },
    config = function(_, opts)
      local se = require "SelectEase"
      local queries = opts.queries
      local modes = { "n", "s", "i" }
      local function o(dir, opts) return vim.tbl_extend("keep", opts or {}, { queries = queries, direction = dir }) end
      local function map(key, fn, dir, opts, desc)
        vim.keymap.set(modes, key, function() se[fn](o(dir, opts)) end, { desc = desc })
      end

      -- TODO: selection first hydra

      -- map("<C-M-k>", "select_node", "previous", {
      --   vertical_drill_jump = true,
      --   visual_mode = true, -- if you want Visual Mode instead of Select Mode
      --   fallback = function() se.select_node(o "previous") end,
      -- }, "Select Previous")
      -- map("<C-M-j>", "select_node", "next", {
      --   vertical_drill_jump = true,
      --   visual_mode = true, -- if you want Visual Mode instead of Select Mode
      --   fallback = function() se.select_node(o "next") end,
      -- }, "Select Previous")
      --
      -- map("<C-M-h>", "select_node", "previous", {
      --   current_line_only = true,
      --   visual_mode = true, -- if you want Visual Mode instead of Select Mode
      -- }, "Select Prev on Line")
      -- map("<C-M-l>", "select_node", "next", {
      --   current_line_only = true,
      --   visual_mode = true, -- if you want Visual Mode instead of Select Mode
      -- }, "Select Next on Line")
      --
      -- -- previous / next node that matches query
      -- map("<C-M-p>", "select_node", "previous")
      -- map("<C-M-n>", "select_node", "next")
      --
      -- -- Swap Nodes
      -- map("<C-M-S-k>", "swap_nodes", "previous", { vertical_drill_jump = true })
      -- map("<C-M-S-j>", "swap_nodes", "next", { vertical_drill_jump = true })
      -- map("<C-M-S-h>", "swap_nodes", "previous", { current_line_only = true })
      -- map("<C-M-S-l>", "swap_nodes", "next", { current_line_only = true })
      -- map("<C-M-S-p>", "swap_nodes", "previous", {})
      -- map("<C-M-S-n>", "swap_nodes", "next", {})
    end,
  },
  -- TODO: https://github.com/drybalka/tree-climber.nvim
  -- TODO: https://github.com/ziontee113/syntax-tree-surfer
}
