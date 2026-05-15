return {
  opts = {
    ui = {
      window_width = 0.50,
      display_cost = false,
      icons = {
        preset = "text",
        overrides = {},
      },
      input = {
        text = {
          wrap = true,
        },
      },
    },
    completion = {
      file_sources = {
        enabled = true,
        preferred_cli_tool = "rg",
      },
    },
    context = {
      cursor_data = {
        enabled = true,
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "saghen/blink.cmp",
    "nvim-telescope/telescope.nvim",
  },
}
