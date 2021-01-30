#!/bin/bash
game_pid=$1

conf=`cat /proc/sys/kernel/kptr_restrict`
[ $conf -ne 0 ] && echo 0 > /proc/sys/kernel/kptr_restrict
echo "perf system"
perf sched record -F 99 -a -g -- sleep 1
perf sched timehist -s | tee sys-perf.txt
perf sched latency -s runtime | tee -a sys-perf.txt
perf sched record -F 99 -p $game_pid -g -- sleep 1
perf sched timehist -s | tee game-perf.txt
perf sched latency -s runtime | tee -a game-perf.txt

