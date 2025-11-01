#!/bin/bash

EWW_BIN=${EWW_BIN:-eww}
CFG="$HOME/.config/eww"
LOCK="$HOME/.cache/eww-calendar.lock"

# garante que o daemon tá rodando
if ! pgrep -x eww >/dev/null; then
  "$EWW_BIN" daemon --config "$CFG"
  sleep 0.3
fi

if [ ! -f "$LOCK" ]; then
  touch "$LOCK"
  "$EWW_BIN" --config "$CFG" open calendar
else
  "$EWW_BIN" --config "$CFG" close calendar
  rm -f "$LOCK"
fi

