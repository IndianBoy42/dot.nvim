-- Common markdown and latex plugins
return {
  {
    "frabjous/knap",
    keys = {
      {
        "<leader>vk",
        function()
          require("knap").toggle_autopreviewing()
          vim.keymap.set("n", "<localleader>v", require("knap").forward_jump, { desc = "Fwd Jump" })
        end,
        desc = "Knap",
      },
    },
  },
  {
    "jbyuki/nabla.nvim",
    keys = function()
      local enabled = false
      return {
        { "<leader>vn", function() require("nabla").popup() end, desc = "Nabla Popup" },
        {
          "<leader>vN",
          function()
            if enabled then
              require("nabla").disable_virt()
            else
              require("nabla").enable_virt()
              local id = vim.api.nvim_create_augroup("nabla_live_popup", { clear = true })
              vim.api.nvim_create_autocmd("CursorHold", {
                callback = function() require("nabla").popup() end,
                buffer = 0,
                group = id,
              })
            end
            enabled = not enabled
          end,
          desc = "Nabla Virtual",
        },
      }
    end,
  },
}
