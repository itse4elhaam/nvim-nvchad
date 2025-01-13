local config = function()
  require("timber").setup {
    log_templates = {
      default = {
        typescript = [[
  console.log(`
    %filename:%line_number
    %log_target ->
    ${%log_target}
  `)
]],
        javascript = [[
  console.log(`
    %filename:%line_number
    %log_target ->
    ${%log_target}
  `)
]],
        jsx = [[
  console.log(`
    %filename:%line_number
    %log_target ->
    ${%log_target}
  `)
]],
        tsx = [[
  console.log(`
    %filename:%line_number
    %log_target ->
    ${%log_target}
  `)
]],
      },
    },
    batch_log_templates = {
      default = {
        javascript = [[console.table({ %repeat<"%log_target": %log_target><, > })]],
        typescript = [[console.table({ %repeat<"%log_target": %log_target><, > })]],
        jsx = [[console.table({ %repeat<"%log_target": %log_target><, > })]],
        tsx = [[console.table({ %repeat<"%log_target": %log_target><, > })]],
      },
    },
    log_marker = "VimLogs",
    log_watcher = {
      enabled = true,
      sources = {
        log_file = {
          type = "filesystem",
          name = "Log file",
          path = "/tmp/vim-logs.log",
        },
      },
    },
  }
end

return config
