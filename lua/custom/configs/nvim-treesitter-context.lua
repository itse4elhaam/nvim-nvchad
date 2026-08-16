return function()
  require("treesitter-context").setup {
    enable = true,
    max_lines = 3,
    trim_scope = "inner",
  }
end
