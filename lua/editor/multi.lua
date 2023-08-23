local nvim_feedkeys = vim.api.nvim_feedkeys
local function feedkeys(keys, o)
  if o == nil then o = "m" end
  nvim_feedkeys(vim.keycode(keys), o, false)
end
local function wrap_vm(prefix, vm, suffix)
  prefix = prefix or ""
  vm = vm and ("<Plug>(VM-" .. vm .. ")") or ""
  local first = prefix .. vm
  if suffix == nil then return first end
  return function()
    feedkeys(first, "m")
    -- Defer to avoid `<Plug>(VM-Hls)`
    vim.defer_fn(function()
      if type(suffix) == "function" then suffix = suffix() end
      if type(suffix) == "string" and #suffix > 0 then feedkeys(suffix, "m") end
    end, 200)
  end
end
local function wrap_vm_call(prefix, vm, affix)
  local wrapped = wrap_vm(prefix, vm, affix)
  if type(wrapped) == "function" then wrapped() end
  if type(wrapped) == "string" then feedkeys(wrapped) end
end
local ops = {
  ["g~"] = "~",
  ["v:lua.require'substitute'.operator_callback"] = "p",
  -- ["v:lua.Duplicate.operator"] = "yd",
  -- ["v:lua.MiniSurround.add"] = "ys",
}
local function multiop(select, find)
  return function()
    local register = vim.v.register
    local operator = vim.v.operator
    local rhs = ops[operator] or operator
    local opfunc = vim.go.operatorfunc
    if operator == "g@" then rhs = ops[opfunc] end

    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("after_find_do_op", {}),
      pattern = "visual_multi_after_find",
      once = true,
      callback = function()
        if rhs ~= nil then
          feedkeys('"' .. register .. rhs)
          vim.schedule(function()
            if vim.fn.mode(true) ~= "no" then
              vim.api.nvim_create_autocmd("ModeChanged", {
                group = vim.api.nvim_create_augroup("after_multi_op_exit", {}),
                pattern = "*:n",
                once = true,
                callback = function() feedkeys "<Plug>(VM-Exit)" end,
              })
            else
              feedkeys "<Plug>(VM-Exit)"
            end
          end)
        else
          -- operatorfunc doesnt work in general so youre out of luck
          vim.cmd [[call b:VM_Selection.Edit.run_visual("g@", 1)]]
        end
      end,
    })
    local finish = vim.schedule_wrap(
      function() wrap_vm_call(nil, select and "Find-Subword-Under" or "Find-Under", find) end
    )

    feedkeys("<C-\\><C-n>", "nx")
    feedkeys("<esc>", "n")
    if select then
      _G.__multiop_finish = function()
        feedkeys("`[v`]", "n")
        finish()
      end
      vim.go.operatorfunc = "v:lua.__multiop_finish"
      feedkeys("g@", "n")
    else
      finish()
    end
  end
end

local VM_meta = {}
VM_meta.__index = function(t, k) return setmetatable({ t[1] .. "#" .. k }, VM_meta) end
VM_meta.__call = function(t, ...) return vim.fn[t[0]](...) end
local VM = setmetatable({ "vm" }, VM_meta)

