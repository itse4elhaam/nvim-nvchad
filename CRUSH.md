# CRUSH Code Style & Commands

This file outlines the code style, formatting conventions, and common commands for this project.

## Commands

- **Build**: `echo "No build command specified"`
- **Lint**: `stylua .`
- **Test**: `echo "No test command specified"`
  - **Run single test**: `echo "No single test command specified"`

## Code Style

### Formatting
- **Column Width**: 120
- **Line Endings**: Unix
- **Indent Type**: Spaces (width: 2)
- **Quotes**: Double quotes are preferred.
- **Call Parentheses**: Omitted when possible.

### Naming Conventions
- **Variables**: `snake_case`
- **Functions**: `snake_case`
- **Modules**: `snake_case`

### Imports
- `require` statements should be at the top of the file.
- Group imports by standard library, third-party, and local modules.

### Types
- Type annotations are encouraged where applicable.

### Error Handling
- Use `pcall` or `xpcall` for functions that may error.
- Return `nil` and an error message on failure.
