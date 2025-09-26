return {
  opts = {
    ui = {
      display_cost = false,
    },
    context = {
      cursor_data = {
        enabled = true, -- Include cursor position and line content in the context
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
    -- Optional, for file mentions and commands completion, pick only one
    "saghen/blink.cmp",
    "nvim-telescope/telescope.nvim",
  },
}