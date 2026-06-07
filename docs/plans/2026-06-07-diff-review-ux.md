# Diff Review UX Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `executing-plans` or `subagent-driven-development` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make actual git diff content easy to see while editing files, not just added/removed signs.

**Architecture:** Start with the already-installed/known diff stack. `gitsigns.nvim` owns hunk-level review, `CodeDiff` owns full-file/full-branch review, and any new plugin must cover a clearly missing visual mode.

**Tech Stack:** `gitsigns.nvim`, existing `CodeDiff`/VSCode-style diff tooling, Neovim Lua mappings, optional `mini.diff`/Diffview/lazydiff evaluation.

---

## Strict Execution Rules

1. **Do not install Diffview by default.** It was previously considered heavy; only add after current tools fail.
2. **Do not replace `gitsigns`.** It remains the first-line hunk tool.
3. **Do not create overlapping mappings with the keymap-conflict plan.**
4. **Do not change branch/review behavior without testing on a real changed file.**
5. **Every mapping must answer: hunk, file, or branch?** Avoid vague “diff” commands.

## Desired User Experience

When a file has git changes, the user should be able to:

1. See the changed hunk inline.
2. See deleted lines/content, not only a sign column marker.
3. Jump across hunks.
4. Open a full-file diff against `HEAD` or base branch.
5. Open a full-branch review for OpenCode-generated changes.
6. Stage/reset one hunk without leaving Neovim.

## Task 1: Inventory Current Diff Commands

**Files:**
- Inspect: `lua/custom/mappings.lua`
- Inspect: `lua/custom/plugins.lua`
- Inspect: `lua/custom/configs/*diff*`, `lua/custom/configs/gitsigns.lua` if present

- [ ] List existing commands/mappings for `gitsigns` preview, word diff, qflist, and stage/reset.
- [ ] List existing `CodeDiff` commands and mappings.
- [ ] Identify missing actions only after reading current config.

## Task 2: Add a Coherent Diff Namespace

**Files:**
- Modify: `lua/custom/mappings.lua`

Use these names only if free after conflict check:

```lua
-- Hunk-level: <leader>h*
-- <leader>hp preview hunk
-- <leader>hi preview hunk inline
-- <leader>hw toggle word diff
-- <leader>hQ hunks to qflist
-- <leader>hs stage hunk
-- <leader>hr reset hunk

-- Review-level: <leader>gD / <leader>gd
-- <leader>gD full CodeDiff review
-- <leader>gd quick current-file diff
```

If `<leader>h` is already overloaded by Harpoon/bookmarks, reconcile with the keymap-conflict plan before editing.

## Task 3: Decide Whether Persistent Inline Diff Is Needed

- [ ] Use current `gitsigns.preview_hunk_inline` on changed files.
- [ ] If deleted content is still not visible enough, trial `mini.diff`.
- [ ] If full-file review is not enough, improve `CodeDiff` command wrappers before adding Diffview.

## Task 4: Verify on Real Git Changes

- [ ] Create or use an existing harmless change in a Lua file.
- [ ] Open the file in Neovim.
- [ ] Test inline hunk preview.
- [ ] Test deleted-line visibility.
- [ ] Test full-file diff.
- [ ] Test hunk stage/reset only on a deliberate temporary change.
- [ ] Revert temporary test change.

## Commands

```bash
/home/elhaam/.local/share/nvim/mason/bin/stylua --check lua/custom/mappings.lua
nvim --headless +q
```

## Rollback Plan

```bash
git checkout -- lua/custom/mappings.lua lua/custom/plugins.lua lua/custom/configs
nvim --headless +q
```

## Done Criteria

- The user can see actual diff content from inside an opened file.
- Full-file/branch diff remains available through existing `CodeDiff` direction.
- No heavy plugin was added unless it beat existing tools in a real review.
