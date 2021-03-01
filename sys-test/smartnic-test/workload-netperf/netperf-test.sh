#!/bin/bash

server() {
  netserver -p 12600
  netserver -p 12601
  netserver -p 12602
  netserver -p 12603
  netserver -p 12604
  netserver -p 12605
  netserver -p 12606
  netserver -p 12607
  netserver -p 12608
  netserver -p 12609
  netserver -p 12610
  netserver -p 12611
  netserver -p 12612
  netserver -p 12613
  netserver -p 12614
  netserver -p 12615
  netserver -p 12616
  netserver -p 12617
  netserver -p 12618
  netserver -p 12619
  netserver -p 12620
  netserver -p 12621
  netserver -p 12622
  netserver -p 12623
  #netserver -p 12624
  #netserver -p 12625
}

client() {
  netperf -H 192.168.0.10 -t UDP_STREAM -l 240000 -p 12600 -T 0,0 -- -m 1 > 12600.txt &
  netperf -H 192.168.0.10 -t UDP_STREAM -l 240000 -p 12601 -T 1,1 -- -m 1 > 12601.txt &
  netperf -H 192.168.0.10 -t UDP_STREAM -l 240000 -p 12602 -T 2,2 -- -m 1 > 12602.txt &
  netperf -H 192.168.0.10 -t UDP_STREAM -l 240000 -p 12603 -T 3,3 -- -m 1 > 12603.txt &
  netperf -H 192.168.0.10 -t UDP_STREAM -l 240000 -p 12604 -T 4,4 -- -m 1 > 12604.txt &
  netperf -H 192.168.0.10 -t UDP_STREAM -l 240000 -p 12605 -T 5,5 -- -m 1 > 12605.txt &
  netperf -H 192.168.0.10 -t UDP_STREAM -l 240000 -p 12606 -T 6,6 -- -m 1 > 12606.txt &
  netperf -H 192.168.0.10 -t UDP_STREAM -l 240000 -p 12607 -T 7,7 -- -m 1 > 12607.txt &
  netperf -H 192.168.1.10 -t UDP_STREAM -l 240000 -p 12608 -T 8,8 -- -m 1 > 12608.txt &
  netperf -H 192.168.1.10 -t UDP_STREAM -l 240000 -p 12609 -T 9,9 -- -m 1 > 12609.txt &
  netperf -H 192.168.1.10 -t UDP_STREAM -l 240000 -p 12610 -T 10,10 -- -m 1 > 12610.txt &
  netperf -H 192.168.1.10 -t UDP_STREAM -l 240000 -p 12611 -T 11,11 -- -m 1 > 12611.txt &
  netperf -H 192.168.1.10 -t UDP_STREAM -l 240000 -p 12612 -T 12,12 -- -m 1 > 12612.txt &
  netperf -H 192.168.1.10 -t UDP_STREAM -l 240000 -p 12613 -T 13,13 -- -m 1 > 12613.txt &
  netperf -H 192.168.2.10 -t UDP_STREAM -l 240000 -p 12614 -T 14,14 -- -m 1 > 12614.txt &
  netperf -H 192.168.2.10 -t UDP_STREAM -l 240000 -p 12615 -T 15,15 -- -m 1 > 12615.txt &
  netperf -H 192.168.2.10 -t UDP_STREAM -l 240000 -p 12616 -T 16,16 -- -m 1 > 12616.txt &
  netperf -H 192.168.2.10 -t UDP_STREAM -l 240000 -p 12617 -T 17,17 -- -m 1 > 12617.txt &
  netperf -H 192.168.2.10 -t UDP_STREAM -l 240000 -p 12618 -T 18,18 -- -m 1 > 12618.txt &
  netperf -H 192.168.2.10 -t UDP_STREAM -l 240000 -p 12619 -T 19,19 -- -m 1 > 12619.txt &
  netperf -H 192.168.3.10 -t UDP_STREAM -l 240000 -p 12620 -T 20,20 -- -m 1 > 12620.txt &
  netperf -H 192.168.3.10 -t UDP_STREAM -l 240000 -p 12621 -T 21,21 -- -m 1 > 12621.txt &
  netperf -H 192.168.3.10 -t UDP_STREAM -l 240000 -p 12622 -T 22,22 -- -m 1 > 12622.txt &
  netperf -H 192.168.3.10 -t UDP_STREAM -l 240000 -p 12623 -T 23,23 -- -m 1 > 12623.txt &
  #netperf -H 192.168.3.10 -t UDP_STREAM -l 240000 -p 12624 -T 24,24 -- -m 1 > 12624.txt &
  #netperf -H 192.168.3.10 -t UDP_STREAM -l 240000 -p 12625 -T 25,25 -- -m 1 > 12625.txt &
}

time_start() {
  echo "netperf start" | tee time.txt
  while true
  do
    date | tee -a time.txt
    sleep 10
  done
}

main() {
  case $1 in
    client)
      client
      time_start
    ;;
    server)
      server
    ;;
    *)
      echo "  unsupported name: $1"
    ;;
  esac
}


main $1
