# Sidekick.nvim & Copilot Language Server Integration

This document explains the integration of both `folke/sidekick.nvim` and the GitHub Copilot Language Server into your NvChad configuration.

## What's Been Integrated

### 1. Sidekick.nvim
- **Repository**: https://github.com/folke/sidekick.nvim
- **Purpose**: AI sidekick that integrates Copilot LSP's "Next Edit Suggestions" with built-in terminal for AI CLI tools
- **Key Features**:
  - Next Edit Suggestions (NES) powered by Copilot LSP
  - Rich diffs with syntax highlighting
  - Integrated AI CLI terminal
  - Pre-configured for popular AI tools (Claude, Gemini, Grok, Copilot CLI)
  - Session persistence with tmux/zellij

### 2. GitHub Copilot Language Server
- **Repository**: https://github.com/github/copilot-language-server-release
- **Purpose**: Official GitHub Copilot Language Server Protocol implementation
- **Installation**: Globally installed via npm (`@github/copilot-language-server`)

## Configuration Files Added/Modified

### New Configuration Files
1. `/lua/custom/configs/sidekick.lua` - Sidekick plugin configuration
2. `/lua/custom/configs/copilot.lua` - Copilot LSP configuration

### Modified Files
1. `/lua/custom/plugins.lua` - Added sidekick to AI plugins section
2. `/lua/custom/mappings.lua` - Added key mappings for both sidekick and copilot
3. `/lua/custom/configs/lspconfig.lua` - Integrated copilot LSP server

## Key Mappings

### Sidekick Mappings
- `<leader>sk` - Jump to/Apply Next Edit Suggestion
- `<leader>aa` - Toggle Sidekick CLI
- `<leader>as` - Select AI Prompt
- `<leader>ach` - Toggle Claude CLI
- `<leader>acp` - Toggle Copilot CLI  
- `<leader>agm` - Toggle Gemini CLI
- `<leader>agr` - Toggle Grok CLI
- `<leader>sn` - Update Next Edit Suggestions
- `<leader>sj` - Jump to Next Edit
- `<leader>sa` - Apply Next Edit Suggestions
- `<leader>sc` - Clear Sidekick Suggestions
- `<c-.>` - Switch Focus to CLI

### Copilot LSP Mappings
- `<leader>cps` - Copilot Status
- `<leader>cpi` - Copilot Sign In
- `<leader>cpo` - Copilot Sign Out
- `<leader>cpe` - Copilot Enable
- `<leader>cpd` - Copilot Disable

## Getting Started

### 1. Authentication
First, authenticate with GitHub Copilot:
```vim
:LspCopilotSignIn
```
Or use the mapping:
```vim
<leader>cpi
```

### 2. Using Next Edit Suggestions (NES)
- NES automatically triggers when you pause typing or move cursor
- Use `<leader>sk` to jump to or apply suggestions
- Use `<leader>sn` to manually request fresh suggestions

### 3. AI CLI Integration
- Use `<leader>aa` to open/focus the AI CLI terminal
- Use `<leader>as` to browse available prompts
- Direct access to specific AI tools:
  - `<leader>ach` for Claude
  - `<leader>acp` for Copilot CLI
  - `<leader>agm` for Gemini
  - `<leader>agr` for Grok

### 4. Pre-configured Prompts
Available prompts include:
- `explain` - Explain this code
- `diagnostics` - What do the diagnostics mean?
- `fix` - Fix issues in this code
- `review` - Review code for improvements
- `optimize` - How can this code be optimized?
- `tests` - Write tests for this code
- `refactor` - Refactor code for better maintainability
- `document` - Add comprehensive documentation

## Configuration Highlights

### Sidekick Configuration
- **Backend**: Uses tmux for session persistence (matches your setup)
- **Layout**: Vertical layout, 80x20 window on the right
- **Diff**: Word-level inline diffs enabled
- **Auto-watch**: Automatically reloads files modified by AI tools

### Copilot LSP Configuration
- **Filetypes**: Comprehensive list including Python, Go, Lua, JS/TS, etc.
- **Capabilities**: Enhanced with blink.cmp integration
- **Fallback**: Graceful fallback if NvChad isn't fully loaded
- **Logging**: Verbose tracing for debugging (can be disabled)

## Integration with Existing Plugins

### AI Ecosystem
Sidekick complements your existing AI plugins:
- **codecompanion.nvim** - For chat-based interactions
- **opencode.nvim** - For direct code operations
- **wtf.nvim** - For error explanations

### LSP Integration
- Works seamlessly with your existing LSP setup
- Respects your blink.cmp configuration
- Follows your NvChad on_attach patterns

### Key Binding Philosophy
- Uses `<leader>a*` prefix for AI-related operations
- Uses `<leader>cp*` prefix for Copilot-specific commands
- Uses `<leader>s*` prefix for Sidekick-specific operations
- Maintains consistency with your existing mapping patterns

## Health Check

To verify the installation:
```vim
:checkhealth sidekick
```

## Troubleshooting

### Common Issues
1. **Copilot not authenticated**: Run `:LspCopilotSignIn`
2. **CLI tools not found**: Install the desired CLI tools (claude, grok, etc.)
3. **NES not working**: Ensure Copilot LSP is running and authenticated
4. **Sidekick not loading**: Check that the plugin was properly installed by Lazy

### Debug Information
- Enable debug mode in sidekick config: `debug = true`
- Check LSP status: `:LspInfo`
- Check Copilot status: `<leader>cps`

## Advanced Usage

### Custom Prompts
Add custom prompts to sidekick configuration:
```lua
prompts = {
  custom_prompt = {
    msg = "Your custom prompt here",
    diagnostics = true, -- Include diagnostics
  }
}
```

### Custom AI Tools
Add custom CLI tools:
```lua
tools = {
  mycli = { 
    cmd = { "mycli", "--option" }, 
    url = "https://github.com/myorg/mycli" 
  }
}
```

## Performance Notes

- Sidekick debounces requests (100ms) to avoid excessive API calls
- NES clears on insert mode to avoid interference
- Large file handling is already optimized in your base config
- CLI sessions persist with tmux for better performance

This integration provides a comprehensive AI coding assistant while maintaining the performance and user experience of your existing NvChad setup.