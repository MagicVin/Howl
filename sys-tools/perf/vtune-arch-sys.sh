#!/bin/bash

source /opt/intel/vtune_profiler_2020/sep_vars.sh
echo "collect system data .."
vtune -collect uarch-exploration -analyze-system -- /usr/bin/sleep 60
