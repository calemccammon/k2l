#!/bin/bash
# times the hand-written Lua versions in runtime/*.lua
B=$(cd "$(dirname "$0")" && pwd)
for f in nbody trees hashmap; do
  line="hand $f:"
  for r in lua5.4 luajit; do
    s=$(date +%s.%N); $r "$B/runtime/$f.lua" >/dev/null; e=$(date +%s.%N)
    line="$line $r=$(printf '%.2f' "$(echo "$e - $s" | bc)")s"
  done
  echo "$line"
done
