local keymaps = function(table)
  local maps = {}
  for k, v in pairs(table) do
    if type(v) == "table" then
      for _, v2 in ipairs(v) do
        maps[v2] = k
      end
    else
      maps[v] = k
    end
  end
  return maps
end
return {
  {
    "chrisgrieser/nvim-genghis",
    dependencies = "stevearc/dressing.nvim",
    init = function()
      local function abbr(lhs, rhs) vim.keymap.set("ca", lhs, "Genghis " .. rhs) end
      abbr("New", "createNewFile")
      abbr("Move", "moveAndRenameFile")
      abbr("Rename", "renameFile")
      abbr("Trash", "trashFile")
    end,
    opts = {},
    cmd = {
      "Genghis",
    },
  },
  { "antosha417/nvim-lsp-file-operations", opts = {} },
  {
    "echasnovski/mini.files",
    cond = true,
    lazy = false,
    main = "mini.files",
    keys = {
      {
        "<leader>of",
        function()
          MiniFiles.open(vim.api.nvim_buf_get_name(0))
          MiniFiles.reveal_cwd()
        end,
        desc = "File Browser",
      },
      { "<leader>oF", F "MiniFiles.open()", desc = "File Browser CWD" },
    },
    opts = {
      windows = {
        preview = true,
        width_nofocus = 30,
      },
      options = {
        use_as_default_explorer = true,
      },
      mappings = {
        go_in = "l",
        go_in_plus = "<cr>",
        go_out = "h",
        go_out_plus = "-",
        reset = "<localleader>R",
        close = "<C-q>",
        synchronize = "<space><space>",
      },
    },
    config = function(_, opts)
      local mf = require "mini.files"
      opts.options.use_as_default_explorer = not vim.g.flatten_is_guest
      mf.setup(opts)

      local group = vim.api.nvim_create_augroup("mini_files_autocmds", {})

      local files_set_cwd = function(path)
        -- Works only if cursor is on the valid file system entry
        local cur_entry_path = MiniFiles.get_fs_entry().path
        local cur_directory = vim.fs.dirname(cur_entry_path)
        vim.fn.chdir(cur_directory)
      end

      local show_dotfiles = true

      local filter_show = function(fs_entry) return true end

      local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, ".") end

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        mf.refresh { content = { filter = new_filter } }
      end

      local set_from_picker = function()
        vim.api.nvim_win_call(
          mf.get_target_window(),
          function() mf.set_target_window(require("ui.win_pick").pick_or_create()) end
        )
      end
      local open_from_picker = function()
        set_from_picker()
        local entry = mf.get_fs_entry()
        if not entry or entry.fs_type ~= "file" then return end
        mf.go_in()
      end

      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local bufnr = args.data.buf_id
          require "hydra" {
            name = "Move",
            hint = false,
            config = {
              buffer = bufnr,
              color = "pink",
            },
            body = "<localleader>",
            heads = {
              { "h", "h", { noremap = true } },
              { "l", "l", { noremap = true } },
              { "H", "h", { noremap = false } },
              { "L", "l", { noremap = false } },
              { "<localleader>", "", { exit = true } },
            },
          }
          vim.keymap.set("n", "<localleader>~", files_set_cwd, { buffer = bufnr })
          vim.keymap.set("n", "<localleader>.", toggle_dotfiles, { buffer = bufnr })
          vim.keymap.set("n", "<localleader>p", set_from_picker, { buffer = bufnr })
          vim.keymap.set("n", "<localleader>L", open_from_picker, { buffer = bufnr })

          require "ui.files.git"
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "MiniFilesExplorerOpen",
        callback = function()
          require "lsp-file-operations" -- This loads it
        end,
      })
    end,
  },
  {
    "stevearc/oil.nvim",
    cond = false,
    lazy = false, -- So that i can do `nvim .` or `nvim <some_directory>`
    opts = {
      columns = { "icon", "permissions", "size", "mtime" },
      keymaps = keymaps {
        ["actions.show_help"] = "g?",
        ["actions.select"] = { "<CR>", "<localleader><localleader>", "<M-l>" },
        ["actions.select_vsplit"] = { "<C-s>", "<localleader>s" },
        ["actions.select_split"] = { "<C-h>", "<localleader>h" },
        ["actions.select_tab"] = { "<C-t>", "<localleader>t" },
        ["actions.preview"] = { "<C-p>", "<localleader>p" },
        ["actions.close"] = { "<C-c>", "<localleader>c" },
        ["actions.refresh"] = { "<C-r>", "<localleader>r" },
        ["actions.parent"] = { "-", "<localleader>-" },
        ["actions.open_cwd"] = { "_", "<localleader>." },
        ["actions.cd"] = { "`", "<localleader>d" },
        ["actions.tcd"] = { "~", "<localleader>~" },
        ["actions.toggle_hidden"] = "<localleader>H",
      },
      view_options = { show_hidden = true },
    },
    -- event = "BufEnter",
    cmd = "Oil",
    keys = {
      { "<leader>oe", function() require("oil").open() end, desc = "Open Oil Dir" },
    },
    init = function()
      if vim.fn.argc() == 1 then
        local arg = vim.fn.argv(0)
        local stat = vim.loop.fs_stat(arg)
        if stat and stat.type == "directory" then require("lazy").load { plugins = { "oil.nvim" } } end
      end
      if not require("lazy.core.config").plugins["oil.nvim"]._.loaded then
        vim.api.nvim_create_autocmd("BufNew", {
          callback = function(args)
            if vim.fn.isdirectory(args.file) == 1 then
              require("lazy").load { plugins = { "oil.nvim" } }
              -- Once oil is loaded, we can delete this autocmd
              return true
            end
          end,
        })
      end
    end,
    -- config = function(_, opts)
    --   require("oil").setup(opts)
    --
    --   vim.api.nvim_create_autocmd("User", {
    --     pattern = "OilEnter",
    --     callback = vim.schedule_wrap(function(args)
    --       local oil = require "oil"
    --       if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
    --         oil.select { preview = true }
    --       end
    --     end),
    --   })
    -- end,
  },
}
