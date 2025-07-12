local config = function()
  require("alternate-toggler").setup {
    alternates = {
      ["=="] = "!=",
      ["up"] = "down",
      ["let"] = "const",
      ["development"] = "production",
    },
  }

  vim.keymap.set(
    "n",
    "<leader><space>", -- <space><space>
    "<cmd>lua require('alternate-toggler').toggleAlternate()<CR>"
  )
end

return config
