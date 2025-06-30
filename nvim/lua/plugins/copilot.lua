return {
  'github/copilot.vim',
  config = function()
    vim.g.copilot_filetypes = {
      go = false,
    }
  end,
}
