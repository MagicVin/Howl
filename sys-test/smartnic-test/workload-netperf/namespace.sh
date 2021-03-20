#!/bin/bash
# xinx.e.zhang@intel.com
# v1.0
# Mar 18, 2021

conf() {
  echo "clean all of the namespaces"
  ip -all netns delete
  sleep 1
  echo "add namespaces"
  for i in {0..3} ;{
    ip netns add ns$i
  }
  echo "check the new created namespaces"
  ip netns list
  echo "assign the interface to the namespace"
  ip link set eth0 netns ns0
  ip link set eth1 netns ns1
  ip link set eth2 netns ns2
  ip link set eth3 netns ns3
  sleep 1
  echo "assign the ip address to the interface"
  ip netns exec ns0 ifconfig eth0 1.3.8.128
  ip netns exec ns1 ifconfig eth1 1.3.8.127
  ip netns exec ns2 ifconfig eth2 1.3.8.126
  ip netns exec ns3 ifconfig eth3 1.3.8.125
  sleep 1
  echo "check the subnet ips"
  for i in {0..3} ;{
    ip netns exec ns$i ifconfig | grep 1.3.8 | sed 's/^\ *//g'
  }
}

server() {
  echo "starting server ..."
  ip netns exec ns1 netserver -p 12600
  ip netns exec ns1 netserver -p 12601
  ip netns exec ns1 netserver -p 12602
  ip netns exec ns1 netserver -p 12603
  ip netns exec ns0 netserver -p 12604
  ip netns exec ns0 netserver -p 12605
  ip netns exec ns0 netserver -p 12606
  ip netns exec ns0 netserver -p 12607
  ip netns exec ns3 netserver -p 12608
  ip netns exec ns3 netserver -p 12609
  ip netns exec ns3 netserver -p 12610
  ip netns exec ns3 netserver -p 12611
  ip netns exec ns2 netserver -p 12612
  ip netns exec ns2 netserver -p 12613
  ip netns exec ns2 netserver -p 12614
  ip netns exec ns2 netserver -p 12615
  sleep 1
}

client() {
  # ns0(1.3.8.128) - ns1(1.3.8.127)
  # ns2(1.3.8.126) - ns3(1.3.8.125)

  echo "starting client ..."
  ip netns exec ns0 netperf -H 1.3.8.127 -t UDP_STREAM -l 240000 -p 12600 -T 0,0 -- -m 1 &
  ip netns exec ns0 netperf -H 1.3.8.127 -t UDP_STREAM -l 240000 -p 12601 -T 1,1 -- -m 1 &
  ip netns exec ns0 netperf -H 1.3.8.127 -t UDP_STREAM -l 240000 -p 12602 -T 2,2 -- -m 1 &
  ip netns exec ns0 netperf -H 1.3.8.127 -t UDP_STREAM -l 240000 -p 12603 -T 3,3 -- -m 1 &
  #sleep 1
  ip netns exec ns1 netperf -H 1.3.8.128 -t UDP_STREAM -l 240000 -p 12604 -T 4,4 -- -m 1 &
  ip netns exec ns1 netperf -H 1.3.8.128 -t UDP_STREAM -l 240000 -p 12605 -T 5,5 -- -m 1 &
  ip netns exec ns1 netperf -H 1.3.8.128 -t UDP_STREAM -l 240000 -p 12606 -T 6,6 -- -m 1 &
  ip netns exec ns1 netperf -H 1.3.8.128 -t UDP_STREAM -l 240000 -p 12607 -T 7,7 -- -m 1 &
  #sleep 1
  ip netns exec ns2 netperf -H 1.3.8.125 -t UDP_STREAM -l 240000 -p 12608 -T 8,8 -- -m 1 &
  ip netns exec ns2 netperf -H 1.3.8.125 -t UDP_STREAM -l 240000 -p 12609 -T 9,9 -- -m 1 &
  ip netns exec ns2 netperf -H 1.3.8.125 -t UDP_STREAM -l 240000 -p 12610 -T 10,10 -- -m 1 &
  ip netns exec ns2 netperf -H 1.3.8.125 -t UDP_STREAM -l 240000 -p 12611 -T 11,11 -- -m 1 &
  #sleep 1
  ip netns exec ns3 netperf -H 1.3.8.126 -t UDP_STREAM -l 240000 -p 12612 -T 12,12 -- -m 1 &
  ip netns exec ns3 netperf -H 1.3.8.126 -t UDP_STREAM -l 240000 -p 12613 -T 13,13 -- -m 1 &
  ip netns exec ns3 netperf -H 1.3.8.126 -t UDP_STREAM -l 240000 -p 12614 -T 14,14 -- -m 1 &
  ip netns exec ns3 netperf -H 1.3.8.126 -t UDP_STREAM -l 240000 -p 12615 -T 15,15 -- -m 1 &
  sleep 1
}

time_start() {
  echo "netperf start" | tee time.txt
  while true
  do
    date | tee -a time.txt
    sleep 10
  done
}

monitor() {
  ip netns exec ns0 sar -n DEV 1 10 > ns0.txt &
  ip netns exec ns1 sar -n DEV 1 10 > ns1.txt &
  ip netns exec ns2 sar -n DEV 1 10 > ns2.txt &
  ip netns exec ns3 sar -n DEV 1 10 > ns3.txt &
  sleep 12
  awk '/Average.*IFACE/' ns0.txt
  awk '/Average.*eth/' ns*txt
}

main() {
  case $1 in
    server)
      #conf
      server
    ;;
    client)
      client
      time_start
    ;;
    conf)
      conf
    ;;
    monitor)
      monitor
    ;;
    stop)
      pkill netperf
      pkill netserver
      sleep 1
      ps aux | grep 'netperf\|netserver'
    ;;
    *)
      echo "unsupported option: $1"
      echo "  supported options: server|client|confi|monitor|stop"
    ;;
  esac
}

main $@
