return {
  opts = {
    ui = {
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
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        anti_conceal = { enabled = false },
        file_types = { "markdown", "opencode_output" },
      },
      ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
    },
    "saghen/blink.cmp",
    "nvim-telescope/telescope.nvim",
  },
}
