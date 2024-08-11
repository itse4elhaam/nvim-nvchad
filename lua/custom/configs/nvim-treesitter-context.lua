return function()
  require('treesitter-context').setup {
    enable = true,
    throttle = true,
    max_lines = 7,
    patterns = {
      default = {
        'class',
        'function',
        'method',
      },
    },
  }
end