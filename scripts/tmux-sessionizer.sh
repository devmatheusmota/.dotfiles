#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
	selected=$1
else
	selected=$((echo "home"; find ~/projetos/emr ~/projetos/pessoal -mindepth 1 -maxdepth 1 -type d) | fzf)
fi

if [[ -z $selected ]]; then
	exit 0
fi

if [[ $selected == "home" ]]; then
	selected=~
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# ✅ Se tmux não está rodando, inicia uma sessão dummy pra acionar o continuum
dummy_created=false
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
	tmux new-session -d -s dummy-initializer
	dummy_created=true
fi

# ✅ Aguarda a restauração terminar
if pgrep -f resurrect >/dev/null; then
	echo "Aguardando restauração do tmux..."
	while tmux list-sessions 2>&1 | grep -q "(dead)"; do
		sleep 0.1
	done
fi

# ✅ Apaga a dummy se tiver sido criada
if $dummy_created && tmux has-session -t dummy-initializer 2>/dev/null; then
	tmux kill-session -t dummy-initializer
fi

# ✅ Cria a sessão se não existir
if ! tmux has-session -t=$selected_name 2>/dev/null; then
	tmux new-session -ds $selected_name -c $selected
fi

# ✅ Faz attach/switch normalmente
if [[ -z $TMUX ]]; then
	tmux attach -t $selected_name
else
	tmux switch-client -t $selected_name
fi
