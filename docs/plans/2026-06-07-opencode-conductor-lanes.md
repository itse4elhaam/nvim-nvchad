# OpenCode Conductor-Like Lanes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `executing-plans` or `subagent-driven-development` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Conductor-like parallel development workflow using OpenCode, git worktrees, tmux, and Neovim review tools.

**Architecture:** Each development lane is a branch + worktree + tmux session + OpenCode session. Neovim acts as the review/control plane: list lanes, inspect changed files, open diffs, accept/reject hunks, and promote work via commit/PR when ready.

**Tech Stack:** OpenCode CLI, existing OpenCode config in `~/dotfiles/.config/opencode`, git worktrees, tmux, Neovim Lua, Snacks picker/terminal or existing picker APIs, `CodeDiff`, `gitsigns`.

---

## Strict Execution Rules

1. **Do not build a giant UI first.** Start with commands that operate on one lane.
2. **Do not invent a new state database until git/tmux can’t answer the question.**
3. **Do not auto-merge agent output.** Human review is mandatory.
4. **Do not run destructive git commands:** no force-push, no hard reset, no clean unless user explicitly approves.
5. **Every lane must be recoverable from git worktree metadata and tmux session name.**
6. **No commits or PRs without explicit user request.**
7. **Neovim must remain usable if OpenCode/tmux is absent.** Optional integrations use `pcall`/availability checks.

## Lane Model

A lane has:

```text
name:        short human name, e.g. keymap-fixes
branch:      feat/keymap-fixes or chore/opencode-lane-keymap-fixes
worktree:    ../nvim-keymap-fixes or configured worktree root
tmux:        oc-keymap-fixes
opencode:    running session in that tmux pane/status
status:      idle | running | review | blocked | done
```

## Files to Create/Modify

- Create: `lua/custom/opencode_lanes.lua` — lane discovery and command helpers.
- Modify: `lua/custom/mappings.lua` — minimal lane/review mappings.
- Possibly modify: `lua/custom/plugins.lua` — only if a picker integration needs registration.
- Optional later: `docs/opencode-lanes.md` — user-facing workflow docs.

## Task 1: Implement Read-Only Lane Discovery

- [ ] Write a helper that shells out to:

```bash
git worktree list --porcelain
```

- [ ] Parse worktree path, branch, and HEAD.
- [ ] Do not mutate anything.
- [ ] Return an empty list gracefully if not in a git repo.

## Task 2: Add Lane Picker / List Command

- [ ] Add a command such as `:OpenCodeLanes`.
- [ ] If Snacks picker exists, use it behind `pcall`.
- [ ] If picker is unavailable, fall back to `vim.ui.select`.
- [ ] Selecting a lane should offer actions:
  - open terminal/tmux session
  - open changed files picker
  - open CodeDiff review
  - show git status

## Task 3: Add Review Actions

- [ ] Add current-lane changed file listing:

```bash
git -C <worktree> diff --name-only main...HEAD
```

- [ ] Add full review command:

```bash
CodeDiff main...HEAD
```

- [ ] Add current-file review command when file belongs to a lane.

## Task 4: Add Lane Creation Command

Only after read-only review works:

- [ ] Prompt for lane name.
- [ ] Create branch/worktree safely:

```bash
git worktree add ../nvim-<lane> -b feat/<lane>
```

- [ ] Start tmux session:

```bash
tmux new-session -d -s oc-<lane> -c ../nvim-<lane> opencode
```

- [ ] Do not start if branch/worktree/session already exists.

## Task 5: Verification

```bash
/home/elhaam/.local/share/nvim/mason/bin/stylua --check lua/custom/opencode_lanes.lua lua/custom/mappings.lua
nvim --headless +'lua require("custom.opencode_lanes")' +q
nvim --headless +q
```

Interactive checks:

- `:OpenCodeLanes` shows lanes or a helpful empty state.
- Opening a lane does not block Neovim.
- CodeDiff opens for a lane with changes.
- Missing tmux/OpenCode produces a readable error, not a crash.

## Rollback Plan

```bash
git checkout -- lua/custom/mappings.lua lua/custom/plugins.lua
rm -f lua/custom/opencode_lanes.lua docs/opencode-lanes.md
nvim --headless +q
```

## Done Criteria

- User can see active worktrees from Neovim.
- User can jump from a lane to diff review.
- No automatic merge/commit behavior exists.
- The workflow feels like a control plane, not another heavyweight plugin.
