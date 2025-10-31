#!/bin/bash

# lê brilho atual (0-100) com brightnessctl
BRI=$(brightnessctl -m | awk -F, '{gsub(/[%]/,"",$4); print $4}')

# manda pro eww
eww update current-brightness="$BRI"
eww update brightness=true

# fecha depois de 2s
(sleep 4 && eww update brightness=false) &
