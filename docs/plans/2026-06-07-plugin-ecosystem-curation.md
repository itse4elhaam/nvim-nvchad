# Plugin Ecosystem Curation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `executing-plans` or `subagent-driven-development` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn ecosystem recommendations into a small, taste-aligned plugin roadmap without bloating the daily editor.

**Architecture:** Prefer existing tools first (`gitsigns`, `CodeDiff`, Snacks terminals, Sidekick/OpenCode, tmux). Add a plugin only when it fills a concrete gap that current config cannot cover with a mapping or command wrapper.

**Tech Stack:** Neovim Lua, lazy.nvim/NvChad plugin specs, `lua/custom/plugins.lua`, `lua/custom/configs/*`, git/tmux/OpenCode workflows.

---

## Strict Execution Rules

1. **No plugin install without a written job-to-be-done.** The plan must say exactly what problem the plugin solves.
2. **No duplicate plugin categories.** If an existing plugin can do it, expose/configure that first.
3. **No heavy plugin swaps unless removing a worse tool.** This config prefers composable helpers.
4. **No broad lazy spec rewrites.** Touch only the plugin group being changed.
5. **No new mappings under occupied prefixes without checking conflicts.**
6. **No commit unless the user explicitly asks.**

## Candidate Plugin Decisions

| Candidate | Decision | Why |
|---|---|---|
| `mini.diff` | Evaluate only | Useful if persistent inline deleted-lines overlay is desired beyond `gitsigns` |
| `dlyongemallo/diffview.nvim` | Defer | More structured review UI, but history suggests Diffview felt heavy |
| `lazydiff.nvim` | Evaluate in sandbox | AI patch review fit, but must prove it beats existing `CodeDiff` |
| `overwatch.nvim` | Research only | Interesting AI-agent review angle; likely not first step |
| More completion/AI plugins | Avoid for now | Config already has AI/OpenCode/Supermaven direction |

## Files to Inspect Before Editing

- `lua/custom/plugins.lua` — plugin declarations and categories.
- `lua/custom/mappings.lua` — workflow mappings.
- `lua/custom/configs/gitsigns.lua` or equivalent — existing hunk behavior.
- `lua/custom/configs/*diff*` and CodeDiff config locations.
- `lazy-lock.json` policy — currently ignored; do not change without approval.

## Task 1: Build the Existing-Capability Matrix

- [ ] Document current capabilities for:
  - hunk preview
  - inline hunk preview
  - word diff
  - full-file diff
  - branch diff
  - changed-file picker
  - staging/reset hunk

- [ ] For each gap, mark one of:
  - solved by existing mapping
  - solved by new mapping
  - requires plugin trial
  - not worth solving

## Task 2: Expose Existing Capabilities Before Installing Anything

**Files:**
- Modify only if needed: `lua/custom/mappings.lua`
- Possibly modify: `lua/custom/configs/gitsigns.lua`

- [ ] Add or refine mappings for existing `gitsigns` actions if missing:

```lua
-- candidate namespace only; verify conflicts first
-- <leader>hp preview hunk
-- <leader>hi preview hunk inline
-- <leader>hw toggle word diff
-- <leader>hQ hunks to qflist
```

- [ ] Add mappings for existing `CodeDiff` if missing:

```lua
-- <leader>gD full branch/file review via CodeDiff
-- <leader>gd quick terminal/diffnav diff, if already used
```

## Task 3: Run a One-Plugin Trial Only If a Gap Remains

- [ ] Choose exactly one plugin to trial.
- [ ] Prefer `mini.diff` if the gap is persistent inline visual diff.
- [ ] Prefer `lazydiff.nvim` if the gap is AI-generated patch review flow.
- [ ] Add plugin lazily and minimally.
- [ ] Add no mappings until the plugin proves useful.

## Task 4: Verify and Decide

```bash
/home/elhaam/.local/share/nvim/mason/bin/stylua --check lua/custom/plugins.lua lua/custom/mappings.lua
nvim --headless +q
```

Then open Neovim interactively and review an actual changed file.

## Rollback Plan

```bash
git checkout -- lua/custom/plugins.lua lua/custom/mappings.lua lua/custom/configs
nvim --headless +q
```

## Done Criteria

- A written plugin decision exists.
- Existing capabilities are exposed before new installs.
- At most one new plugin is trialed in the first pass.
- Interactive git review is better than before, not merely different.
