#!/bin/bash
# usage: rt.sh [-c] [names...] : (-c: recompile) run generated Lua of each runtime/<name> on lua5.4 and luajit; prints seconds
B=$(cd "$(dirname "$0")" && pwd)
K2L=${K2L:-$B/../compiler/build/install/k2l/bin/k2l}
compile=0
if [ "$1" = "-c" ]; then compile=1; shift; fi
names=("$@")
[ ${#names[@]} -eq 0 ] && names=(nbody trees strings pipeline hashmap classes delegates)
for n in "${names[@]}"; do
  d=$B/runtime/$n
  if [ $compile = 1 ]; then
    (cd "$d" && "$K2L" >/dev/null 2>"$d/compile.err" || cat "$d/compile.err")
    (cd "$d" && sed -i 's/"luaTarget":"[^"]*"/"luaTarget":"JIT"/' k2l.json && "$K2L" -o out-jit >/dev/null 2>&1; sed -i 's/"luaTarget":"[^"]*"/"luaTarget":"5.4"/' k2l.json)
  fi
  out=""
  for rt in "lua5.4:out" "luajit:out-jit"; do
    bin=${rt%%:*}; dir=${rt##*:}
    s=$(date +%s.%N)
    (cd "$d/$dir" && $bin main.lua >"$d/$dir.stdout" 2>"$d/$dir.stderr")
    rc=$?
    e=$(date +%s.%N)
    out="$out $bin=$(printf '%.2f' "$(echo "$e - $s" | bc)")s(rc$rc)"
  done
  echo "$n:$out"
done
