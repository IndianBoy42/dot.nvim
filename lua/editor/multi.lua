return {
  "mg979/vim-visual-multi",
  init = function()
    vim.g.VM_maps = nil
    local ldr = "\\"
    vim.g.VM_leader = ldr
    vim.g.VM_maps = {
      ["Find Under"] = "<M-n>",
      ["Find Next"] = "<M-n>",
      ["Find Prev"] = "<M-S-n>",
      ["Find Subword Under"] = "<M-n>",
      ["Add Cursor Down"] = "<M-j>",
      ["Add Cursor Up"] = "<M-k>",
      ["Select Cursor Down"] = "<M-S-j>",
      ["Select Cursor Up"] = "<M-S-k>",
      ["Skip Region"] = "n",
      ["Remove Region"] = "N",
      ["Visual Cursors"] = ldr .. ldr,
      ["Visual Add"] = "<M-v>",
      ["Visual Regex"] = "/",
      ["Add Cursor At Pos"] = "+",
      ["Find Operator"] = "m",
      ["Undo"] = "u",
      ["Redo"] = "<C-r>",
      ["Reselect Last"] = ldr .. ldr,
      ["Toggle Mappings"] = "-",
      ["Transpose"] = "<M-r>",
    }
    vim.g.VM_mouse_mappings = true

    local theme = "codedark"
    vim.g.VM_theme = theme
  end,
  config = function()
    -- require("which-key").register(
    --   { [vim.g.VM_leader .. "g"] = "which_key_ignore", [vim.g.VM_leader] = "which_key_ignore" },
    --   { mode = "n" }
    -- )
    vim.cmd.VMTheme(vim.g.VM_theme)
    local ldr = vim.g.VM_leader
    local map = vim.keymap.set
    local nvim_feedkeys = vim.api.nvim_feedkeys
    local termcode = vim.api.nvim_replace_termcodes
    local function t(keys) return termcode(keys, true, true, true) end
    local function feedkeys(keys, o)
      if o == nil then o = "m" end
      nvim_feedkeys(t(keys), o, false)
    end
    local function wrap_vm(prefix, vm, affix)
      prefix = prefix or ""
      local first = prefix .. "<Plug>(VM-" .. vm .. ")"
      if affix == nil then return first end
      return function()
        feedkeys(first, "m")
        -- Defer to avoid `<Plug>(VM-Hls)`
        vim.defer_fn(function()
          if type(affix) == "function" then affix = affix() end
          feedkeys(affix, "m")
        end, 200)
      end
    end
    -- map("x", "I", wrap_vm(nil, "Visual-Add", "i"), { remap = true })
    map("x", "I", wrap_vm(nil, "Visual-Add", "i"), { remap = true })
    map("x", "A", wrap_vm(nil, "Visual-Add", "a"), { remap = true })
    local c_v = t "<C-v>"
    map("x", "c", function()
      if vim.api.nvim_get_mode().mode == c_v then
        wrap_vm(nil, "Visual-Add", "c")()
        return ""
      else
        return '"_c'
      end
    end, { expr = true, remap = false })

    map("x", "<C-v>", function()
      if vim.api.nvim_get_mode().mode == c_v then
        return "<Plug>(VM-Visual-Add)"
      else
        return "<Plug>(VM-Visual-Cursors)"
      end
    end, { expr = true })

    -- Multi select object
    local find_under_operator = utils.operatorfunc_keys "<Plug>(VM-Find-Under)"
    map("n", "<M-v>", find_under_operator, {})
    map("n", ldr .. "n", find_under_operator, { desc = "Find Under" })
    -- Multi select all
    local select_all_operator = utils.operatorfunc_keys "<Plug>(VM-Select-All)"
    map("n", "<M-S-v>", select_all_operator, {})
    map("n", ldr .. "<S-v>", select_all_operator, {})

    vim.api.nvim_create_autocmd("User", {
      pattern = "visual_multi_mappings",
      callback = function() end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "visual_multi_start",
      callback = function() end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "visual_multi_end",
      callback = function() end,
    })

    -- map("n", "co", wrap_vm(nil, "Find-Under", "<Plug>(VM-Find-Operator)"), {})
    -- map("n", "co", utils.operatorfunc_keys("<esc><M-n>mgv"), {})
    -- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufNewFile" }, { command = "VMTheme " .. theme })

    -- TODO: https://docs.helix-editor.com/keymap.html#selection-manipulation
  end,
  event = { "BufWinEnter", "BufEnter" },
}
