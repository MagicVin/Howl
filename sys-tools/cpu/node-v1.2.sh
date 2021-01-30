#!/bin/bash
# xinx.e.zhang@intel.com
# Jan 30, 2021
# v1.2

cpu_info() {
  node_num="`lscpu | awk '/NUMA/ {if (NF == 3 ) {print $NF}}'`"
  socket_num="`lscpu | awk '/Socket/ {print $NF}'`"
  core_num="`lscpu | awk '/Core/ {print $NF}'`"
  hpthread="`lscpu | awk '/Thread/ {print $NF}'`"
  node_cpu=(`lscpu | awk '/node.+ CPU/ {print $2,$NF}'`)
}

fakecpu_info() {
  file="c3.txt"
  node_num="`cat $file | awk '/NUMA/ {if (NF == 3 ) {print $NF}}'`"
  socket_num="`cat $file | awk '/Socket/ {print $NF}'`"
  core_num="`cat $file | awk '/Core/ {print $NF}'`"
  hpthread="`cat $file | awk '/Thread/ {print $NF}'`"
  node_cpu=(`cat $file | awk '/node.+ CPU/ {print $2,$NF}'`)
}

node_info() {
  node=""
  cpu=""
  for ((i=0;i<${#node_cpu[@]};i++)) ;{
    score=$((i%2))
    [ $score -eq 0 ] && node+="${node_cpu[i]} " || cpu+="${node_cpu[i]} "
  }
  node=(`echo $node`)
  cpu=(`echo $cpu`)
}

info() {
  cpu_info
  #fakecpu_info
  node_info
  cpu_snc=$((node_num/socket_num)) # 1: SNC disable , !1 : SNC enable
  core_perskt=$((core_num*hpthread))
  [[ $cpu_snc -eq 1 ]] && node_core=$core_perskt 
  [[ $cpu_snc -ne 1 ]] && node_core=$((core_perskt/cpu_snc))
  
}

put() {
  echo "node_num: $node_num"
  echo "socket_num: $socket_num"
  echo "core_num: $core_num"
  echo "hpthread: $hpthread"
  echo "node_cpu: ${node_cpu[@]}"
  echo "node: ${node[@]}"
  echo "cpu: ${cpu[@]}"
  echo "snc: ${cpu_snc} (1: SNC disable , !1 : SNC enable)"
  echo "core_pernode: $node_core"

}

parse() {
  range=${@//,/ }
  range=${range//-/..}
  list=""
  for p in $range ;{
    [[ $p =~ '..' ]] && list+="`eval echo {$p}` " || list+="$p "
  }
  list=(`echo $list`)
}

comp() {
  
  node_group=$((${#node[@]}/$socket_num))
  comp_count=0
  err_tag=""
  for ((i=0;i<socket_num;i++)) ;{
    node_idx=$((i*node_group))
    node_err=0
    cpu_str=""
    for ((j=0;j<$node_group;j++)) ;{
      idx=$((node_idx+j))
      cpu_list+="${cpu[idx]} "
      parse ${cpu[idx]}
      cpu_str+="${node[idx]} ${cpu[idx]}/${#list[@]} "
      [ ${#list[@]} -ne $node_core ] && node_err=$((node_err+1))
    }
    output="skt: $i; $cpu_str -- "
    if [ $node_err -ne 0 ]
    then
      output+="unbalanced!"
      output="$output"
      comp_count=$((comp_count+1))
    else
      output+="balanced!" 
      output="$output"
    fi
    echo "$output"
  }
  pass_cpu=0
  if [ $comp_count -eq 0 ]
  then
    echo "CPU PASS: ${socket_num}"
  else
    pass_cpu=$((socket_num-comp_count))
    if [ $pass_cpu -ne 0 ]
    then
      echo "CPU PASS: ${pass_cpu}"
      echo "CPU FAIL: ${comp_count}"
    else
      echo "CPU FAIL: ${comp_count}"
    fi

  fi

}

main() {
  info
  #put
  comp

}

main
