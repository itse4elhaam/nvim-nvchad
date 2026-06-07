# Nvim Dotfiles Unification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `executing-plans` or `subagent-driven-development` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move `/home/elhaam/.config/nvim` into `/home/elhaam/dotfiles/.config/nvim` so Neovim and dotfiles are one active repository.

**Architecture:** Preserve nvim history by rewriting it under `.config/nvim/`, merging it into the dotfiles repo, then replacing the live `~/.config/nvim` real directory with a stow-managed symlink. The old nvim repo remains backed up until verification is complete.

**Tech Stack:** git, `git-filter-repo`, GNU Stow, Neovim headless startup checks, shell with `set -euo pipefail` discipline.

---

## Strict Execution Rules

1. **Do not execute this while either repo is dirty.** Both repos must be clean first.
2. **Do not run migration from inside an active Neovim session that you rely on.** Use a separate terminal.
3. **Do not delete the old nvim directory.** Move it aside as a dated backup first.
4. **Do not use submodules.** The user explicitly wants one repo, not separate repos.
5. **Do not choose simple copy unless the user accepts losing nvim history.**
6. **Do not run `git reset --hard`, `git clean`, or force-push.**
7. **Do not push dotfiles until stow and `nvim --headless +q` pass.**

## Current Known State

- `/home/elhaam/.config/nvim` is a real standalone git repo, not a symlink.
- `/home/elhaam/dotfiles` is the dotfiles repo.
- Dotfiles does not currently contain `.config/nvim`.
- Dotfiles uses Stow-style symlinks for `.config/ghostty`, `.config/lazygit`, `.config/opencode`, etc.
- Recent nvim changes were committed and pushed as `fd5dcd3`.

## Recommended Strategy

Use `git filter-repo` + `git merge --allow-unrelated-histories`.

Why:

- Preserves the nvim repo's history.
- Produces one real dotfiles repo.
- Avoids submodule dual-repo friction.
- Keeps future edits in `~/dotfiles/.config/nvim`.

## Task 1: Preflight and Backups

- [ ] Confirm clean repos.

```bash
git -C /home/elhaam/.config/nvim status --short --branch
git -C /home/elhaam/dotfiles status --short --branch
```

Expected: no modified/untracked files that are not intentionally handled.

- [ ] Create backups.

```bash
git clone --mirror /home/elhaam/.config/nvim /tmp/nvim-backup.git
git clone --mirror /home/elhaam/dotfiles /tmp/dotfiles-backup.git
tar czf /tmp/nvim-config-backup-$(date +%Y%m%d).tgz -C /home/elhaam/.config nvim
git -C /home/elhaam/.config/nvim rev-parse HEAD > /tmp/nvim-pre-migration-head.txt
git -C /home/elhaam/dotfiles rev-parse HEAD > /tmp/dotfiles-pre-migration-head.txt
```

## Task 2: Rewrite Nvim History Under `.config/nvim/`

- [ ] Install `git-filter-repo` if missing.

```bash
command -v git-filter-repo || pip install --user git-filter-repo
```

- [ ] Rewrite in a temp clone, not the live config.

```bash
TMPDIR=$(mktemp -d)
git clone --no-hardlinks /home/elhaam/.config/nvim "$TMPDIR/nvim-rewrite"
cd "$TMPDIR/nvim-rewrite"
git filter-repo --path-rename /:.config/nvim/ --force
```

## Task 3: Merge Into Dotfiles

- [ ] Add temp remote and merge.

```bash
cd /home/elhaam/dotfiles
git remote add nvim-import "$TMPDIR/nvim-rewrite"
git fetch nvim-import
git merge nvim-import/dev --allow-unrelated-histories --no-edit
git remote remove nvim-import
```

If the branch is not `dev`, inspect `git branch -a` in the temp clone and merge the correct branch.

## Task 4: Review Ignore Files

- [ ] Keep nvim-specific ignores in `.config/nvim/.gitignore` unless there is a concrete reason to move them.
- [ ] Ensure generated directories remain ignored:
  - `plugin`
  - `spell`
  - `ftplugin`
  - `syntax`
  - `node_modules/`
  - `tmp/`
  - `.crush/`

## Task 5: Replace Live Config with Stow Symlink

- [ ] Move live directory aside.

```bash
mv /home/elhaam/.config/nvim /home/elhaam/.config/nvim.bak.$(date +%Y%m%d)
```

- [ ] Stow from dotfiles.

```bash
cd /home/elhaam/dotfiles
stow .config
```

If Stow reports conflicts, stop. Do not force. Restore from rollback or fix the specific conflict.

## Task 6: Verify

```bash
ls -la /home/elhaam/.config/nvim
readlink -f /home/elhaam/.config/nvim
git -C /home/elhaam/dotfiles status --short
git -C /home/elhaam/dotfiles ls-files .config/nvim | wc -l
git -C /home/elhaam/dotfiles log --oneline --follow .config/nvim/init.lua | head
nvim --headless +q
```

Expected:

- `~/.config/nvim` is a symlink into `/home/elhaam/dotfiles/.config/nvim`.
- Dotfiles status shows only intended migration changes.
- Neovim starts with exit code 0.

## Task 7: Commit and Push Dotfiles

Only after verification:

```bash
git -C /home/elhaam/dotfiles add .config/nvim .gitignore .stow-local-ignore
git -C /home/elhaam/dotfiles commit -m "chore(dotfiles): absorb nvim config"
git -C /home/elhaam/dotfiles push origin dev
```

Adjust staged files based on actual changes. Do not stage unrelated dotfiles work.

## Rollback Plan

```bash
# Remove bad symlink if created
rm -f /home/elhaam/.config/nvim

# Restore original nvim directory
mv /home/elhaam/.config/nvim.bak.<date> /home/elhaam/.config/nvim

# Reset dotfiles to pre-migration state using recorded HEAD
cd /home/elhaam/dotfiles
git reset --hard "$(cat /tmp/dotfiles-pre-migration-head.txt)"

# Verify nvim still works
nvim --headless +q
```

Only use `reset --hard` here if the user explicitly approves rollback and there are no unrelated dotfiles changes. Otherwise use `git revert` for the merge commit.

## Done Criteria

- `~/.config/nvim` is stow-managed from dotfiles.
- Dotfiles contains `.config/nvim` with preserved history.
- Old standalone nvim repo is no longer the active edit location.
- `nvim --headless +q` passes.
- Dotfiles push succeeds.
