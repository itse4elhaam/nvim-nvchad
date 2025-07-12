return {
  bigfile = { enabled = true },
  zen = {
    enabled = true,
    on_open = function(_)
      vim.fn.system "tmux set-option status off"
    end,
    --- Callback when the window is closed.
    ---@param win snacks.win
    on_close = function(_)
      vim.fn.system "tmux set-option status on"
    end,
    --- Options for the `Snacks.zen.zoom()`
    ---@type snacks.zen.Config
    zoom = {
      toggles = {},
      show = { statusline = false, tabline = false },
      win = {
        backdrop = false,
        width = 0, -- full width
      },
    },
  },
  quickfile = { enabled = true },
  lazygit = { enabled = true },
  scratch = { enabled = true },
  gitbrowse = { enabled = true },
  notifier = { enabled = true },
  scroll = {
    enabled = false,
    animate = {
      duration = { step = 12, total = 180 }, -- nice and smooth
    },
    animate_repeat = {
      delay = 80,                         -- if next scroll happens within 80ms, use fast mode
      duration = { step = 1, total = 1 }, -- basically instant
    },
  },
}
