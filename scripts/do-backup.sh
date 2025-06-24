#!/usr/bin/env bash

backup_dir="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "📦 Criando backup em: $backup_dir"
mkdir -p "$backup_dir"

# Arquivos na home
cp -v "$HOME/.zshrc" "$backup_dir/" 2>/dev/null || echo "⚠️ .zshrc não encontrado"
cp -v "$HOME/.gitconfig" "$backup_dir/" 2>/dev/null || echo "⚠️ .gitconfig não encontrado"
cp -v "$HOME/.tmux.conf" "$backup_dir/" 2>/dev/null || echo "⚠️ .tmux.conf não encontrado"
cp -v "$HOME/.tmux-cht-command" "$backup_dir/" 2>/dev/null || echo "⚠️ .tmux-cht-command não encontrado"
cp -v "$HOME/.tmux-cht-languages" "$backup_dir/" 2>/dev/null || echo "⚠️ .tmux-cht-languages não encontrado"

# Diretórios
cp -rv "$HOME/.config/nvim" "$backup_dir/" 2>/dev/null || echo "⚠️ .config/nvim não encontrado"
cp -v "$HOME/.config/starship.toml" "$backup_dir/" 2>/dev/null || echo "⚠️ starship.toml não encontrado"

# Scripts pessoais (se quiser)
mkdir -p "$backup_dir/local-bin-backup"
find "$HOME/.local/bin" -type f -exec cp -v {} "$backup_dir/local-bin-backup/" \; 2>/dev/null || echo "⚠️ Nenhum script em ~/.local/bin"

echo "✅ Backup completo!"
