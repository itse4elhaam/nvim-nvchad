return function()
  require("treesitter-context").setup {
    enable = true,
    throttle = true,
    max_lines = 7,
    trim_scope = "inner",
    patterns = {
      default = {
        "class",
        "function",
        "method",
      },
    },
  }
end
