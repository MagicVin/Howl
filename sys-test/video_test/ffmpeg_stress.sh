#!/bin/bash
# xinx.e.zhang@intel.com
# Mar 21, 2021
# v1.1

options() {

USAGE=$(cat <<- EOF
options:
  -i    -- input file 
  -bv   -- video bitrate
  -ba   -- audio bitrate
  -s    -- frame size (e.g. 1280x720)
  -r    -- frame rate (e.g 30 fps)
  -vc   -- vcodec
  -o    -- output file
  -l    -- loops
EOF
)
  [ $# -lt 2 ] && {
    echo "$USAGE"
    exit
  }

    while [ $# -gt 1 ]
    do
      case $1 in 
        -i)
          shift
          input_file=$1
          shift
        ;;
        -bv)
          shift
          video_bitrate=$1
          shift
        ;;
        -ba)
          shift
          audio_bitrate=$1
          shift
        ;;
        -s)
          shift
          framesize=$1 #1280x720
          shift
        ;;
        -r)
          shift
          framerate=$1 #fps=30
          shift
        ;;
        -vc)
          shift
          vcodec=$1
          shift
        ;;
        -o)
          shift
          output_file=$1
          shift
        ;;
        -l)
          shift
          loops=$1
          shift
        ;;
        *)
          echo "unsupported options: $@"
          echo "$USAGE"
          exit
        ;;
      esac
    done
}

parse_opts() {
  log_name="ffreport-`date +'%m%d-%H%M%S'`.txt"
  #heads="FFREPORT=file=${log_name}:level=-8 ffmpeg -y -stats"
  #heads="ffmpeg -y -stats -vstats"
  heads="ffmpeg -y -stats"
  mids=" "
  tails="-hide_banner -benchmark"
  [[ $input_file ]] && [ -s $input_file ] || {
    echo "file:$input_file does not exist"
    exit
  }

  [[ $video_bitrate ]] && mids="$mids -b:v $video_bitrate"
  [[ $audio_bitrate ]] && mids="$mids -b:a $audio_bitrate"
  [[ $framesize ]] && mids="$mids -s $framesize"
  [[ $framerate ]] && mids="$mids -r $framerate"
  #[[ $vcodec ]] && mids="$mids -vcodec $vcodec"
  [[ $vcodec ]] && mids="$mids -c:v $vcodec" || mids="$mids -c:v libx264 -c:a copy" #libx264
  [[ $loops ]] && stress_loops=$loops || stress_loops=1

}

copy_orifile() {
  echo "copy source file"
  for ((i=0;i<stress_loops;i++)) ;{
    name=$i-in.mp4
    [ -s $name ] || cp $input_file $name
    echo "`ls -l $name`"
  }
}

loops_stress() {
  copy_orifile
  pids_arr=()
  for ((i=0;i<stress_loops;i++)) ;{
    iname=$i-in.mp4
    oname=$i-out.mp4
    [[ $i -eq 0 ]] && [[ $output_file ]] && oname=$output_file
    [ -s $iname ] && {
      cmds="$heads -i $iname $mids $tails $oname > $i.txt 2>&1 &"
      echo "cmds: $cmds"
      #$cmds 
      $heads -i $iname $mids $tails $oname > $i.txt 2>&1 &
      pids_arr[i]=$!
      sleep 0.5
    } || {
      echo "file: $iname does not exist"
      exit
    }
  }

}

stress_wait() {
  while true
  do
    pids="`echo ${pids_arr[@]} | sed 's/ /\|/g'`"
    ps aux | egrep $pids | grep -v grep > /dev/null 2>&1
    [ $? -eq 0 ] && {
      sleep 5
    } || {
      echo "stress is done"
      parse_log | tee result.log
      rm -rf *in*
      rm -rf *out*
      break
    }
  done
}

parse_log() {
  avg_fps=()
  end_fps=()
  cpu_time=()
  max_mem=()
  for ((i=0;i<stress_loops;i++)) ;{
    per_log=$i.txt
    #[ -s $i.txt ] && sed -e 's/\r/\n/g' $i.txt | awk '/Past/ || /lib/ {next} /frame/,/max/ { print }'| tee -a stress.log
    [ -s $per_log ] && {
      avg_fps[i]=`sed -e 's/\r/\n/g' $per_log | grep fps | awk -F '=' '{sum+=$3} END {gsub(" q","");print sum/NR}'`
      end_fps[i]=`sed -e 's/\r/\n/g' $per_log | awk -F '=' '/Lsize/ {gsub(" q","");print $3}'`
      cpu_time[i]=`sed -e 's/\r/\n/g' $per_log | awk -F '=' '/utime/ {print $2}'`
      max_mem[i]=`sed -e 's/\r/\n/g' $per_log | awk -F '=' '/maxrss/ {print $2}'`
    }
  }

  avg_afps=`echo ${avg_fps[@]} | awk '{for(i=1;i<=NF;i++){a+=$i}} END {printf ("%-d", a/NF)}'`
  avg_efps=`echo ${end_fps[@]} | awk '{for(i=1;i<=NF;i++){a+=$i}} END {printf ("%-d", a/NF)}'`
  avg_ctime=`echo ${cpu_time[@]} | awk '{for(i=1;i<=NF;i++){a+=$i}} END {printf ("%-d", a/NF)}'`
  avg_mmem=`echo ${max_mem[@]} | awk '{for(i=1;i<=NF;i++){a+=$i}} END {printf ("%-d", a/NF)}'`

  printf "%-6s %-6s %-7s %-8s %s\n" "thread" "ref_fps" "avg_fps" "cpu_time" "max_memUse"
  for ((i=0;i<stress_loops;i++)) ;{
    printf "%-6s %-7s %-7s %-8s %s\n" "$i" "${end_fps[i]}" "${avg_fps[i]}" "${cpu_time[i]}" "${max_mem[i]}"
  }
  printf "%-6s %-7s %-7s %-8s %s\n" "avg" "$avg_efps" "$avg_afps" "${avg_ctime}s" "${avg_mmem}kB"

}

main() {
  options $@
  parse_opts
  loops_stress
  stress_wait
}

main $@

