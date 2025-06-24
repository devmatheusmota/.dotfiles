-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      follow_current_file = true, -- This will make the current file be highlighted in the Neo-tree
      filtered_items = {
        visible = true, -- when true, they will just be displayed differently than normal items
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          '.DS_Store',
          'thumbs.db',
          'node_modules',
          '.git',
          '.hg',
          '.svn',
        },
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
    event_handlers = {
      {
        event = 'file_renamed',
        handler = function(args)
          local old_path = vim.loop.fs_realpath(args.source) or vim.fn.fnamemodify(args.source, ':p')
          local new_path = vim.loop.fs_realpath(args.destination) or vim.fn.fnamemodify(args.destination, ':p')
          if not old_path or not new_path then
            return
          end
          local ok, harpoon = pcall(require, 'harpoon')
          if not ok then
            return
          end
          local project_root = vim.fn.getcwd()
          local list = harpoon.lists[project_root] and harpoon.lists[project_root].__harpoon_files
          local items = list and list.items or {}
          for i, item in ipairs(items) do
            local item_abs = vim.fn.fnamemodify(item.value, ':p')
            if item_abs == old_path then
              item.value = vim.fn.fnamemodify(new_path, ':.')
              return
            end
          end
        end,
      },
    },
  },
}
