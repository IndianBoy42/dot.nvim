return {
  "mg979/vim-visual-multi",
  init = function()
    vim.g.VM_maps = nil
    -- local ldr = "\\"
    local ldr = "<Del>" -- FIXME: a little buggy
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
      -- ["Visual Add"] = "+",
      -- ["Add Cursor At Pos"] = "+",
      ["Visual Regex"] = "/",
      ["Find Operator"] = "m",
      ["Undo"] = "u",
      ["Redo"] = "<C-r>",
      ["Reselect Last"] = ldr .. ldr,
      ["Transpose"] = "(",
      ["Visual Subtract"] = "_",
      ["Split Regions"] = "_",
      ["Toggle Mappings"] = "-",
    }
    if ldr == "<Del>" then vim.g.VM_maps["Del"] = "" end
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
        if type(affix) == "function" then affix = affix() end
        -- Defer to avoid `<Plug>(VM-Hls)`
        vim.defer_fn(function() feedkeys(affix, "m") end, 200)
      end
    end
    -- map("x", "I", wrap_vm(nil, "Visual-Add", "i"), { remap = true })
    map(
      "n",
      "+",
      "<Plug>(VM-Add-Cursor-At-Pos)<Plug>(VM-Disable-Mappings)",
      { remap = true, desc = "Add Cursor At Pos" }
    )
    map("x", "+", "<Plug>(VM-Visual-Add)<Plug>(VM-Disable-Mappings)", { remap = true, desc = "Add Region" })
    map("x", "-", "<Plug>(VM-Visual-Add)<Plug>(VM-Split-Regions)", { remap = true, desc = "Split Visual Region" })
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
    local find_under_operator = utils.operatorfunc_keys "<Plug>(VM-Find-Subword-Under)"
    map("n", "<M-v>", find_under_operator, { desc = "Find Under (op)" })
    map("n", "ms", find_under_operator, { desc = "Find Under (op)" })
    -- Multi select all
    local select_all_operator = utils.operatorfunc_keys "<Plug>(VM-Visual-Add)<Plug>(VM-Select-All)"
    map("n", "<M-S-v>", select_all_operator, { desc = "Select all (op)" })
    map("n", "mS", select_all_operator, { desc = "Select all (op)" })
    local add_selection_operator = utils.operatorfunc_keys "<Plug>(VM-Visual-Add)<Plug>(VM-Disable-Mappings)"
    map("n", "ma", add_selection_operator, { desc = "Add Selection (op)" })
    map("n", "mr", function()
      add_selection_operator()
      feedkeys("r", "m")
    end, { desc = "Add Selection (op)" })

    map("n", "mo", wrap_vm(nil, "Find-Under", "<Plug>(VM-Find-Operator)"), { remap = true })

    -- map("n", ldr .. "n", "<Plug>(VM-Start-Regex-Search)<C-r>/<cr>", { desc = "Select all (op)" })
    map(
      "n",
      ldr .. "n",
      wrap_vm(nil, "Start-Regex-Search", function() return vim.fn.getreg "/" .. "<cr>" end),
      { desc = "From last search" }
    )

    vim.api.nvim_create_autocmd("User", {
      pattern = "visual_multi_mappings",
      callback = function()
        map("n", "<Plug>(VM-Del)", function() require("which-key").show(t "<del>", { mode = "n", auto = true }) end)
        map("n", "<Plug>(VM-Motion-()", "<Plug>(VM-Transpose)")
        map("n", "<Plug>(VM-Motion-))", "<Plug>(VM-Transpose)")
      end,
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
    map("n", "<Plug>(VM-Disable-Mappings)", ":call b:VM_Selection.Maps.disable(1)<cr>", { silent = true })
    map("n", "<Plug>(VM-Enable-Mappings)", ":call b:VM_Selection.Maps.enable()<cr>", { silent = true })
    map("n", "<Plug>(VM-Motion-()", "<Plug>(VM-Transpose)")
  end,
  event = { "BufWinEnter", "BufEnter" },
}