return {
  "IndianBoy42/vim-visual-multi",
  api = VM,
  dev = true,
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
      ["Visual Add"] = "<M-v>",
      -- ["Add Cursor At Pos"] = "+",
      ["Visual Regex"] = "/",
      ["Find Operator"] = "m",
      ["Undo"] = "u",
      ["Redo"] = "<C-r>",
      ["Reselect Last"] = ldr .. ldr,
      ["Transpose"] = "(",
      ["Split Regions"] = "-",
      ["Toggle Mappings"] = "<S-Esc>",
      ["Surround"] = "s",
      -- ["Select Operator"] = ldr .. "s",
      ["Select Operator"] = "<C-v>",
    }
    if ldr == "<Del>" then vim.g.VM_maps["Del"] = "" end
    vim.g.VM_mouse_mappings = true

    local theme = "codedark"
    vim.g.VM_theme = theme
    vim.g.VM_user_operators = {
      "yd",
      "cx",
    }
    vim.g.VM_surround_mapping = "s"
  end,
  config = function()
    -- require("which-key").register(
    --   { [vim.g.VM_leader .. "g"] = "which_key_ignore", [vim.g.VM_leader] = "which_key_ignore" },
    --   { mode = "n" }
    -- )
    vim.cmd.VMTheme(vim.g.VM_theme)
    local ldr = vim.g.VM_leader
    local map = vim.keymap.set
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
    local c_v = vim.keycode "<C-v>"
    map("x", "c", function()
      if vim.api.nvim_get_mode().mode == c_v then
        wrap_vm(nil, "Visual-Add", "c")()
        return ""
      else
        return '"_c'
      end
    end, { expr = true, remap = false })

    map("x", "<C-v>", function()
      local m = vim.api.nvim_get_mode().mode
      if m == c_v or m == "V" then
        return "<Plug>(VM-Visual-Add)"
      else
        -- If same row then go to visual block mode
        if vim.fn.getpos(".")[2] == vim.fn.getpos("v")[2] then
          feedkeys("<c-v>", "n")
          return ""
        else
          return "<Plug>(VM-Visual-Cursors)"
        end
      end
    end, { expr = true })

    -- Multi select object
    local find_under_operator = utils.operatorfunc_keys "<Plug>(VM-Find-Subword-Under)"
    map("n", "<M-v>", find_under_operator, { desc = "Find Under (op)" })
    -- map("n", "m", find_under_operator, { desc = "Find Under (op)" })
    -- Multi select all
    local select_all_operator = utils.operatorfunc_fn(
      vim.schedule_wrap(function() wrap_vm_call(nil, "Find-Subword-Under", "<Plug>(VM-Select-All)") end)
    )
    map("n", "mA", select_all_operator, { desc = "Select all (op)" })
    local select_in_operator = utils.operatorfunc_fn(
      vim.schedule_wrap(function() wrap_vm_call(nil, "Find-Subword-Under", "<Plug>(VM-Find-Operator)") end)
    )
    map("n", "mI", select_in_operator, { desc = "Select (op) in" })
    local add_selection_operator = utils.operatorfunc_keys "<Plug>(VM-Visual-Add)<Plug>(VM-Disable-Mappings)"
    map("n", ldr .. "+", add_selection_operator, { desc = "Add Selection (op)" })
    map("n", ldr .. "r", function()
      add_selection_operator()
      feedkeys("r", "m")
    end, { desc = "Add Selection Remote (op)" })

    map(
      "n",
      ldr .. "I",
      wrap_vm(nil, "Find-Under", "<Plug>(VM-Find-Operator)"),
      { remap = true, desc = "Select word in (motion)" }
    )

    map(
      "n",
      "mo",
      wrap_vm(nil, "Find-Under", "<Plug>(VM-Find-Operator)"),
      { remap = true, desc = "Select all of word" }
    )
    map("n", "mO", wrap_vm(nil, nil, "<Plug>(VM-Select-All)"), { remap = true, desc = "Select all of word" })
    map(
      "x",
      ldr .. "I",
      -- "<Plug>(VM-Find-Subword-Under)<Plug>(VM-Find-Operator)",
      wrap_vm(nil, "Find-Subword-Under", "<Plug>(VM-Find-Operator)"),
      { remap = true, desc = "Select (selection) in (motion)" }
    )

    map("o", "o", multiop(false, "<Plug>(VM-Find-Operator)"), { desc = "op all cword in" })
    map("o", "O", multiop(false, "<Plug>(VM-Select-All)"), { desc = "op all cword" })
    map("o", "I", multiop(true, "<Plug>(VM-Find-Operator)"), { desc = "op all <> in" })
    map("o", "A", multiop(true, "<Plug>(VM-Select-All)"), { desc = "op all of <>" })

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
        map(
          "n",
          "<Plug>(VM-Del)",
          function() require("which-key").show(vim.keycode "<del>", { mode = "n", auto = true }) end
        )
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
  lazy = false,
}
