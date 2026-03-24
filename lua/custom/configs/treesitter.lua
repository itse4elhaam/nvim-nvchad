-- zsh has no dedicated treesitter parser; use bash parser instead
vim.treesitter.language.register("bash", "zsh")

local options = {
  ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
    "lua",
    "javascript",
    "typescript",
    "tsx",
    "go",
    "css",
    "markdown",
    "bash",
    "json",
    "yaml",
    "toml",
    "json5",
    "python",
    "html",
    "rust",
    "c",
    "cpp",
    "sql",
  },
  highlight = {
    enable = true,
    use_languagetree = true,
  },

  indent = { enable = true },
}

return options
