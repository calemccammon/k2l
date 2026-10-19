#!/bin/bash
# usage: flags.sh DIR RUNS VARIANTS_FILE : min/median/avg wall seconds of k2l in DIR for each JAVA_OPTS line of VARIANTS_FILE
B=$(cd "$(dirname "$0")" && pwd)
K2L=${K2L:-$B/../compiler/build/install/k2l/bin/k2l}
dir=$(realpath "$1"); runs=$2; vfile=$(realpath "$3")
cd "$dir"
while IFS= read -r v; do
  export JAVA_OPTS="${v//@B@/$B}"
  ts=()
  for i in $(seq 1 "$runs"); do
    s=$(date +%s.%N); "$K2L" >/dev/null 2>&1; e=$(date +%s.%N)
    ts+=("$(echo "$e - $s" | bc)")
  done
  printf '%s\n' "${ts[@]}" | sort -n | awk -v v="$v" '{a[NR]=$1; s+=$1} END{printf "min %.2f med %.2f avg %.2f  [%s]\n", a[1], a[int((NR+1)/2)], s/NR, v}'
done < "$vfile"
