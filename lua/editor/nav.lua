local function paranormal(targets)
  -- Get the :normal sequence to be executed.
  local input = vim.fn.input "normal! "
  if #input < 1 then return end

  local ns = vim.api.nvim_create_namespace ""

  -- Set an extmark as an anchor for each target, so that we can also execute
  -- commands that modify the positions of other targets (insert/change/delete).
  for _, target in ipairs(targets) do
    local line, col = unpack(target.pos)
    id = vim.api.nvim_buf_set_extmark(0, ns, line - 1, col - 1, {})
    target.extmark_id = id
  end

  -- Jump to each extmark (anchored to the "moving" targets), and execute the
  -- command sequence.
  for _, target in ipairs(targets) do
    local id = target.extmark_id
    local pos = vim.api.nvim_buf_get_extmark_by_id(0, ns, id, {})
    vim.fn.cursor(pos[1] + 1, pos[2] + 1)
    vim.cmd("normal! " .. input)
  end

  -- Clean up the extmarks.
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

local paranormal_map = function()
  require("leap").leap {
    target_windows = { vim.fn.win_getid() },
    action = paranormal,
    multiselect = true,
  }
end

local partial = utils.partial
local hop_fn = setmetatable({}, {
  __index = function(_, n)
    return setmetatable({}, {
      __call = function(t, ...) return partial(require("hop-extensions")[n], ...) end,
      __index = function(t, k)
        return function(...) return partial(require("hop-extensions")[n][k], ...) end
      end,
    })
  end,
})

local hops = function()
  return {
    -- {["/"] , prefix .. "hint_patterns({}, vim.fn.getreg('/'))<cr>", "Last Search" },
    -- {"g" , exts"hint_localsgd", "Go to Definition of" },
    { "/", "<cmd>HopPattern<cr>", "Search" },
    { "?", hop_fn.hint_patterns_from({}, { reg = "/" }), "Last Search" },
    -- { "w", exts "hint_words", "Words" },
    { "L", hop_fn.hint_lines_skip_whitespace(), "Lines" },
    { "v", hop_fn.hint_vertical(), "Lines Column" },
    { "w", hop_fn.hint_patterns_from({}, { expand = "<cword>" }), "cword" },
    { "W", hop_fn.hint_patterns_from({}, { expand = "<cWORD>" }), "cWORD" },
    { "m", hop_fn.ts.hint_containing_nodes(), "TS Nodes Containing" },
    -- { "m", function() require("tsht").move { side = "end" } end, "TS Nodes Containing" },
    { "M", function() require("tsht").move { side = "start" } end, "TS Nodes Containing" },
    { "l", hop_fn.ts.hint_defnref(), "Locals" },
    { "D", hop_fn.ts.hint_definition(), "LSP Definitions" },
    { "r", hop_fn.lsp.hint_references(), "LSP References" },
    { "u", hop_fn.ts.hint_usages(), "TS Usages" },
    { "c", hop_fn.ts.hint_scopes(), "Scopes" },
    { "C", hop_fn.ts.hint_containing_scopes(), "Scopes" },
    { "s", hop_fn.lsp.hint_symbols(), "LSP Symbols" },
    { "d", hop_fn.hint_diagnostics(), "LSP Diagnostics" },
    {
      "k",
      hop_fn.ts.hint_textobjects {
        captures = {
          "@function",
          "@block",
          "@class",
          "@conditional",
          "@loop",
        },
      },
      "Blocks",
    },
    {
      "j",
      hop_fn.ts.hint_textobjects {
        captures = {
          "@parameter",
          "@statement",
          "@assignment",
          "@call",
        },
      },
      "Expressions",
    },
  }
end
return {
  {
    "phaazon/hop.nvim",
    dependencies = { "IndianBoy42/hop-extensions" },
    event = "VeryLazy",
    opts = {
      keys = O.hint_labels,
    },
    keys = function()
      local hop_pattern = {
        "<M-h>", -- "<M-CR>",
        "<CR><CMD>lua require'hop'.hint_patterns({}, vim.fn.getreg('/'))<CR>",
        mode = { "c" },
      }
      local keys = { hop_pattern }
      for _, rhs_ in ipairs(hops()) do
        local lhs, rhs, desc = unpack(rhs_)
        table.insert(keys, { "<leader>h" .. lhs, rhs, desc = desc })
      end
      return keys
    end,
  },
  {
    "ggandor/leap.nvim",
    keys = {
      -- {
      --   "s",
      --   function()
      --     local current_window = vim.fn.win_getid()
      --     require("leap").leap { target_windows = { current_window } }
      --   end,
      --   mode = "n",
      --   desc = "Leap",
      -- },
      { "s", "<Plug>(leap-forward-to)", mode = "n", desc = "Leap" },
      -- { "tt", "<Plug>(leap-forward-till)", mode = "n", desc = "Leap" },
      { "S", "<Plug>(leap-backward-to)", mode = "n", desc = "Leap" },
      -- { "TT", "<Plug>(leap-backward-till)", mode = "n", desc = "Leap" },
      {
        "z",
        function()
          local current_window = vim.fn.win_getid()
          require("leap").leap { target_windows = { current_window } }
        end,
        mode = "x",
        desc = "Leap",
      },
      {
        "z",
        function()
          local current_window = vim.fn.win_getid()
          require("leap").leap { target_windows = { current_window } }
        end,
        mode = "o",
        desc = "Leap",
      },
    },
    config = function() end,
  },
  {
    "rlane/pounce.nvim",
    keys = {
      {
        "<leader>hf",
        -- "<cmd>Pounce<cr>",
        function()
          mappings.register_nN_repeat { "<cmd>PounceRepeat<cr>", "<cmd>PounceRepeat<cr>" }
          vim.cmd.Pounce()
        end,
        desc = "Fuzzy",
      },
    },
    cmd = { "Pounce" },
    opts = {
      accept_keys = O.hint_labels:upper(),
    },
  },
  {
    "ggandor/flit.nvim",
    -- TODO:
    -- dependencies = {
    --   {
    --     "jinh0/eyeliner.nvim",
    --     config = function()
    --       require("eyeliner").setup {
    --         highlight_on_key = true,
    --       }
    --     end,
    --   },
    -- },
    keys = function()
      local ret = {}
      for _, key in ipairs { "f", "F", "t", "T" } do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
      end
      return ret
    end,
    opts = { labeled_modes = "nx" },
  },
  {
    "cbochs/portal.nvim",
    dependencies = {
      -- "cbochs/grapple.nvim", -- Optional: provides the "grapple" query item
      -- "ThePrimeagen/harpoon", -- Optional: provides the "harpoon" query item
    },
    opts = {
      portal = {
        window_options = {
          border = "none",
        },
      },
    },
    cmd = "Portal",
    keys = {
      { "<C-i>", function() require("portal.builtin").jumplist.tunnel_forward() end, desc = "portal fwd" },
      { "]o", function() require("portal.builtin").jumplist.tunnel_backward() end, desc = "portal fwd" },
      { "<C-o>", function() require("portal.builtin").jumplist.tunnel_backward() end, desc = "portal bwd" },
      -- TODO: use other queries?
    },
  },
}
