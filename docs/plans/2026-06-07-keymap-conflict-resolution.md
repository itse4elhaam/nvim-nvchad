# Keymap Conflict Resolution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `executing-plans` or `subagent-driven-development` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve the real `:checkhealth` keymap conflict pain without churning the user's muscle memory.

**Architecture:** Treat keymaps as product surface, not cleanup fodder. Fix only conflicts that create ambiguous leader prefixes or broken discoverability, while preserving the established AI/git/find/navigation namespaces.

**Tech Stack:** Neovim Lua, NvChad `load_mappings`, `lua/custom/mappings.lua`, `lua/core/mappings.lua`, plugin key specs in `lua/custom/plugins.lua` and `lua/custom/configs/*`.

---

## Strict Execution Rules

1. **Do not start by editing.** First reproduce the conflicts with `:checkhealth` or targeted keymap inspection.
2. **Do not remove mappings because they look ugly.** Remove only if unused, obsolete, or directly conflicting.
3. **Do not change `<leader>a`, `<leader>g`, `<leader>f`, or `<C-h/j/k/l>` semantics without explicit approval.**
4. **Do not run `stylua .`.** Format only touched Lua files.
5. **Do not commit until verification passes and the user asks for a commit.**
6. **Every changed mapping must have a human reason:** conflict avoided, namespace clarified, or obsolete binding removed.

## Known Conflict Inventory

| Priority | Conflict | Current Problem | Preferred Direction |
|---|---|---|---|
| High | Harpoon `<leader>9` vs `99.nvim` `<leader>9*` | Single-key mapping shadows a whole namespace | Move Harpoon numbered jumps to `<leader>h1..h9` or move 99.nvim to `<leader>99*` |
| High | Single `<leader>s` vs `<leader>s*` | Split command blocks a rich search/split namespace | Rename single split mapping to `<leader>ss` or remove if redundant |
| High | Single `<leader>w` vs `<leader>w*` | Write-all shadows write/window/workflow group | Rename to `<leader>ww` or use command-line `:wa` |
| Medium | Snacks Zen `<leader>zn` vs legacy TrueZen `<leader>zn*` | Old and new zen systems overlap | Remove legacy `M.true_zen` if Snacks Zen is active |
| Medium | CodeCompanion `<leader>cc` vs core context jump | AI workflow conflicts with core context mapping | Keep AI mapping only if CodeCompanion is active; otherwise restore core |

## Files to Inspect Before Editing

- `lua/custom/mappings.lua` — primary custom mappings.
- `lua/core/mappings.lua` — NvChad/core defaults and overrides.
- `lua/custom/plugins.lua` — plugin key specs, lazy-loading keys.
- `lua/custom/configs/harpoon.lua` — Harpoon-specific bindings if present.
- `lua/custom/configs/codecompanion.lua` — only if CodeCompanion mappings still load.

## Task 1: Capture the Current Conflict Report

- [ ] Run Neovim health focused on mappings.

```bash
nvim --headless '+checkhealth vim.health' '+qall'
```

Expected: no startup crash. If mapping conflicts are only visible interactively, open Neovim and run `:checkhealth` manually.

- [ ] Save a short note in the implementation log with exact conflicts observed.

Do **not** proceed if the conflict list differs substantially from the inventory above; update this plan first.

## Task 2: Fix Single-Key Leader Shadows

**Files:**
- Modify: `lua/custom/mappings.lua`
- Possibly modify: `lua/custom/plugins.lua`

- [ ] Locate exact mappings for `<leader>9`, `<leader>s`, and `<leader>w`.

Use targeted search only. Do not rewrite the mapping file.

- [ ] Change only the conflicting single-key mappings.

Preferred outcomes:

```lua
-- Harpoon numbered jumps: prefer h-prefix if 99.nvim owns <leader>9
-- <leader>h1 ... <leader>h9

-- Split/write single-key mappings:
-- <leader>s  -> <leader>ss  OR remove if redundant
-- <leader>w  -> <leader>ww  OR remove if redundant
```

- [ ] Keep descriptions accurate so which-key/help text remains useful.

## Task 3: Retire Legacy Zen Conflict

**Files:**
- Modify: `lua/custom/mappings.lua`
- Possibly inspect: `lua/custom/plugins.lua`

- [ ] Confirm Snacks Zen is the active zen workflow.
- [ ] Remove or disable legacy `M.true_zen` mappings only if TrueZen is no longer configured.
- [ ] Preserve any unique zen behavior by moving it to a non-conflicting namespace only if it is still used.

## Task 4: Verify Mapping Behavior

- [ ] Check formatting on touched Lua files only.

```bash
/home/elhaam/.local/share/nvim/mason/bin/stylua --check lua/custom/mappings.lua lua/custom/plugins.lua
```

Expected: PASS, except for explicitly documented pre-existing style differences outside touched regions.

- [ ] Run startup smoke test.

```bash
nvim --headless +q
```

Expected: exit code 0.

- [ ] Open Neovim interactively and test:
  - `which-key` display for changed prefixes.
  - New Harpoon jump bindings.
  - Split/write mappings.
  - Zen mapping.

## Rollback Plan

```bash
git checkout -- lua/custom/mappings.lua lua/custom/plugins.lua lua/custom/configs/harpoon.lua
nvim --headless +q
```

## Done Criteria

- `:checkhealth` no longer reports the targeted keymap conflicts.
- No unrelated mappings changed.
- Startup passes.
- Interactive smoke test confirms changed mappings work.
