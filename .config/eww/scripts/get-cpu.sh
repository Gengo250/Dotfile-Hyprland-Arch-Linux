#!/bin/bash
LC_ALL=C top -bn1 | awk '/Cpu\(s\):/ {printf "%.0f\n", 100 - $8}'

