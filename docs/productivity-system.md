# Productivity system

Neovim shortcuts for the plain-Markdown planning system in `~/vaults/obsidian-notes`.

The vault path is read from `lua/custom/configs/obsidian.lua`, so the workflow stays aligned with the configured Obsidian workspace.

## Mental model

The editor should make the trusted layers cheap to enter:

- Today — the command center.
- This week — commitments and WIP limits.
- Tasks — the warehouse.
- Someday — non-commitments.
- Projects — outcome-specific thinking and next actions.
- Inbox — capture without context-switching.

## Mappings

| Mapping | Action |
| --- | --- |
| `<leader>ot` | Open/create today's note |
| `<leader>ow` | Open/create this week's note |
| `<leader>oa` | Open the master task warehouse |
| `<leader>os` | Open Someday |
| `<leader>op` | Browse project files with Telescope |
| `<leader>oi` | Capture a task into today's Inbox |
| `<leader>or` | Open the productivity-system reference |

## Commands

- `:Today`
- `:Week`
- `:Tasks`
- `:Someday`
- `:Projects`
- `:Capture`
- `:ProductivitySystem`

## Behavior

`Today` and `Week` are fail-safe: if the expected note does not exist, Neovim creates the directory and a minimal Markdown template before opening it.

`Capture` asks for a single item and writes it under `## Inbox` in today's note. This is intentionally optimized for staying inside the current context rather than opening another task manager.

## Constraints kept deliberately simple

- No new Neovim plugins.
- No Dataview/Tasks/Templater dependency.
- No database or hidden state.
- Plain files remain usable from Obsidian, Neovim, GitHub, shell tools, or any future automation.

The system should run manually for a while before adding automation beyond repeated real friction.
