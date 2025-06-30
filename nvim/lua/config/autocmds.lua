vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local argv = vim.fn.argv()
    if #argv > 0 then
      local cwd = vim.loop.cwd()
      local first_file = argv[1]

      -- Se não for caminho absoluto, concatena manualmente com o CWD
      if not first_file:match '^/' then
        first_file = cwd .. '/' .. first_file
      end

      local first_file_dir = vim.fn.fnamemodify(first_file, ':h')
      if vim.fn.isdirectory(first_file_dir) == 1 then
        vim.cmd('cd ' .. vim.fn.fnameescape(first_file_dir))
      else
        vim.notify('Diretório não encontrado: ' .. first_file_dir, vim.log.levels.WARN)
      end
    end
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
