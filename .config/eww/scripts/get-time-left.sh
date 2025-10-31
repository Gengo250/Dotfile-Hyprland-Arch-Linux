#!/bin/bash

# pega o primeiro device de bateria que o upower conhecer
DEV=$(upower -e | grep -E 'BAT|battery' | head -n1)

# se não tiver bateria (desktop/VM)
if [ -z "$DEV" ]; then
  echo "—"
  exit 0
fi

INFO=$(upower -i "$DEV")

STATE=$(echo "$INFO" | awk -F: '/state:/ {gsub(/^[ \t]+/, "", $2); print $2}')
TIME_EMPTY=$(echo "$INFO" | awk -F: '/time to empty:/ {gsub(/^[ \t]+/, "", $2); print $2}')
TIME_FULL=$(echo "$INFO" | awk -F: '/time to full:/  {gsub(/^[ \t]+/, "", $2); print $2}')

# escolhe qual tempo usar
if [ "$STATE" = "discharging" ] && [ -n "$TIME_EMPTY" ]; then
  RAW_TIME="$TIME_EMPTY"
elif [ -n "$TIME_FULL" ]; then
  RAW_TIME="$TIME_FULL"
else
  echo "—"
  exit 0
fi

# RAW_TIME vem tipo: "2.3 hours" ou "2,3 horas" ou "45.0 minutes"
NUM=$(echo "$RAW_TIME" | awk '{print $1}' | tr ',' '.')
UNIT=$(echo "$RAW_TIME" | awk '{print $2}')

# função pra arredondar fração -> minutos
to_minutes() {
  frac="$1"
  if [ -z "$frac" ]; then
    echo 0
  else
    # precisa ter bc instalado
    echo "0.$frac*60" | bc -l | awk '{printf "%d\n", $1 + 0.5}'
  fi
}

H=0
M=0

case "$UNIT" in
  hour|hours|hora|horas)
    H=$(echo "$NUM" | cut -d. -f1)
    FRAC=$(echo "$NUM" | cut -s -d. -f2)
    M=$(to_minutes "$FRAC")
    ;;
  minute|minutes|minuto|minutos)
    M=$(printf "%.0f" "$NUM")
    ;;
  *)
    # se vier um formato inesperado, mostra cru mesmo
    echo "$RAW_TIME"
    exit 0
    ;;
esac

# normaliza se der 60 min+
if [ "$M" -ge 60 ]; then
  H=$((H + M/60))
  M=$((M % 60))
fi

# saída final
if [ "$M" -eq 0 ]; then
  echo "${H}h"
else
  echo "${H}h ${M}min"
fi

