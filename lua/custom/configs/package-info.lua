return {
  colors = {
    up_to_date = "#3C4048", -- Text color for up to date package virtual text
    outdated = "#fc514e",   -- Text color for outdated package virtual text
  },
  icons = {
    enable = true,               -- Whether to display icons
  },
  autostart = true,              -- Whether to autostart when `package.json` is opened
  hide_up_to_date = true,        -- It hides up to date versions when displaying virtual text
  hide_unstable_versions = true, -- It hides unstable versions from version list e.g next-11.1.3-canary3

  package_manager = "yarn",
}
