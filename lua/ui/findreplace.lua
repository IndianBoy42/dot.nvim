return {
  {
    "MagicDuck/grug-far.nvim",
    opts = {
      -- transient = true,
      keymaps = {
        close = "<C-c>",
        replace = { n = O.quicksave },
        -- TODO: need a hydra for the next/prev
        -- qflist = { n = '<localleader>q' },
        -- syncLocations = { n = '<localleader>s' }, // sync all
        -- applyNext = { n = '<localleader>j' },
        -- applyPrev = { n = '<localleader>k' },
        -- syncNext = { n = '<localleader>n' },
        -- syncPrev = { n = '<localleader>p' },
        -- syncFile = { n = '<localleader>v' },
        syncLine = { n = "L" },
        -- historyOpen = { n = '<localleader>t' },
        -- historyAdd = { n = '<localleader>a' },
        -- refresh = { n = '<localleader>f' },
        -- openLocation = { n = '<localleader>o' },
        -- TODO: jump to match without opening
        -- openNextLocation = { n = '<down>' },
        -- openPrevLocation = { n = '<up>' },
        -- gotoLocation = { n = '<enter>' },
        -- pickHistoryEntry = { n = '<enter>' },
        -- abort = { n = '<localleader>b' },
        -- help = { n = 'g?' },
        -- toggleShowCommand = { n = '<localleader>w' },
        -- swapEngine = { n = '<localleader>e' },
        -- previewLocation = { n = '<localleader>i' },
        -- swapReplacementInterpreter = { n = '<localleader>x' },
        -- nextInput = { n = '<tab>' },
        -- prevInput = { n = '<s-tab>' },
      },
    },
    cmd = { "GrugFar" },
    keys = {
      { "<leader>rp", "<cmd>GrugFar<cr>", desc = "GrugFar Project", mode = { "x", "n" } },
      {
        "<leader>rf",
        function() require("grug-far").open { prefills = { paths = vim.fn.expand "%" } } end,
      },
      {
        "<leader>rr*",
        function() require("grug-far").open { prefills = { search = vim.fn.expand "<cword>" } } end,
        desc = "Last search",
      },
      {
        "<leader>rr/",
        function() require("grug-far").open { prefills = { search = vim.fn.getreg "/" } } end,
        desc = "Last search",
      },
      {
        "<leader>rr+",
        function() require("grug-far").open { prefills = { search = vim.fn.getreg "+" } } end,
        desc = "Last yank",
      },
      {
        "<leader>rr.",
        function() require("grug-far").open { prefills = { search = vim.fn.getreg "." } } end,
        desc = "Last insert",
      },
      {
        "<Plug>(GrugFarFile)",
        function() require("grug-far").open { prefills = { flags = vim.fn.expand "%" } } end,
        desc = "GrugFar File",
      },
    },
    setup = function(opts)
      require("grug-far").setup(opts)
      local function nN()
        mappings.register_nN_repeat {
          "<Plug>(GrugNextMatch)",
          "<Plug>(GrugPrevMatch)",
        }
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("grug-far-keybindings", { clear = true }),
        pattern = { "grug-far" },
        callback = function()
          local inst = require("grug-far").get_instance(0)
          if not inst then return end

          nN()

          -- Jump and close
          vim.keymap.set("n", "<C-enter>", function()
            inst:open_location()
            inst:close()
          end, { buffer = true })
          vim.keymap.set(
            "n",
            "<Plug>(GrugNextMatch)",
            function() inst:goto_next_match() end,
            { buffer = true }
          )
          vim.keymap.set(
            "n",
            "<Plug>(GrugPrevMatch)",
            function() inst:goto_prev_match() end,
            { buffer = true }
          )
          vim.keymap.set("n", "<Plug>(GrugApplyNextMatch)", function()
            inst:goto_next_match()
            inst:apply_next_change {}
          end, { buffer = true })
          vim.keymap.set("n", "<Plug>(GrugApplyPrevMatch)", function()
            inst:goto_prev_match()
            inst:apply_next_change {}
          end, { buffer = true })
          vim.keymap.set("n", "<localleader>/", function()
            inst:goto_next_match()
            nN()
          end, { buffer = true })
        end,
      })
    end,
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
        -- vim.api.nvim_create_autocmd("WinLeave", {
        --   buffer = 0,
        --   callback = function() vim.cmd.write() end,
        -- })
      end,
    },
  },
}
