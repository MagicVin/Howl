#!/bin/bash

info() {
  cpus="`lscpu | awk '/On-line/ {print $NF}'`"
  #ip_list=(`ip addr | awk -F '/' '/192.168/ {gsub("inet ","");print $1}'`)
  local_ip_list=(
    192.168.0.11
    192.168.1.11
    192.168.2.11
    192.168.3.11
  )

  remote_ip_list=(
    192.168.0.10
    192.168.1.10
    192.168.2.10
    192.168.3.10
  )


  first_port=10010
  run_time=86400
  #run_time=180
  host_name=`cat /etc/hostname`
  #echo "cpus: $cpus"
  #echo "ip_list: ${ip_list[@]}"
}

iperf3_server_cmds() {
  #echo iperf3 server
  log=${log_dir}/server
  #pkill iperf3 
  count=0
  for i in ${local_ip_list[@]} ;{
    iperf_port=$((first_port+count))
    cmds="iperf3 -s -p $iperf_port"
    echo "cmds: $cmds" | tee ${log}_${count}.txt
    sleep 0.1
    #$cmds >> ${log}_${count}.txt &
    $cmds > /dev/null  &
    count=$((count+1))
  }
}

iperf3_client_cmds_single() {
  #echo iperf3 client
  log=${log_dir}/client
  #pkill iperf3
  for j in 0 1 ;{
    count=0
    for i in ${remote_ip_list[@]} ;{
      iperf_port=$((first_port+count))
      cmds="iperf3 -c $i -p $iperf_port -i 1 -t $run_time -P 4 -l 256 -u -b 300m"
      #cmds="iperf3 -c $i -p $iperf_port -i 1 -t $run_time -P 2 -l 256 -u -b 300m"
      echo "cmds: $cmds" | tee ${log}_${count}.txt
      sleep 0.1
      $cmds >> ${log}_${count}.txt &
      count=$((count+1))
    }
    sleep $((run_time+20))
  }
}

iperf3_client_cmds_mix() {
  log=${log_dir}/client
  declare A client_pids
  c=0
  for n in ${remote_ip_list[@]} ;{
    echo "`date +%m%d-%H%M%S` start iperf3 client" | tee ${log}_${c}.txt
    client_pids[c]="null"
    c=$((c+1))
  }

  while true
  do
    count=0
    for i in ${remote_ip_list[@]} ;{
      run_true=`ps aux | awk '/iperf/ && $2 == pid {print 0}' pid=${client_pids[count]}`
      if [ "$run_true" == "0" ]
      then
        count=$((count+1))
        continue
      else
        iperf_port=$((first_port+count))
        iperf_size=$((RANDOM%1245+256)) # 256 - 1500 KB
        iperf_time=$((RANDOM%201+100)) # 100 - 300 sec
        iperf_parallel=$((RANDOM%8+1)) # 1 - 8 parallel
        cmds="iperf3 -c $i -p $iperf_port -i 10 -t $iperf_time -P $iperf_parallel -l $iperf_size -u -b 300m"
        echo "`date +%m%d-%H%M%S` $cmds" >> ${log}_${count}.txt
        $cmds >> ${log}_${count}.txt &
        sleep 0.5
        client_pids[count]=$!
        count=$((count+1))
      fi
      run_true="1"
    }
    sleep 2
  
  done
}


fio_run() {
  pkill fio
  log=${log_dir}/${host_name}-fio.txt
  [ -f $fio_job ] && fio $fio_job > ${log} &
}

fio_mix() {
  log=${log_dir}/${host_name}-fio
  devs=(vdb vdc)
  for b in ${devs[@]} ;{
    echo "`date +%m%d-%H%M%S` start fio" | tee ${log}_${b}.txt
  }
  declare A fio_pids
  fio_pids=('null' 'null')
  while true 
  #for kk in 0
  do
    fcount=0
    for blk in ${devs[@]} ;{
      fio_true=`ps aux | awk '/fio/ && $2 == pid {print 0}' pid=${fio_pids[fcount]}`
      if [ "$fio_true" == "0" ]
      then
        fcount=$((fcount+1))
        continue
      else
        block_name="/dev/$blk"
        job_name="${blk}_test"
        fio_time=$((RANDOM%1201+600)) # 600 - 1800 sec
        #fio_time=300 # 600 - 1800 sec
        blk_size=$(((RANDOM%30+1)*512)) # 512B - 15KB
        mixread=$((RANDOM%31+70)) # 70% - 100%
        model=(
          fio
          -filename=$block_name
          -direct=1
          -iodepth=256
          -thread
          -rw=randrw
          -rwmixread=$mixread
          -ioengine=libaio
          -bs=$blk_size
          -size=512m
          -time_based
          -numjobs=2
          -runtime=$fio_time
          -name=$job_name
          -group_reporting
        )
        echo "`date +%m%d-%H%M%S` cmd: ${model[@]}" >> ${log}_${blk}.txt
        #${model[@]} >> /dev/null &
        ${model[@]} >> ${log}_${blk}.txt &
        sleep 0.5
        fio_pids[fcount]=$!
        fcount=$((fcount+1))
      fi
    }
    #echo "fio_pis: ${fio_pids[@]}"
    #ps aux | grep fio
    sleep 5
  done
}

iperf_wait() {
  sleep $run_time
  pkill iperf3
}

collect_data() {
  # 1. collect cpu/mem/disk
  log=${log_dir}/${host_name}
  pkill sar
  pkill iostat
  sar -r -u ALL -P ALL -n DEV -d -p 1 10 > ${log}-sar.txt &
  iostat -d -x -k 1 10 > ${log}-iostat.txt &
  # 2. get the irq
  #dev_regx="Eth.*Virtio"
  dev_regx="Virtio"
  irq_type="msi_irqs"
  echo "dev: ${dev_regx}" 
  echo "irq_type: $irq_type"
  irq_info=(`ruby /root/smartnic/irq.rb -r $dev_regx -t $irq_type`)
  dev_list=${irq_info[0]/dev:/} 
  irq_list=${irq_info[1]/irq:/}
  echo "dev_list: $dev_list, irq_list: $irq_list"
  ruby /root/smartnic/interrupts.rb -c $cpus -i "${irq_list[@]}" > ${log}-interrupts.txt
}

main() {
  info
  log_dir="/root/smartnic/logs"
  fio_job="/root/smartnic/read_40k.job"
  case $1 in
    server)
      iperf3_server_cmds
      run_time=$((run_time+10))
      #iperf_wait
    ;;
    client)
      #iperf3_client_cmds &
      #iperf_wait
      iperf3_client_cmds_mix &
    ;;
    fio)
      #fio_run
      fio_mix &
    ;;
    data)
      collect_data
    ;;
    *)
      echo "the option($1) is unsupported!"
    ;;
  esac
  
}

main $1
