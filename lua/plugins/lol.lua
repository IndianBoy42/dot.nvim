return {

  { --giusgad/pets.nvim
    "giusgad/pets.nvim",
    opts = {
      popup = { width = "100%" },
    },
    init = function()
      vim.api.nvim_create_user_command("LotsOPets", function()
        local names = "abcdefghijklmnopqrstuvwxyz"

        local chars = {}
        for c in names:gmatch "." do
          vim.cmd.PetsNew(c)
        end
      end, {})
    end,
    dependencies = { "MunifTanjim/nui.nvim", "edluffy/hologram.nvim" },
    cmd = {
      "PetsNew",
      "PetsNewCustom",
      "PetsList",
      "PetsKill",
      "PetsKillAll",
      "PetsPauseToggle",
      "PetsHideToggle",
      "PetsSleepToggle",
    },
  },
  { --tamton-aquib/duck.nvim
    "tamton-aquib/duck.nvim",
    keys = {
      -- {
      --   "gzD",
      --   function()
      --     -- 🦆 ඞ  🦀 🐈 🐎 🦖 🐤
      --     require("duck").hatch("🦆", "10")
      --   end,
      --   desc = "hatch a duck",
      -- },
    },
  },
}
