return {
  "okuuva/auto-save.nvim",
  cmd = "ASToggle", -- optional for lazy loading on command
  event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
  opts = {},
  init = function()
    -- Mark autosave writes so conform skips format_on_save for them
    local group = vim.api.nvim_create_augroup("autosave_no_format", {})
    vim.api.nvim_create_autocmd("User", {
      pattern = "AutoSaveWritePre",
      group = group,
      callback = function()
        vim.g.autosave_in_progress = true
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "AutoSaveWritePost",
      group = group,
      callback = function()
        vim.g.autosave_in_progress = false
      end,
    })
  end,
}
