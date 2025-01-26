local config = function()
  require("true-zen").setup {
    modes = {
      ataraxis = {
        callbacks = {
          open_pre = function()
            vim.cmd "silent !tmux set-option status off"
          end,
          open_post = function()
            vim.cmd "silent !tmux set-option status on"
          end,
        },
      },
      minimalist = {
        callbacks = {
          open_pre = function()
            vim.cmd "silent !tmux set-option status off"
          end,
          open_post = function()
            vim.cmd "silent !tmux set-option status on"
          end,
        },
      },
      narrow = {
        callbacks = {
          open_pre = function()
            vim.cmd "silent !tmux set-option status off"
          end,
          open_post = function()
            vim.cmd "silent !tmux set-option status on"
          end,
        },
      },
      focus = {
        callbacks = {
          open_pre = function()
            vim.cmd "silent !tmux set-option status off"
          end,
          open_post = function()
            vim.cmd "silent !tmux set-option status on"
          end,
        },
      },
    },
  }
end

return config
