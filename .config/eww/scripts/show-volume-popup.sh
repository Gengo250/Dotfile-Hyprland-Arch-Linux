#!/bin/bash

# pega o sink padrão
SINK=$(pactl get-default-sink)

# lê o volume atual (pega o primeiro % que aparecer)
VOL=$(pactl get-sink-volume "$SINK" | awk -F'/' 'NR==1 {gsub(/[% ]/,"",$2); print $2}')

# atualiza o eww com o valor AGORA
eww update current-volume="$VOL"
eww update volume=true

# fecha depois de 2s
(sleep 4 && eww update volume=false) &

