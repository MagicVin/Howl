#!/bin/bash
conf() {
  cpus="`lscpu | awk '/On-line/ {print $NF}'`"
  dev_regx="4907"
  irq_type="msi_irqs"
  log=sample.txt
}

get() {
  irq_info=(`ruby irq.rb -r $dev_regx -t $irq_type`)
  dev_list=${irq_info[0]/dev:/} 
  irq_list=${irq_info[1]/irq:/}
  echo ${irq_info[@]}
  echo "cpu: $cpus"
  ruby interrupts.rb -c $cpus -i "${irq_list[@]}" > $log
}

nodeput() {
  timest=(`awk '/2021-/ {print $2}' $log`)
  for i in `echo $irq_list | sed 's/,/ /g'` ;{
    nres=()
    ngaps=()
    nres=(`grep "^${i}:"  $log | awk '{print $(NF-1)}'`)
    ngaps=(`echo ${nres[@]} | sed 's/ /\n/g'| awk '{a[NR]=$NF; if (NR>1) print a[NR]-a[NR-1]}'`)
    echo "[$i]time - value    - gap"
    for ((i=0;i<${#nres[@]};i++)) ;{
      [ $i -eq 0 ] && echo "${timest[i]} - ${nres[i]} - 0"
      [ $i -gt 0 ] && echo "${timest[i]} - ${nres[i]} - ${ngaps[i-1]}"
    }
  }
}

allput() {
  timest=(`awk '/2021-/ {print $2}' $log`)
  res=(`awk '/sum/ {print $NF}' $log`)
  gaps=(`echo ${res[@]} | sed 's/ /\n/g'| awk '{a[NR]=$NF; if (NR>1) print a[NR]-a[NR-1]}'`)
  echo 
  echo "sum time - value     - gap"
  for ((i=0;i<${#res[@]};i++)) ;{
    [ $i -eq 0 ] && echo "${timest[i]} - ${res[i]} - 0"
    [ $i -gt 0 ] && echo "${timest[i]} - ${res[i]} - ${gaps[i-1]}"
  }
}

main() {
  conf
  get
  nodeput
  allput
}

main
