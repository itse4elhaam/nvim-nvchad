local tmux_status

return {
  bigfile = { enabled = true },
  gh = { enabled = true },
  picker = {
    enabled = true,
  },
  zen = {
    enabled = true,
    toggles = {
      dim = false
    },
    on_open = function(_)
      if not vim.env.TMUX then
        return
      end

      vim.system({ "tmux", "show-option", "-gqv", "status" }, { text = true }, function(result)
        tmux_status = vim.trim(result.stdout or "") ~= "" and vim.trim(result.stdout) or "on"
        vim.system { "tmux", "set-option", "-g", "status", "off" }
      end)
    end,
    --- Callback when the window is closed.
    ---@param win snacks.win
    on_close = function(_)
      if vim.env.TMUX then
        vim.system { "tmux", "set-option", "-g", "status", tmux_status or "on" }
        tmux_status = nil
      end
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
  gitbrowse = { enabled = true, what = "branch" },
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
