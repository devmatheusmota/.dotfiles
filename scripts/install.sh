#!/usr/bin/env bash

set -e
set -u

echo "🔧 Instalando pacotes básicos..."

# Só instala se não tiver
command -v git >/dev/null 2>&1 || sudo apt install -y git
command -v zsh >/dev/null 2>&1 || sudo apt install -y zsh
command -v tmux >/dev/null 2>&1 || sudo apt install -y tmux
command -v nvim >/dev/null 2>&1 || sudo apt install -y neovim
command -v curl >/dev/null 2>&1 || sudo apt install -y curl
command -v build-essential >/dev/null 2>&1 || sudo apt install -y build-essential
command -v fzf >/dev/null 2>&1 || sudo apt install -y fzf

echo "🔗 Criando symlinks..."

DOTFILES_DIR="$HOME/.dotfiles"

# Arquivos soltos na home
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
ln -sf "$DOTFILES_DIR/.tmux" "$HOME/.tmux"
ln -sf "$DOTFILES_DIR/.tmux-cht-command" "$HOME/.tmux-cht-command"
ln -sf "$DOTFILES_DIR/.tmux-cht-languages" "$HOME/.tmux-cht-languages"


echo "🚀 Instalando Starship prompt..."

if ! command -v starship >/dev/null 2>&1; then
	curl -sS https://starship.rs/install.sh | sh -s -- -y
else
	echo "✅ Starship já instalado"
fi

# Garante que o eval tá no .zshrc
if ! grep -q 'starship init zsh' "$HOME/.zshrc"; then
	echo 'eval "$(starship init zsh)"' >>"$HOME/.zshrc"
	echo "✅ Adicionado eval ao .zshrc"
else
	echo "ℹ️  Starship já está configurado no .zshrc"
fi


# Neovim
echo "🧠 Criando symlink do diretório Neovim inteiro..."

# Remove se já existir como pasta normal (mas faz backup primeiro se quiser)
if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
	mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%s)"
	echo "📦 Backup da antiga config do Neovim criado!"
fi

ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Scripts (se existirem e forem executáveis)
if [ -d "$DOTFILES_DIR/scripts" ]; then
	mkdir -p "$HOME/.local/bin"
	find "$DOTFILES_DIR/scripts" -type f -executable -exec ln -sf {} "$HOME/.local/bin/" \;
fi

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	echo "💻 Instalando oh-my-zsh..."
	cp -r "$DOTFILES_DIR/.oh-my-zsh" "$HOME/.oh-my-zsh"
fi

# Nerd Fonts
echo "🔤 Verificando instalação das Nerd Fonts..."

# Verifica se uma das fontes já está instalada
if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
	echo "🔤 Instalando Nerd Fonts..."

	NERD_FONT_TMP="$HOME/.cache/nerd-fonts"

	# Clona só se ainda não tiver
	if [ ! -d "$NERD_FONT_TMP" ]; then
		git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git "$NERD_FONT_TMP"
	fi

	# Instala as fontes desejadas
	"$NERD_FONT_TMP/install.sh" JetBrainsMono FiraCode Hack

	# Limpa o cache depois da instalação
	rm -rf "$NERD_FONT_TMP"
	echo "🧹 Repositório temporário das Nerd Fonts removido."
	echo "✅ Fontes Nerd instaladas!"
else
	echo "✅ Nerd Fonts já instaladas. Pulando..."
fi

# Trocar shell padrão pra Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
	echo "🌀 Trocando shell padrão para zsh..."
	chsh -s "$(which zsh)"
fi

echo "✅ Ambiente configurado com sucesso!"

### ─────────────────────────────────────────────────────────────
### 🐳 Instalação do Docker
### ─────────────────────────────────────────────────────────────

if ! command -v docker >/dev/null 2>&1; then
	echo "🐳 Instalando Docker..."

	sudo apt-get update
	sudo apt-get install -y \
		ca-certificates \
		gnupg \
		lsb-release

	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	sudo usermod -aG docker "$USER"
	echo "✅ Docker instalado com sucesso! Reinicie a sessão para usar sem sudo."
else
	echo "🐳 Docker já está instalado"
fi

### ─────────────────────────────────────────────────────────────
### 🔁 Instalação do Node via nvm
### ─────────────────────────────────────────────────────────────

if ! command -v node >/dev/null 2>&1; then
	echo "🟢 Instalando Node.js via NVM..."

	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

	# Carrega o nvm na sessão atual
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

	# Instala a versão LTS do Node
	nvm install --lts
	nvm use --lts
	nvm alias default lts/*

	echo "✅ Node.js instalado via NVM"
else
	echo "🟢 Node já está instalado"
fi
