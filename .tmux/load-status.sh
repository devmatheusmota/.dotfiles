#!/usr/bin/env bash

# Espera até que cpu_percentage e ram_percentage tenham algum valor
wait_for_tmux_vars() {
	for i in {1..20}; do
		cpu=$(tmux show -gqv "@catppuccin_status_cpu")
		ram=$(tmux show -gqv "@catppuccin_status_ram")
		if [[ -n "$cpu" && -n "$ram" ]]; then
			return 0
		fi
		sleep 0.2
	done
	return 1
}

# Roda o bloco de status depois dos valores estarem prontos
if wait_for_tmux_vars; then
	tmux source-file ~/.tmux.conf
	tmux refresh-client -S
fi
