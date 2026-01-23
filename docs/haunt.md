# Haunt.nvim Integration Guide

## What is haunt.nvim?

Haunt.nvim is a powerful bookmark annotation plugin that allows you to annotate specific lines in your code with persistent notes displayed as virtual text (ghost text). Perfect for marking important code sections, TODOs, or leaving notes for yourself.

## Key Features

✅ **Annotate lines** with persistent ghost text notes
✅ **Git branch aware** - annotations persist per branch
✅ **Snacks picker** integration for quick navigation
✅ **Sidekick integration** - see all bookmarks in sidebar
✅ **Quickfix support** - send bookmarks to quickfix list
✅ **Yank locations** - copy bookmark locations to clipboard

## Power User Keymaps

All keymaps use the `<leader>h` prefix for ergonomic access:

| Keymap       | Function      | Description                                  |
| ------------ | ------------- | -------------------------------------------- |
| `<leader>hm` | Mark/Annotate | Create or edit bookmark on current line      |
| `<leader>ht` | Toggle        | Toggle annotation visibility on current line |
| `<leader>hd` | Delete        | Delete bookmark on current line              |
| `<leader>hc` | Clear         | Clear all bookmarks in current buffer        |
| `<leader>hC` | Clear All     | Clear ALL bookmarks across all files         |
| `<leader>hp` | Picker        | Open snacks picker to browse all bookmarks   |
| `<leader>hn` | Next          | Jump to next bookmark                        |
| `<leader>hN` | Previous      | Jump to previous bookmark                    |
| `<leader>hq` | Quickfix      | Send all bookmarks to quickfix list          |
| `<leader>hy` | Yank          | Copy all bookmark locations to clipboard     |
| `<leader>ha` | Toggle All    | Toggle visibility of all annotations         |

## Sidekick Integration

The **gold feature** you requested! Bookmarks automatically appear in the sidekick sidebar with:

- 📍 **Icon:** `󱚝` for easy visual identification
- 📋 **Format:** `@/{path}:L{line} - "{note}"`
- 🔄 **Auto-update:** Updates on `User HauntUpdate` event
- 🎨 **Styled section:** " Bookmarks" header with custom icon

To view bookmarks in sidekick, just open the sidebar and they'll be there!

## Usage Workflow

### Basic Annotation

1. Move cursor to the line you want to bookmark
2. Press `<leader>hm`
3. Enter your annotation text
4. Ghost text appears at end of line

### Navigation

- Use `<leader>hp` to see all bookmarks in picker
- Use `<leader>hn` / `<leader>hN` to jump between bookmarks
- Click on bookmark in sidekick to jump to location

### Organization

- Use `<leader>hq` to send to quickfix for bulk operations
- Use `<leader>hy` to copy locations (great for documentation)
- Use `<leader>hc` to clean up buffer-specific bookmarks

## Configuration Details

### Visual Style

- **Sign:** `󱚝` (bookmark icon in gutter)
- **Sign highlight:** `DiagnosticInfo` (blue by default)
- **Virtual text:** `HauntAnnotation` highlight group
- **Prefix:** `  ` (note icon + space)
- **Position:** End of line (`eol`)

### Picker Actions

When in picker (`<leader>hp`):

- Press `d` to delete bookmark
- Press `a` to edit annotation

### Data Storage

Bookmarks are stored in: `~/.local/share/nvim/haunt/`

- Git branch aware
- Persists across sessions
- JSON format for easy migration

## Integration Status

✅ **Snacks.nvim** - Picker integration enabled
✅ **Sidekick.nvim** - Sidebar section configured
✅ **Git** - Branch-aware persistence
✅ **Quickfix** - Full support
✅ **Clipboard** - Yank locations support

## Tips & Tricks

1. **Quick annotation:** `<leader>hm` → type note → Enter (super fast!)
2. **Review all:** `<leader>hp` to see picker with all bookmarks
3. **Sidebar view:** Open sidekick to see bookmarks organized by file
4. **Code review:** Use `<leader>hq` to review all bookmarks in quickfix
5. **Documentation:** `<leader>hy` to get all locations for docs/wikis

## Harper Keymap Change

⚠️ **Note:** Harper grammar check keymap changed from `<leader>ht` to `<leader>hg` to avoid conflict with haunt toggle.

- **Harper toggle:** `<leader>hg` (grammar check)
- **Haunt toggle:** `<leader>ht` (bookmark visibility)
