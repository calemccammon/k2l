#!/bin/bash
# usage: scale.sh N... : generates (once) and compiles N-file synthetic projects (gen.py), prints wall seconds
B=$(cd "$(dirname "$0")" && pwd)
K2L=${K2L:-$B/../compiler/build/install/k2l/bin/k2l}
for n in "$@"; do
  [ -d "$B/p$n" ] || python3 "$B/gen.py" "$B/p$n" "$n"
  cd "$B/p$n"
  s=$(date +%s.%N)
  "$K2L" >/dev/null 2>"$B/p$n.err"
  rc=$?
  e=$(date +%s.%N)
  echo "n=$n rc=$rc $(echo "$e - $s" | bc)s"
done
