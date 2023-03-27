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
      ["Select All"] = ldr .. "A",
      ["Find Subword Under"] = "<M-n>",
      ["Add Cursor Down"] = "<M-j>",
      ["Add Cursor Up"] = "<M-k>",
      ["Select Cursor Down"] = "<M-S-j>",
      ["Select Cursor Up"] = "<M-S-k>",
      ["Skip Region"] = "n",
      ["Remove Region"] = "N",
      ["Visual Cursors"] = ldr .. ldr,
      ["Visual Add"] = ldr .. "v",
      ["Visual All"] = ldr .. "a",
      ["Visual Regex"] = "/",
      ["Add Cursor At Pos"] = ldr .. ldr,
      ["Find Operator"] = "m",
      -- ["Visual Find"] = "<M-f>",
      ["Undo"] = "u",
      ["Redo"] = "<C-r>",
      ["Reselect Last"] = ldr .. ldr,
    }

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
    local feedkeys_ = vim.api.nvim_feedkeys
    local termcode = vim.api.nvim_replace_termcodes
    local function feedkeys(keys, o)
      if o == nil then o = "m" end
      feedkeys_(termcode(keys, true, true, true), o, false)
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
          feedkeys(affix, "n")
        end, 100)
      end
    end
    -- map("x", "I", wrap_vm(nil, "Visual-Add", "i"), { remap = true })
    map("x", "I", wrap_vm(nil, "Visual-Add", "i"), { remap = true })
    map("x", "A", wrap_vm(nil, "Visual-Add", "a"), { remap = true })
    local c_v = termcode("<C-v>", true, true, true)
    map("x", "c", function()
      if vim.api.nvim_get_mode().mode == c_v then
        wrap_vm(nil, "Visual-Add", "c")()
        return ""
      else
        return '"_c'
      end
    end, { expr = true, remap = false })

    map("x", "<C-v>", "<Plug>(VM-Visual-Add)")

    local operatorfunc_keys = require("utils").operatorfunc_keys
    -- Multi select object
    local find_under_operator = operatorfunc_keys("multiselect", vim.g.VM_maps["Find Under"])
    map("n", "<M-v>", find_under_operator, {})
    map("n", ldr .. "n", find_under_operator, { desc = "Find Under" })
    -- Multi select all
    local select_all_operator = operatorfunc_keys("multiselect_all", vim.g.VM_maps["Select All"])
    map("n", "<M-S-v>", select_all_operator, {})
    map("n", ldr .. "<S-v>", select_all_operator, {})

    -- map("n", "co", wrap_vm(nil, "Find-Under", "<Plug>(VM-Find-Operator)"), {})
    -- map("n", "co", operatorfunc_keys("find_occurences", "<esc><M-n>mgv"), {})
    -- map("x", "<C-v>", function()      -- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufNewFile" }, { command = "VMTheme " .. theme })
  end,
  event = { "BufWinEnter", "BufEnter" },
}
