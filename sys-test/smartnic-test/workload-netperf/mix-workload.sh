#!/bin/bash
# xinx.e.zhang@intel.com
# v1.0
# Mar 3, 2021

opts() {
  while [ $# -gt 0 ]
  do
    case $1 in
    -d)
      devs=$2
      shift
      shift
    ;;
    -q)
      queues=$2
      shift
      shift
    ;;
    -t)
      cs=$2 #client or server
      shift
      shift
    ;;
    -s)
      sec=$2
      shift
      shift
    ;;
    *)
      shift
      shift
    ;;
    esac
  done
}

pre_env() {
  opts $@
  [[ $sec ]] && runtime=$sec || runtime=240000
  port=12600
  size=1
  log="./client_log"
  
  #server ip
  ip_list=(
    192.168.0.11
    192.168.1.11
    192.168.2.11
    192.168.3.11
  )
}

out_env() {
  echo "devs: $devs, queues: $queues, cs: $cs, sec: $runtime"
}

client_cmds() {
  t=1
  mkdir -p $log
  rm $log/* -rf 
  cd $log

  for ((i=0;i<devs;i++)) ;{
    for ((j=0;j<queues;j++)) ;{
      echo "netperf -H ${ip_list[i]} -t UDP_STREAM -l $runtime -p $port -T ${t},${t} -- -m $size > $port.txt &" | tee -a client_cmds.sh
      netperf -H ${ip_list[i]} -t UDP_STREAM -l $runtime -p $port -T ${t},${t} -- -m $size > $port.txt &
      let t++
      let port++
    }
  }
}

server_cmds() {
  [ -e server.sh ] && rm server.sh -rf 
  for ((i=0;i<devs;i++)) ;{
    for ((j=0;j<queues;j++)) ;{
      echo "netserver -p $port" | tee -a server.sh
      netserver -p $port
      let port++
    }
  }
}

main() {
  pre_env $@
  out_env
  case $cs in
    client)
      [ $devs -ge 1 ] && [[ $queues -ge 1 ]] && client_cmds
    ;;
    server)
      [ $devs -ge 1 ] && [[ $queues -ge 1 ]] && server_cmds
    ;;
    *)
      echo "unsupported option: $cs"
      echo "start server"
      echo $0 -d 1 -q 1 -t server
      echo
      echo "start client"
      echo $0 -d 1 -q 1 -t client -s 300
    ;;
  esac
}

main $@
