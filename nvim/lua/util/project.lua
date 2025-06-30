local M = {}

-- Usa o root da LSP se existir, senão usa o diretório atual
function M.get_root()
  local clients = vim.lsp.get_active_clients { bufnr = 0 }
  for _, client in ipairs(clients) do
    local workspace = client.config.root_dir
    if workspace then
      return workspace
    end
  end
  return vim.fn.getcwd()
end

return M
