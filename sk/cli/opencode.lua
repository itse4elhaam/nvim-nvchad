---@type sidekick.cli.Config
--- Override for folke/sidekick.nvim's `sk/cli/opencode.lua`.
---
--- Upstream registers an "external" opencode session backend that discovers
--- running opencode processes via an lsof port scan and then sends prompts
--- over HTTP to `/tui/append-prompt` and `/tui/submit-prompt`. Those endpoints
--- return 404 on opencode >= 1.14.30 (see folke/sidekick.nvim issue #314), so
--- the external session attaches as a no-op while the broken HTTP path is
--- preferred over the working tmux pane backend (higher priority in
--- `sidekick.cli.state` dedup). This override drops the session registration,
--- leaving the tmux backend to detect and drive opencode panes via
--- `tmux paste-buffer`/`send-keys`, which works regardless of opencode's HTTP
--- server API.
return {
  cmd = { "opencode" },
  env = {
    OPENCODE_THEME = "system",
  },
  is_proc = "\\<opencode\\>",
  url = "https://github.com/sst/opencode",
  continue = { "--continue" },
  native_scroll = true,
}
