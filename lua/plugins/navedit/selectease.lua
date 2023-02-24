return {
  "ziontee113/selectease",
  config = function()
    local se = require "SelectEase"
    -- For more language support check the `Queries` section
    local lua_query = [[
            ;; query
            ((identifier) @cap)
            ("string_content" @cap)
            ((true) @cap)
            ((false) @cap)
        ]]
    local python_query = [[
            ;; query
            ((identifier) @cap)
            ((string) @cap)
        ]]

    local rust_query = [[
    ;; query
    ((boolean_literal) @cap)
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
  ]]

    local queries = {
      lua = lua_query,
      python = python_query,
      rust = rust_query,
    }

    vim.keymap.set({ "n", "s", "i" }, "<C-A-k>", function()
      se.select_node {
        queries = queries,
        direction = "previous",
        vertical_drill_jump = true,
        -- visual_mode = true, -- if you want Visual Mode instead of Select Mode
        fallback = function()
          -- if there's no target, this function will be called
          se.select_node { queries = queries, direction = "previous" }
        end,
      }
    end, {})
    vim.keymap.set({ "n", "s", "i" }, "<C-A-j>", function()
      se.select_node {
        queries = queries,
        direction = "next",
        vertical_drill_jump = true,
        -- visual_mode = true, -- if you want Visual Mode instead of Select Mode
        fallback = function()
          -- if there's no target, this function will be called
          se.select_node { queries = queries, direction = "next" }
        end,
      }
    end, {})

    vim.keymap.set({ "n", "s", "i" }, "<C-A-h>", function()
      se.select_node {
        queries = queries,
        direction = "previous",
        current_line_only = true,
        -- visual_mode = true, -- if you want Visual Mode instead of Select Mode
      }
    end, {})
    vim.keymap.set({ "n", "s", "i" }, "<C-A-l>", function()
      se.select_node {
        queries = queries,
        direction = "next",
        current_line_only = true,
        -- visual_mode = true, -- if you want Visual Mode instead of Select Mode
      }
    end, {})

    -- previous / next node that matches query
    vim.keymap.set({ "n", "s", "i" }, "<C-A-p>", function()
      se.select_node { queries = queries, direction = "previous" }
    end, {})
    vim.keymap.set({ "n", "s", "i" }, "<C-A-n>", function()
      se.select_node { queries = queries, direction = "next" }
    end, {})

    -- Swap Nodes
    vim.keymap.set({ "n", "s", "i" }, "<C-A-S-k>", function()
      se.swap_nodes {
        queries = queries,
        direction = "previous",
        vertical_drill_jump = true,

        -- swap_in_place option. Default behavior is cursor will jump to target after the swap
        -- jump_to_target_after_swap = false --> this will keep cursor in place after the swap
      }
    end, {})
    vim.keymap.set({ "n", "s", "i" }, "<C-A-S-j>", function()
      se.swap_nodes {
        queries = queries,
        direction = "next",
        vertical_drill_jump = true,
      }
    end, {})
    vim.keymap.set({ "n", "s", "i" }, "<C-A-S-h>", function()
      se.swap_nodes {
        queries = queries,
        direction = "previous",
        current_line_only = true,
      }
    end, {})
    vim.keymap.set({ "n", "s", "i" }, "<C-A-S-l>", function()
      se.swap_nodes {
        queries = queries,
        direction = "next",
        current_line_only = true,
      }
    end, {})
    vim.keymap.set({ "n", "s", "i" }, "<C-A-S-p>", function()
      se.swap_nodes { queries = queries, direction = "previous" }
    end, {})
    vim.keymap.set({ "n", "s", "i" }, "<C-A-S-n>", function()
      se.swap_nodes { queries = queries, direction = "next" }
    end, {})
  end,
}
