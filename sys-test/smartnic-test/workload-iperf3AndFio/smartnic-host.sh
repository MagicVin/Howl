#!/bin/bash

conf() {
  #1. set tcp port for performing vm's commands
  vm_port=(30000 30001)
  vm_logs="/root/smartnic/logs"
  host_logs="/root/smartnic/logs"
  #server_port=(30000 30002 30004 30006)
  #client_port=(30001 30003 30005 30007)
  server_port=(30000)
  client_port=(30001)
  vm_cpu="0-51,104-155"
  #vm_cpu="22-23,126-127,24-25,128-129"
  #vm_cpu="2-25,106-129"
  run_time=30
}


run() {
  pkill sar
  pkill iostat
  pkill ruby
  #2. start fio
  for i in ${server_port[@]} ${client_port[@]} ;{
    echo ssh root@localhost -p $i '/root/smartnic/smartnic-vm.sh fio'
    ssh root@localhost -p $i '/root/smartnic/smartnic-vm.sh fio' &
  }

  sleep 1

  #3. start iperf server
  for server in ${server_port[@]} ;{
    echo ssh root@localhost -p $server '/root/smartnic/smartnic-vm.sh server'
    ssh root@localhost -p $server '/root/smartnic/smartnic-vm.sh server' &
  }

  sleep 1

  #4. start iperf client
  for client in ${client_port[@]} ;{
    echo ssh root@localhost -p $client '/root/smartnic/smartnic-vm.sh client'
    ssh root@localhost -p $client '/root/smartnic/smartnic-vm.sh client' &
  }
}

collect() {
  #5. collect host data
  ./interrupts.rb -c $vm_cpu -i PIN,PIW > ${host_logs}/host-interrupts.txt &
  sar -r -u ALL -P ALL -n DEV -d -p 1 10 > ${host_logs}/host-sar.txt &
  iostat -d -x -k 1 10 > ${host_logs}/host-iostat.txt &
  
  #6. collect vm data
  for i in ${server_port[@]} ${client_port[@]} ;{
    echo "ssh root@localhost -p $i '/root/smartnic/smartnic-vm.sh data'"
    ssh root@localhost -p $i '/root/smartnic/smartnic-vm.sh data' &
  }
}

output() {
  # output the interrupts data

  # gather the interrupts
  echo "host interrupts statistic"
  awk 'NR == 2 {print } /sum/ {print}' ${host_logs}/host-interrupts.txt

  echo "vm server statistic"
  for oi in ${server_port[@]} ;{
    server=$oi
    echo ssh root@localhost -p $server "awk 'NR == 2 {print } /sum/ {print}' ${vm_logs}/*interrupts.txt"
    ssh root@localhost -p $server "awk 'NR == 2 {print } /sum/ {print}' ${vm_logs}/*interrupts.txt"
    scp -P $server root@localhost:${vm_logs}/*interrupts.txt ${host_logs}
  }

  echo "vm client statistic"
  for oi in ${client_port[@]} ;{
    client=$oi
    echo ssh root@localhost -p $client "awk 'NR == 2 {print } /sum/ {print}' ${vm_logs}/*interrupts.txt"
    ssh root@localhost -p $client "awk 'NR == 2 {print } /sum/ {print}' ${vm_logs}/*interrupts.txt"
    scp -P $client root@localhost:${vm_logs}/*interrupts.txt ${host_logs}
  }

  # gather the disk/network/mem
  echo "host sar statistic"
  awk '/Average/' ${host_logs}/host-sar.txt

  echo "vm server sar statistic"
  for oi in ${server_port[@]} ;{
    server=$oi
    echo ssh root@localhost -p $server "awk '/Average/' ${vm_logs}/*sar.txt"
    ssh root@localhost -p $server "awk '/Average/' ${vm_logs}/*sar.txt"
    scp -P $server root@localhost:${vm_logs}/*sar.txt ${host_logs}
  }

  echo "vm client sar statistic"
  for oi in ${client_port[@]} ;{
    client=$oi
    echo ssh root@localhost -p $client "awk '/Average/' ${vm_logs}/*sar.txt"
    ssh root@localhost -p $client "awk '/Average/' ${vm_logs}/*sar.txt"
    scp -P $client root@localhost:${vm_logs}/*sar.txt ${host_logs}
  }

  echo "transfer log"
  for oi in ${server_port[@]} ${client_port[@]} ;{
    echo "scp -P $oi root@localhost:${vm_logs}/*iostat.txt ${host_logs}/"
    scp -P $oi root@localhost:${vm_logs}/*iostat.txt ${host_logs}/
    scp -P $oi root@localhost:${vm_logs}/*fio.txt ${host_logs}/${oi}-fio.txt
    scp -P $oi root@localhost:${vm_logs}/*fio_vdb.txt ${host_logs}/${oi}-fio_vdb.txt
    scp -P $oi root@localhost:${vm_logs}/*fio_vdc.txt ${host_logs}/${oi}-fio_vdc.txt
    scp -P $oi root@localhost:/root/smartnic/interrupts.rb ${host_logs}/${oi}-interrupts.rb
    scp -P $oi root@localhost:/root/smartnic/irq.rb ${host_logs}/${oi}-irq.rb
    scp -P $oi root@localhost:/root/smartnic/smartnic-vm.sh ${host_logs}/${oi}-smartnic-vm.sh
  }

}

main() {
  conf
  #run
  #sleep 10
  collect
  sleep 30
  output | tee ${host_logs}/data.txt
}

main 
