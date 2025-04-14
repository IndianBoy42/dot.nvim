local nvim_feedkeys = vim.api.nvim_feedkeys
local function feedkeys(keys, o)
  if o == nil then o = "m" end
  nvim_feedkeys(vim.keycode(keys), o, false)
end
local function wrap_vm(prefix, vm, suffix)
  prefix = prefix or ""
  vm = vm and ("<Plug>(VM-" .. vm .. ")") or ""
  local first = vm
  if suffix == nil then return first end
  return function()
    if type(prefix) == "function" then prefix = prefix() end
    if type(prefix) == "string" then first = prefix .. first end
    feedkeys(first, "m")
    -- Defer to avoid `<Plug>(VM-Hls)`
    vim.defer_fn(function()
      if type(suffix) == "function" then suffix = suffix() end
      if type(suffix) == "string" and #suffix > 0 then feedkeys(suffix, "m") end
      -- HACK: tune this value
    end, 200)
  end
end
local function wrap_vm_call(prefix, vm, affix)
  local wrapped = wrap_vm(prefix, vm, affix)
  if type(wrapped) == "function" then wrapped() end
  if type(wrapped) == "string" then feedkeys(wrapped) end
end
-- TODO: implement custom operators in core
local ops = {
  ["g~"] = "~",
  ["v:lua.require'substitute'.operator_callback"] = '"_p',
  ["v:lua.Duplicate.operator"] = "D",
  ["v:lua.MiniSurround.add"] = "s",
}
local function multiop(select, find)
  return function()
    feedkeys("<C-\\><C-n>", "nx")
    feedkeys("<esc>", "n")

    local register = vim.v.register
    local operator = vim.v.operator
    local rhs = ops[operator] or operator
    local opfunc = vim.go.operatorfunc
    if operator == "g@" then rhs = ops[opfunc] end

    local function callback()
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
        vim.go.operatorfunc = opfunc
        vim.cmd [[call b:VM_Selection.Edit.run_visual("g@", 1)]]
      end
    end
    if select == "?" then
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("after_find_do_op", {}),
        pattern = "visual_multi_after_regex",
        once = true,
        callback = callback,
      })
      feedkeys("<Plug>(VM-Start-Regex-Search)", "m")
      return
    end

    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("after_find_do_op", {}),
      pattern = "visual_multi_after_find",
      once = true,
      callback = callback,
    })
    if select == true then
      local finish = vim.schedule_wrap(function() wrap_vm_call(nil, "Find-Subword-Under", find) end)
      _G.__multiop_finish = function()
        feedkeys("`[v`]", "n")
        finish()
      end
      vim.go.operatorfunc = "v:lua.__multiop_finish"
      feedkeys("g@", "n")
    else
      local finish = vim.schedule_wrap(
        function() wrap_vm_call(nil, select == "/" and "Find-Regex" or "Find-Under", find) end
      )
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
  init = function()
    vim.g.VM_maps = nil
    -- local ldr = "\\"
    -- local ldr = "<Del>" -- FIXME: a little buggy
    local ldr = O.multi_leader_key
    vim.g.VM_leader = ldr
    vim.g.VM_maps = {
      ["Find Under"] = "<M-n>",
      ["Add Cursor At Word"] = "<C-n>",
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
      ["Visual Regex"] = "?",
      ["Slash Search"] = ldr .. "/",
      -- ["Find Operator"] = "m",
      ["Find Operator"] = ldr .. "o",
      ["Undo"] = "u",
      ["Redo"] = "<C-r>",
      ["Reselect Last"] = ldr .. ldr,
      ["Transpose"] = "M",
      ["Split Regions"] = "-",
      ["Toggle Mappings"] = ldr .. "<Esc>",
      ["Surround"] = "s",
      -- ["Select Operator"] = ldr .. "s",
      ["Select Operator"] = "<M-v>",
      ["Add Cursor At Pos"] = "+",
      ["Select All"] = ldr .. "O",
      ["Visual All"] = ldr .. "O",
    }
    if ldr == "<Del>" then vim.g.VM_maps["Del"] = "" end
    vim.g.VM_mouse_mappings = 1
    vim.g.VM_add_cursor_at_pos_no_mappings = 1

    local theme = "codedark"
    vim.g.VM_theme = theme
    vim.g.VM_user_operators = {
      "yd",
      "r",
      "cx",
      "yc",
    }
  end,
  config = function()
    -- TODO: yolo and merge this into the github lol, i forked it anyway, could be implemented better anyway
    vim.cmd.VMTheme(vim.g.VM_theme)
    local ldr = vim.g.VM_leader
    local map = vim.keymap.set
    map(
      { "x" },
      "<C-n>",
      "<Plug>(VM-Add-Cursor-At-SubWord)",
      { remap = true, desc = "Add Cursor At Region" }
    )
    map("x", "+", "<C-v>", { remap = true, desc = "Add regions" })
    map(
      "x",
      "-",
      wrap_vm(nil, "Visual-Add", "<Plug>(VM-Split-Regions)"),
      { remap = true, desc = "Split Visual Region" }
    )
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
          return "<Plug>(VM-Visual-Cursors)" .. (m == "V" and "^" or "")
        end
      end
    end, { expr = true, desc = "Add regions" })
    -- TODO: subsume visual block mode
    -- TODO: add selection downward
    -- TODO: * can be replaced?

    map("c", "<M-n>", function()
      local mode = vim.fn.getcmdtype()
      if mode == "/" or mode == "?" then
        -- TODO: from flash fuzzy search
        return [[<cr><Plug>(VM-Find-Regex)]]
      else
        return ""
      end
    end, { expr = true, remap = true, desc = "Visual Multi" })
    map("c", "<M-a>", function()
      local mode = vim.fn.getcmdtype()
      if mode == "/" or mode == "?" then
        -- TODO: from flash fuzzy search
        return [[<cr><Plug>(VM-Find-Regex)<Plug>(VM-Select-All)]]
      else
        return ""
      end
    end, { expr = true, remap = true, desc = "Visual Multi" })
    map("c", "<M-i>", function()
      local mode = vim.fn.getcmdtype()
      if mode == "/" or mode == "?" then
        -- TODO: from flash fuzzy search
        return [[<cr><Plug>(VM-Find-Regex)<Plug>(VM-Find-Operator)]]
      else
        return ""
      end
    end, { expr = true, remap = true, desc = "Visual Multi" })

    -- Multi select object
    local find_under_operator = utils.operatorfunc_keys "<Plug>(VM-Find-Subword-Under)"
    map("n", "<M-v>", find_under_operator, { desc = "MVisual (op)", expr = true })
    -- map("n", "m", find_under_operator, { desc = "Find Under (op)" })
    -- Multi select all
    local select_all_operator = utils.operatorfunc_fn(
      vim.schedule_wrap(
        function() wrap_vm_call(nil, "Find-Subword-Under", "<Plug>(VM-Select-All)") end
      )
    )
    map("n", ldr .. "A", select_all_operator, { desc = "Select all (op)", expr = true })
    local select_in_operator = utils.operatorfunc_fn(
      vim.schedule_wrap(
        function() wrap_vm_call(nil, "Find-Subword-Under", "<Plug>(VM-Find-Operator)") end
      )
    )
    map("n", ldr .. "I", select_in_operator, { desc = "Select (op) in", expr = true })
    map(
      "n",
      ldr .. "o",
      wrap_vm(nil, "Find-Under", "<Plug>(VM-Find-Operator)"),
      { remap = true, desc = "Select word in (motion)" }
    )
    map(
      "x",
      ldr .. "o",
      wrap_vm(nil, "Find-Subword-Under", "<Plug>(VM-Find-Operator)"),
      { remap = true, desc = "Select all of (selection)" }
    )

    map("o", "o", multiop(false, "<Plug>(VM-Find-Operator)"), { desc = "op all cword in" })
    map("o", "O", multiop(false, "<Plug>(VM-Select-All)"), { desc = "op all cword" })
    map("o", "/", multiop("/", "<Plug>(VM-Find-Operator)"), { desc = "op all pattern in" })
    map("o", "?", multiop("/", "<Plug>(VM-Select-All)"), { desc = "op all pattern" })
    map("o", "I", multiop(true, "<Plug>(VM-Find-Operator)"), { desc = "op all <> in" })
    map("o", "A", multiop(true, "<Plug>(VM-Select-All)"), { desc = "op all of <>" })
    -- TODO: Start-Regex-Search version of operators

    -- TODO: this should be implemented in vm core
    local add_selection_operator =
      utils.operatorfunc_keys "<Plug>(VM-Visual-Add)<Plug>(VM-Disable-Mappings)"
    map("n", ldr .. "+", add_selection_operator, { desc = "Add Selection (op)", expr = true })
    map("n", ldr .. "r", function()
      add_selection_operator()
      feedkeys(O.select_remote, "m")
    end, { desc = "Add Selection Remote (op)", expr = true })

    -- map("n", ldr .. "n", "<Plug>(VM-Start-Regex-Search)<C-r>/<cr>", { desc = "Select all (op)" })
    local last_search
    map("n", ldr .. "n", "<Plug>(VM-Find-Regex)", { desc = "Select last search" })
    map(
      "n",
      ldr .. "F",
      -- wrap_vm(nil, "Find-Regex", "<Plug>(VM-Select-All)"),
      wrap_vm(nil, "Find-Regex", "<Plug>(VM-Select-All)"),
      { remap = true, desc = "Select all of last search" }
    )
    local find_in_operator = utils.operatorfunc_keys "<Plug>(VM-Visual-Find)"
    map("n", ldr .. "f", find_in_operator, { desc = "Select last search in (op)", expr = true })
    map("x", "/", function()
      local cursor, other = vim.fn.getpos ".", vim.fn.getpos "v"
      if cursor ~= other or vim.api.nvim_get_mode().mode == "V" then
        return "<Plug>(VM-Visual-Regex)"
      else
        return "<Plug>(VM-Start-Regex-Search)"
      end
    end, { expr = true, desc = "From last search" })

    vim.api.nvim_create_autocmd("User", {
      pattern = "visual_multi_mappings",
      callback = function()
        -- map(
        --   "n",
        --   ldr,
        --   function() require("which-key").show(vim.keycode "<del>", { mode = "n", auto = true }) end,
        --   {
        --     buffer = 0,
        --   }
        -- )
      end,
    })
    local mapl = vim.keymap.setl
    vim.api.nvim_create_autocmd("User", {
      pattern = "visual_multi_start",
      callback = function()
        mapl("n", "<C-n>", "<Plug>(VM-Find-Next)")
        mapl("n", "<C-S-n>", "<Plug>(VM-Find-Prev)")
        mapl("n", ";", function()
          if vim.g.Vm.extend_mode then
            return "<Plug>(VM-Run-Visual)"
          else
            return "<Plug>(VM-Run-Normal)"
          end
        end)
        mapl("n", "(", "<Plug>(VM-Transpose)")
        mapl("n", ")", "<Plug>(VM-Transpose)")
      end,
    })
    local unmap = vim.keymap.dell
    vim.api.nvim_create_autocmd("User", {
      pattern = "visual_multi_exit",
      callback = function()
        unmap("n", "<C-n>")
        unmap("n", "<C-S-n>")
        unmap("n", ";")
        unmap("n", "(")
        unmap("n", ")")
      end,
    })

    map(
      "n",
      "<Plug>(VM-Disable-Mappings)",
      ":call b:VM_Selection.Maps.disable(1)<cr>",
      { silent = true }
    )
    map(
      "n",
      "<Plug>(VM-Enable-Mappings)",
      ":call b:VM_Selection.Maps.enable()<cr>",
      { silent = true }
    )
    map("n", "<Plug>(VM-Motion-()", "<Plug>(VM-Transpose)")

    -- TODO: https://docs.helix-editor.com/keymap.html#selection-manipulation
  end,
  lazy = false,
}
