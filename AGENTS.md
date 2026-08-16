# Agent Guidelines for Neovim Config

## Prime Directive

This is a daily-driver Neovim config. Changes must preserve startup, editing,
AI workflow, git review, terminal/tmux integration, and writing-mode behavior.
Prefer small reversible improvements over broad rewrites.

## User Taste and Product Priorities

- Small UX experiments are welcome when they are easy to undo.
- Writing/distraction-free flows matter: markdown/text/typst/latex behavior must
  stay calm and readable.
- Workflow keymaps matter more than theoretical neatness; do not churn mappings
  unless a real conflict or broken behavior exists.
- Prefer composable terminal/git/tmux helpers over heavyweight UI replacements.
- Plugin swaps/removals are acceptable only when they reduce friction or replace
  something already unused.
- Avoid broad formatting churn. The user explicitly dislikes non-required diffs.
- Performance is very paramount and important - no change should cause lag or delay while editing text.

## Commands

- **Format touched Lua files only**: `stylua <file1> <file2>`
- **Check formatting without churn**: `stylua --check <file1> <file2>`
- **Do not run `stylua .`** unless the user explicitly asks for whole-repo
  formatting.
- **Startup smoke test**: `nvim --headless +q`
- **Targeted module test**:
  `nvim --headless +'lua require("custom.configs.<module>")' +q`
- **No automated test suite is configured**; use targeted Neovim verification.

## Verification Requirements

After any change, verify before claiming success:

1. Inspect the diff: `git diff --stat` and targeted `git diff`.
2. Run `stylua --check` on touched Lua files, or explain why formatting was not
   run to avoid unwanted churn.
3. Run `nvim --headless +q` for every config change.
4. Run targeted headless file/module checks for changed plugin configs.
5. If UI, keymaps, themes, completion, picker windows, terminal behavior, or git
   review flows changed, open Neovim yourself and verify interactively.
6. Treat new startup errors as blockers. Treat unrelated pre-existing
   `:checkhealth` warnings as informational unless the change caused them.

## Code Style

- 120 char width, 2-space indents, Unix line endings, double quotes preferred.
- Use `snake_case` for variables, functions, and modules.
- Keep `require` calls near the top when they are hard dependencies.
- For optional plugins/providers, wrap `require` or extension loading in `pcall`.
- Do not add global `require` monkeypatches or broad error suppression.
- Public module exports use `M.<name>`; private helpers use `local function`.
- Use LuaLS annotations for public APIs when they clarify behavior.
- Prefer named tables for plugin configs and return config tables/functions.

## Plugin Architecture

- `lua/custom/plugins.lua` contains categorized plugin groups.
- Plugin configs live in `lua/custom/configs/<plugin>.lua` with `opts`, `config`,
  or `dependencies` as appropriate.
- Preserve lazy-loading triggers: `lazy`, `event`, `cmd`, `keys`, and `ft`.
- Declare dependencies explicitly when load order matters.
- Hard dependencies may fail loudly; optional integrations should degrade with
  `pcall` and keep the editor usable.
- Do not remove or replace existing plugins without checking current usage,
  mappings, and commit-history intent.

## Keymap Rules

- Custom mappings live in `lua/custom/mappings.lua` and load via
  `load_mappings` from `core.utils`.
- Search existing mappings before adding new ones.
- Preserve these namespaces unless deliberately refactoring them:
  - `<leader>a` for AI/assistant workflows
  - `<leader>g` for git and review flows
  - `<leader>f` for find/pickers
  - `<leader>h` for hunks/bookmarks if non-conflicting
  - `<C-h/j/k/l>` window/navigation behavior
- Avoid single-key leader mappings that shadow groups, especially `<leader>s`,
  `<leader>w`, and `<leader>9`.
- Known conflict areas to handle carefully: Harpoon vs `99.nvim`, legacy TrueZen
  vs Snacks Zen, CodeCompanion vs core context mappings, and completion `<Tab>`.

## Pull Request Base

- All pull requests must target the `dev` branch unless the user explicitly requests another base.
- Create feature and fix branches from the latest `dev` branch to avoid unrelated history in the diff.

## Git/Diff Review Direction

- `gitsigns.nvim` is the first-line hunk tool: preview hunks, inline previews,
  word diff, qflist, stage/reset hunk.
- Existing `CodeDiff`/VSCode-style diff tooling is preferred for full-file or
  branch review before adding heavier diff plugins.

## Must Follow

- Never leave the config in a broken state.
- Never commit without explicit user request.
- Never hide failures with `as any`, `@ts-ignore`, empty catches, or silent broad
  suppression patterns.
- Do not speculate about unread code; inspect the relevant files first.
- When changing this repo, run Neovim yourself and make it ready to use.
