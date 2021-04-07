#!/bin/bash
full() {
  for i in {0..38}; {
    echo android$i
    docker exec -it android$i sh -c 'input tap 1024 40'
    sleep 2
    docker exec -it android$i sh -c 'input tap 790 210'
    sleep 1
    docker exec -it android$i sh -c 'input tap 780 520'
    sleep 1
    docker exec -it android$i sh -c 'input tap 521 521'
  }
}

ad_clean() {
  for j in 1 2 3; {
  #for j in 1 2 ; {
    for i in 1 17 18 28; {
      echo android$i
      docker exec -it android$i sh -c 'input tap 1025 641'
      docker exec -it android$i sh -c 'input tap 1193 124'
    }
  }
}

# 0
start_watch() {
  echo android$1
  docker exec -it android$1 sh -c 'input tap 1024 40'
}

# 1
play_video() {
  echo android$1
  docker exec -it android$1 sh -c 'input tap 790 210'
}

# 2
confirm_watch() {
  echo android$1
  docker exec -it android$1 sh -c 'input tap 780 520'
}

# 3
head_video() {
  echo android$1
  docker exec -it android$1 sh -c 'input tap 521 521'
}

main() {
  case $1 in
  full)
    full
  ;;
  ad)
    ad_clean
  ;;
  0)
    shift
    start_watch $1
  ;;
  1)
    shift 
    play_video $1
  ;;
  2)
    shift
    confirm_watch $1
  ;;
  3)
    shift
    head_video $1
  ;;
  *)
    echo "support full | ad | 0 | 1 | 2 | 3"
    echo " full: full steps to watch the video"
    echo " ad: clean ad"
    echo " 0: start watch"
    echo " 1: play video"
    echo " 2: confirm watch"
    echo " 3: head video"
  ;;
  esac
}

main $@
