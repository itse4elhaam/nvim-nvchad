local config = function()
  require("goto-preview").setup {
    width = 120,
    height = 15,
    border = { "↖", "─", "╮", "│", "╯", "─", "╰", "│" },
    default_mappings = false,
    debug = false,
    opacity = nil,
    resizing_mappings = false,
    post_open_hook = nil,
    post_close_hook = nil,
    references = {
      provider = "telescope",
      telescope_opts = nil,
    },
    focus_on_open = true,
    dismiss_on_move = false,
    force_close = true,
    bufhidden = "wipe",
    stack_floating_preview_windows = true,
    same_file_float_preview = false,
    preview_window_title = { enable = true, position = "left" },
  }
end

return config
