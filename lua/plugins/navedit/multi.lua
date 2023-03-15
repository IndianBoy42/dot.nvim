return {
  "mg979/vim-visual-multi",
  init = function()
    vim.g.VM_maps = nil
    vim.g.VM_leader = "\\"
    vim.g.VM_maps = {
      ["Find Under"] = "<M-n>",
      ["Find Next"] = "<M-n>",
      ["Find Prev"] = "<M-S-n>",
      ["Select All"] = vim.g.VM_leader .. "a",
      ["Find Subword Under"] = "<M-n>",
      ["Add Cursor Down"] = "<M-j>",
      ["Add Cursor Up"] = "<M-k>",
      ["Select Cursor Down"] = "<M-S-j>",
      ["Select Cursor Up"] = "<M-S-k>",
      ["Skip Region"] = "n",
      ["Remove Region"] = "N",
      ["Visual Cursors"] = vim.g.VM_leader .. vim.g.VM_leader,
      ["Visual Add"] = vim.g.VM_leader .. "v",
      ["Visual All"] = vim.g.VM_leader .. "a",
      ["Visual Regex"] = "/",
      ["Add Cursor At Pos"] = "<M-S-n>", -- TODO: better keymap for this?
      ["Find Operator"] = "m",
      -- ["Visual Find"] = "<M-f>",
      ["Undo"] = "u",
      ["Redo"] = "<C-r>",
      ["Reselect Last"] = vim.g.VM_leader .. vim.g.VM_leader,
    }

    local theme = "codedark"
    vim.g.VM_theme = theme
    -- vim.g.VM_leader = [[<leader>m]]
  end,
  config = function()
    require("which-key").register(
      { [vim.g.VM_leader .. "g"] = "which_key_ignore", [vim.g.VM_leader] = "which_key_ignore" },
      { mode = "n" }
    )
    vim.cmd.VMTheme(vim.g.VM_theme)
    local map = vim.keymap.set
    local feedkeys_ = vim.api.nvim_feedkeys
    local termcode = vim.api.nvim_replace_termcodes
    local function feedkeys(keys, o)
      if o == nil then
        o = "m"
      end
      feedkeys_(termcode(keys, true, true, true), o, false)
    end
    local function wrap_vm(prefix, vm, affix)
      prefix = prefix or ""
      local first = prefix .. "<Plug>(VM-" .. vm .. ")"
      if affix == nil then
        return first
      end
      return function()
        feedkeys(first, "m")
        -- Defer to avoid `<Plug>(VM-Hls)`
        vim.defer_fn(function()
          if type(affix) == "function" then
            affix = affix()
          end
          feedkeys(affix, "m")
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
    -- map("x", "<C-v>", function()      -- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufNewFile" }, { command = "VMTheme " .. theme })
  end,
  event = { "BufReadPost", "BufNewFile" },
}
