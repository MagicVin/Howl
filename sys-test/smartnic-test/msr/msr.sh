#!/bin/bash
env_set() {
  work_dir="/root/msr-tools"
  wrmsr=$work_dir/wrmsr
  rdmsr=$work_dir/rdmsr
  msr_id="0x150"
}

msr_use() {
  h=$1 l=$2
  echo $wrmsr 0x150 0x8000001f00${h}000${l}8 -a
  $wrmsr 0x150 0x8000001f00${h}000${l}8 -a
  echo $rdmsr 0x150
  $rdmsr 0x150
  echo $wrmsr 0x150 0x8000001e00000000 -a
  $wrmsr 0x150 0x8000001e00000000 -a
  echo $rdmsr 0x150
  $rdmsr 0x150
  echo $wrmsr 0x150 0x8000001f00${h}000${l}9 -a
  $wrmsr 0x150 0x8000001f00${h}000${l}9 -a
  echo $rdmsr 0x150
  $rdmsr 0x150
  echo $wrmsr 0x150 0x8000011e00000000 -a
  $wrmsr 0x150 0x8000011e00000000 -a
  echo $rdmsr 0x150
  $rdmsr 0x150
  echo $wrmsr 0x150 0x8000001f00${h}000${l}A -a
  $wrmsr 0x150 0x8000001f00${h}000${l}A -a
  echo $rdmsr 0x150
  $rdmsr 0x150
  echo $wrmsr 0x150 0x8000021e00000000 -a
  $wrmsr 0x150 0x8000021e00000000 -a
  echo $rdmsr 0x150
  $rdmsr 0x150
  echo $wrmsr 0x150 0x8000001f00${h}000${l}B -a
  $wrmsr 0x150 0x8000001f00${h}000${l}B -a
  echo $rdmsr 0x150
  $rdmsr 0x150
  echo $wrmsr 0x150 0x8000031e00000000 -a
  $wrmsr 0x150 0x8000031e00000000 -a
  echo $rdmsr 0x150
  $rdmsr 0x150
  echo $wrmsr 0x150 0x8000001f00${h}000${l}C -a
  $wrmsr 0x150 0x8000001f00${h}000${l}C -a
  echo $rdmsr 0x150
  $rdmsr 0x150
  echo $wrmsr 0x150 0x8000041e00000000 -a
  $wrmsr 0x150 0x8000041e00000000 -a
  echo $rdmsr 0x150
  $rdmsr 0x150
}


env_set
msr_use $1 $2
