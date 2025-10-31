#!/bin/bash

mem_total=$(grep -i MemTotal /proc/meminfo | awk '{print $2}')
mem_avail=$(grep -i MemAvailable /proc/meminfo | awk '{print $2}')

if [ -z "$mem_total" ] || [ -z "$mem_avail" ]; then
  echo 0
  exit 0
fi

mem_used=$((mem_total - mem_avail))
pct=$((mem_used * 100 / mem_total))

echo "$pct"

