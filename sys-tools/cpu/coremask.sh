#!/bin/bash
# core id: 0    1    2    3
#   place: 0001 0010 0100 1000
#    mask: 0001 0002 0004 0008
# core id: 4    5    6    7
#   place: 0001 0010 0100 1000
#    mask: 0010 0020 0040 0080
# core id: 8    9    10    11
#   place: 0001 0010 0100 1000
#    mask: 0100 0200 0400 0800
# core id: 12   13    14    15
#   place: 0001 0010 0100 1000
#    mask: 1000 2000 4000 8000
# core id: 16     17     18     19
#   place: 0001   0010   0100   1000
#    mask: 10000  20000  40000  80000
# core id: 20     21     22     23
#   place: 0001   0010   0100   1000
#    mask: 100000 200000 400000 800000

convDeci_bin() {
  BITMASK=0
  BITMASK=`ruby -e "puts (2**(ARGV[0].to_i)).to_s(16)" $1`
}

convDeci() {
  DECIMAL=0
  DECIMAL=`ruby -e "puts (2**(ARGV[0].to_i))" $1`
}

pinthread_core() {
  PINCORE_USAGE=$(cat <<- EOF
  usage:
    -p [pid] -l [list]

    -p xxxx -l 0-7
EOF
)
  [ $# -eq 4 ] && {
    while [ $# -gt 0 ]
    do
      case $1 in
        -p)
          QEMU_PID=$2
          let PIN_OPTION+=0
          shift
          shift
        ;;
        -l)
          CORE_LIST=$2
          let PIN_OPTION+=0
          shift
          shift
        ;;
        *)
          echo "  unsupported app options: $@"
          let PIN_OPTION+=1
          echo "$PINCORE_USAGE"
          break
        ;;
      esac
    done
    
    [ $PIN_OPTION -eq 0 ] && {
      QEMU_PID_ARR=(`ps -eLo ruser,pid,ppid,lwp,psr,args | awk -v PID=$QEMU_PID '$2 == PID && $6 == "qemu-system-x86_64" {print $4}'`)
      syslib_list $CORE_LIST
      [ $LIST_ACTION -eq 0 ] && CORE_ARR=(${UNQ_ARR[@]})
      echo "  core list: ${CORE_ARR[@]}"
      [ $((${#QEMU_PID_ARR[@]}-3)) -eq ${#CORE_ARR[@]} ] && {
      local coresum
      for i in ${CORE_ARR[@]} ;{
        convDeci $i
        #echo "  $i: $DECIMAL"
        #let coresum+=DECIMAL
        coresum=`ruby -e "puts (ARGV[0].to_i)+(ARGV[1].to_i)" $coresum $DECIMAL`
        #echo "  sum: $coresum"
      }
      sum_mask=`ruby -e "puts (ARGV[0].to_i).to_s(16)" $coresum`
      echo "  core sum: $coresum mask: $sum_mask"
        printf "  %-10s %-12s %-s\n" "thread" "core" "mask"
        for ((i=0;i<${#QEMU_PID_ARR[@]};i++)) ;{
          [ $i -le 1 ] || [ $i -eq $((${#QEMU_PID_ARR[@]}-1)) ] && {
              taskset -p $sum_mask ${QEMU_PID_ARR[i]} 2>&1 > /dev/null
              printf "  %-10s %-12s %-s\n" ${QEMU_PID_ARR[i]} $CORE_LIST $sum_mask
            } || {
              let indx=i-2
              convDeci_bin ${CORE_ARR[indx]}
              taskset -p $BITMASK ${QEMU_PID_ARR[i]} 2>&1 > /dev/null
              printf "  %-10s %-12s %-s\n" ${QEMU_PID_ARR[i]} ${CORE_ARR[indx]} $BITMASK
            }
        }
  
      } || {
        echo "  the cpu list is not corresponding with the threads list, wait for a second and try again"
      }
    }

  } || {
    echo "$PINCORE_USAGE"
  }
}

. sys.sh
pinthread_core $@
