return {
  'mason-org/mason.nvim',
  opts = { ensure_installed = { 'lazygit' } },
  keys = function()
    local Project = require 'util.project'

    return {
      {
        '<leader>gG',
        function()
          Snacks.terminal { 'lazygit' }
        end,
        desc = 'lazygit (cwd)',
      },
      {
        '<leader>gg',
        function()
          Snacks.terminal({ 'lazygit' }, { cwd = Project.get_root() })
        end,
        desc = 'lazygit (Root Dir)',
      },
    }
  end,
  init = function()
    -- delete lazygit keymap for file history
    vim.api.nvim_create_autocmd('User', {
      pattern = 'LazyVimKeymaps',
      once = true,
      callback = function()
        pcall(vim.keymap.del, 'n', '<leader>gf')
        pcall(vim.keymap.del, 'n', '<leader>gl')
      end,
    })
  end,
}
