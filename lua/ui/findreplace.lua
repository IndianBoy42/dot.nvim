return {
  {
    "MagicDuck/grug-far.nvim",
    opts = {
      keymaps = {
        close = "<C-c>",
      },
    },
    cmd = { "GrugFar" },
    keys = {
      { "<leader>rp", "<cmd>GrugFar<cr>", desc = "GrugFar Project" },
      {
        "<leader>rr*",
        function() require("grug-far").grug_far { prefills = { search = vim.fn.expand "<cword>" } } end,
        desc = "Last search",
      },
      {
        "<leader>rr/",
        function() require("grug-far").grug_far { prefills = { search = vim.fn.getreg "/" } } end,
        desc = "Last search",
      },
      {
        "<leader>rr+",
        function() require("grug-far").grug_far { prefills = { search = vim.fn.getreg "+" } } end,
        desc = "Last yank",
      },
      {
        "<leader>rr.",
        function() require("grug-far").grug_far { prefills = { search = vim.fn.getreg "." } } end,
        desc = "Last insert",
      },
      {
        "<Plug>(GrugFarFile)",
        function() require("grug-far").grug_far { prefills = { flags = vim.fn.expand "%" } } end,
        desc = "GrugFar File",
      },
    },
  },
  {
    "cshuaimin/ssr.nvim",
    -- Calling setup is optional.
    opts = {
      border = "rounded",
      min_width = 50,
      min_height = 5,
      max_width = 120,
      max_height = 25,
      keymaps = {
        close = "<C-q>",
        next_match = "n",
        prev_match = "N",
        replace_confirm = "<cr>",
        replace_all = "<localleader><cr>",
      },
    },
    keys = {
      {
        "<leader>rr",
        function() require("ssr").open() end,
        mode = { "n", "x" },
        desc = "Treesitter SSR",
      },
    },
  },
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    keys = {
      {
        "<leader>rn",
        function() return ":IncRename " .. vim.fn.expand "<cword>" end,
        expr = true,
        desc = "Rename",
      },
      {
        "rn",
        function() return ":IncRename " .. vim.fn.expand "<cword>" end,
        expr = true,
        desc = "Lsp Rename",
      },
    },
    config = true,
  },
  {
    "AckslD/muren.nvim",
    opts = {},
    keys = {
      { "<leader>rm", function() require("muren.api").toggle_ui() end, desc = "Multi Replace" },
      { "<M-m>", "<cr><cmd>MurenUnique<cr>", mode = "c", desc = "Multi Replace" },
    },
  },
  {
    "stevearc/quicker.nvim",
    -- TODO: winleavepre
    opts = {
      keys = {
        {
          "<Right>",
          function() require("quicker").expand { before = 2, after = 2, add_to_existing = true } end,
          desc = "Expand quickfix context",
        },
        {
          "<Left>",
          function() require("quicker").collapse() end,
          desc = "Collapse quickfix context",
        },
        {
          "<localleader><localleader>",
          function() require("quicker").refresh() end,
          desc = "Refresh",
        },
      },
      on_qf = function(bufnr)
        vim.api.nvim_create_autocmd("WinLeavePre", {
          buffer = 0,
          callback = function() vim.cmd.write() end,
        })
      end,
    },
  },
}
