#!/bin/bash
mkdir -p perf
sar -u ALL 1 20 > perf/sar.txt &
free -h > perf/mem.txt &
./cfps.rb > perf/fps.txt &
./cg-v1.9.sh col gpu > /dev/null 2>&1 &
sleep 35
echo 
grep 'CPU\|Aver' perf/sar.txt
echo 
cat perf/mem.txt
echo 
cat perf/fps.txt | grep 'bad\|good\|total'
echo 
awk '/Ren/ { for (i=1;i<=NF;i++) {name[i]=$i}}; /Total/ {for (i=1;i<=NF;i++) {avg[i]=$i}} END { for (i=1;i<=length(name);i++)          {printf ("%-25s %-25s\n","  "name[i], avg[i])}}' /root/work/i915_usage/sum.txt
