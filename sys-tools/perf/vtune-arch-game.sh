#!/bin/bash

source /opt/intel/vtune_profiler_2020/sep_vars.sh
echo "collect game data .."
vtune -collect uarch-exploration -target-pid $(pidof com.tencent.tmgp.sgame)
