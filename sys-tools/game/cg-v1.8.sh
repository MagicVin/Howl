#!/bin/bash
# This is cg lib
# Author: xinx.e.zhang@intel.com
# Date: 2020, Nov 01
# Version: v1.8
#################################<env#########################################

envlib() {
  NORMAL_USER=root
  LD_LIBRARY=/opt/intel/mediasdk/share/mfx/samples/_bin/x64/
}

envaic() {
  #AIC_DIR=/home/media/ACGSS_SG1_LR_LT_4.2_Dev_666/aic-cg
  AIC_DIR=/data/aic
  AIC=${AIC_DIR}/aic
  AAPT=${AIC_DIR}/aapt
  ACCOUNT_FILE=/data/kog/vm1-account.txt
  OBB_DIR=
  INSTANCE_NUM=
  REMOTE_USER=
  REMOTE_IP=
  REMOTE_DIR=/home/$REMOTE_USER/temp

}

envsys() {
  DEBUG_LEVEL_PATH=/home/$NORMAL_USER/work/system/service
  DEBUG_LEVEL_SCRIPT=$DEBUG_LEVEL_PATH/highest_debug_level.sh
  DEBUG_LEVEL_SERVICE=$DEBUG_LEVEL_PATH/highest_debug_level.service
}

enveth() {
  ETH_CONF_PATH=/etc/sysconfig/network-scripts
  BOOT_ENABLE_ETH_DEV=ens3
}

envi915() {
  CARD_DRI_PATH=/sys/kernel/debug/dri
  #SYNC_PATH=/home/$NORMAL_USER/work/i915_dri
  SYNC_PATH=/data/i915_dri
}

envqemu() {
  QEMU_LINK=https://download.qemu.org/qemu-5.0.0.tar.xz
  #QEMU_BUILD=/home/$NORMAL_USER/work/qemu
  QEMU_BUILD=/root/work/qemu
  QEMU_SW=$QEMU_BUILD/sw
  IMG_DIR=$QEMU_BUILD/img
  SAMPLE_IMG=$IMG_DIR/vm-os.raw
  ISO_DIR=$QEMU_BUILD/os/CentOS-7.4-x86_64-DVD-1708.iso
  PREPARE_DIR=$QEMU_BUILD/prepare
  BOOT_DIR=$QEMU_BUILD/boot
}

envproxy() {
  export http_proxy=http://child-prc.intel.com:913
  export https_proxy=http://child-prc.intel.com:913
}

envfree() {
  FREE_RAW_DATA="mem.txt"
  FREE_PLOT_DATA="mem.dat"
  FREE_PLOT_SCRIPT="mem.gp"
  FREE_SEC=1
  FREE_COUNT=60
  FREE_CHART_TITLE="Mem Trace"
  FREE_CHART_NAME="mem-test.png"
}
#################################env\>#########################################

#################################<sys#########################################

syslib_root_access() {
  [ $USER != root ] && echo "please grant the root permission, try again" && exit -1
}

syslib_int_num() {
  [ $# -eq 1 ] || [ $# -eq 0 ] && {
    [[ `echo $1 | awk '/^[0-9]+$/ && $1 > 0'` ]] && echo 0 || echo 1
    :
  } || {
    echo "  only support one parameter, but $#($@) were given."
  }
}

platform_check() {
  awk '/^ID=/ {gsub("\"","");sub("^ID=","");print}' /etc/os-release
}

syslib_list() {
  local list_raw_arr=($@)
  local list_l1_arr=(`echo ${list_raw_arr[@]} | sed 's/,/ /g'`)
  local single_num=""
  local multi_char_str=""
  local MULTI_NUM_OPTION=0
  LIST_ACTION=1
  for i in ${list_l1_arr[@]}	;{
    [[ "${i}" =~ "-" ]] && {
      multi_char_str="${multi_char_str}${i} "
    } || {
      single_num="${single_num}${i} "
    }
  }

  [[ ! -z "${multi_char_str}" ]] && {
  local	multi_num=""
    for i in ${multi_char_str[@]} ;{
      each_group_arr=(`echo $i | sed 's/-/ /g'`)
      [ ${#each_group_arr[@]} -eq 2 ] && { 
        for ((idx=each_group_arr[0];idx<=each_group_arr[1];idx++)) ;{
          multi_num="${multi_num}${idx} "
        }
      } || {
        let MULTI_NUM_OPTION=MULTI_NUM_OPTION+1
        echo "  wrong list: $i, must be two num(e.g: 1-3)"
      }
    }
  }
	
  [ $MULTI_NUM_OPTION -eq 0 ] && {
    local random_list_arr=()
    local all_unit_arr=()
    UNQ_ARR=()
    random_list_arr=(${single_num} ${multi_num})
    all_unit_arr=(`syslib_sort ${random_list_arr[@]}`)
    UNQ_ARR=(`echo ${all_unit_arr[@]} | sed 's/ /\n/g' | uniq`)
  }
  LIST_ACTION=$MULTI_NUM_OPTION
}

syslib_sort() {
  local temp_list=($@)
  local list_len=${#temp_list[@]}
  for ((t=0;t<list_len;t++)) ;{
    for ((o=1;o<=list_len-1;o++)) ;{
      [ ${temp_list[o-1]} -gt ${temp_list[o]} ] && {
        temp=${temp_list[o-1]}
        temp_list[o-1]=${temp_list[o]}
        temp_list[o]=$temp
      }
    }
  }
  echo ${temp_list[@]}
}


syslib_second() {
  sec=$1
  echo "  wait for ${sec}s ..."
  for i in `seq $sec` ;{
    echo -en "  [${i}]\r"
    sleep 1
  }
}

syslib_ip_check() {
  ip addr | grep ${1}: -A3 | sed -n 's/^.*inet \(.*\)\/.*$/\1/p'
}

syslib_ipp() {
  ETH_LIST=(`ip addr | grep mtu | sed -n 's/^.: \(.*\): <.*$/\1/p'`)
  for i in ${ETH_LIST[@]} ;{
    [[ $i = "lo" ]] && continue
    echo $i: `syslib_ip_check $i`
  }
}

syslib_iommu_group() {
  shopt -s nullglob
  for d in /sys/kernel/iommu_groups/*/devices/* ;{
    n=${d#*/iommu_groups/*}
    n=${n%%/*}
    printf ' IOMMU GROUP %s ' "$n"
    lspci -nns "${d##*/}"
  }
}

syslib_proc_threads() {
  local proc_num=(`ls /proc`)  
  local c=0
  local n=0
  for i in ${proc_num[@]} ;{
    tasks=/proc/$i/task
    [ -d $tasks ] && {
      a=`ls $tasks | wc -l`
      let c=c+a
      let n++
      cmds=(`sudo ps aux | awk -v PIDD="$i" '$2 == PIDD {print $11}'`)
      printf " %-7s %-7s %-6s %-6d %-s\n" "pid:" $i "tasks:" $a "cmds: "${cmds[@]}
    }
  }
  printf " %-7s %-7s %-6s %-6d\n" "total:" $n  "tasks:" $c
}

syslib_card_id() {
  local c=0
  PCI_ARR=(`lspci | awk '/VGA.*490[5|7]/ {print $1}'`)
  for i in ${PCI_ARR[@]} ;{
    PCI_DRI[c]="`lspci -s $i -n -vv | awk '/Kernel driver in use:/ {print $NF}'`"
    let c++
  }
  BUS_PATH=/sys/bus/pci/devices/0000:
}

syslib_i915_card() {
  [[ ${PCI_ARR[@]} ]] || syslib_card_id
  printf " %-10s %-5s %-5s %-15s %-15s %-9s %-9s %-9s %-9s %-s\n" "id" "irq" "numa" "cpu" "driver" "speed" "cfreq/MHz" "mfreq/MHz" "Mfreq/MHz" "dev"
  local c=0
  for i in ${PCI_ARR[@]} ;{
    gpu_id=$BUS_PATH$i
    [ -e $gpu_id/irq ] && gpu_irq=(`cat $gpu_id/irq`) || gpu_irq="/"
    [ -e $gpu_id/numa_node ] && gpu_numa=(`cat $gpu_id/numa_node`) || gpu_numa="/"
    [ -e $gpu_id/local_cpulist ] && gpu_cpu=`cat $gpu_id/local_cpulist` || gpu_cpu="/"
    [ -e $gpu_id/current_link_speed ] && gpu_speed=(`cat $gpu_id/current_link_speed`) || gpu_speed="/"
    [ -e $gpu_id/drm/card* ] && {
      gcard_id="`ls -d $gpu_id/drm/card*`"
      gpu_cfreq=(`cat $gcard_id/gt_cur_freq_mhz`)
      gpu_bfreq=(`cat $gcard_id/gt_boost_freq_mhz`)
      gpu_Mfreq=(`cat $gcard_id/gt_max_freq_mhz`)
      gpu_mfreq=(`cat $gcard_id/gt_min_freq_mhz`)
      gpu_dev=(`ls $gpu_id/drm`)
    } || {
      gcard_id="/"
      gpu_cfreq="/"
      gpu_bfreq="/"
      gpu_Mfreq="/"
      gpu_mfreq="/"
      gpu_dev="/"
    }

    printf " %-10s %-5s %-5d %-15s %-15s %-9s %-9s %-9s %-9s %-s\n" $i ${gpu_irq[@]} ${gpu_numa[@]} ${gpu_cpu[@]} ${PCI_DRI[c]} "`echo ${gpu_speed[@]}`"\
    "`echo ${gpu_cfreq[@]}`" "`echo ${gpu_mfreq[@]}`" "`echo ${gpu_Mfreq[@]}`" "`echo ${gpu_dev[@]}`"
    let c++
  }
}

syslib_i915_usage() {
  syslib_root_access
  [[ $# -eq 1 ]] && monitor_sec=$1 || monitor_sec=30
  [[ ${PCI_ARR[@]} ]] || syslib_card_id
  mkdir -p i915_usage
  cd i915_usage
  local c=0
  local metrics_arr
  export LD_LIBRARY_PATH=$LD_LIBRARY:$LD_LIBRARY_PATH
  echo "  starting metrics monitor for gpu node ..."
  for i in ${PCI_ARR[@]} ;{
    gpu_id=$BUS_PATH$i
    [ -e $gpu_id/drm/render* ] && {
      render_dev=`ls -d $gpu_id/drm/render* | awk -F / '{print $NF}'`
      ${LD_LIBRARY}metrics_monitor -d /dev/dri/$render_dev > $render_dev.txt &
      metrics_arr[c]=$!
      let c++
      :
    }
  }
  echo "  wait for ${monitor_sec}s to collecte the data ..."
  syslib_second ${monitor_sec}
  echo "  collecting done, stop the metrics monitor ..."
  for i in ${metrics_arr[@]} ;{
    sudo kill -9 $i
  }
  sudo chown $NORMAL_USER:$NORMAL_USER -R *txt
  echo "  log path: `pwd`"
}

syslib_deviceid() {
  [ $# -gt 0 ] && {
    syslib_list $@
    [ $LIST_ACTION -eq 0 ] && {
      for i in ${UNQ_ARR[@]} ;{
        device_id=(`docker exec android$i sh -c 'logcat -d' | awk '/cloudgame.*device/ {print $NF}'`)
        echo "  android$i ${device_id[0]}"
      }
    }
  } || {
    echo "  the instance's id should be given, 0-10 or 0,2,3"
  }
}

ruby_cal() {
  RES_VALUE=0
  [ $# -eq 2 ] && {
    RES_VALUE=`ruby -e 'p (ARGV[0].to_i)+(ARGV[1].to_i)' $1 $2`
    return 0
  } || {
    echo "  value is incorrect"
    return 1
  }
}

dir_comp() {
  [ $# -eq 2 ] && {
    local comp_arr=($@)
    local comp_count=0
    local comp_len=${#comp_arr[@]}
    for i in ${comp_arr[@]} ;{
      [ -d $i ] && ruby_cal $comp_count 0 && comp_count=$RES_VALUE || comp_count=1 
    }
    
    [ $comp_count -eq 0 ] && {
      for ((i=0;i<comp_len;i++)) ;{
        arr_name=(`ls ${comp_arr[i]} -l | awk '{print $9}'`)
        arr_size=(`ls ${comp_arr[i]} -l | awk '{print $5}'`)
        comp_dic_name+=([i]=${arr_name[@]})
        comp_dic_size+=([i]=${arr_size[@]})
      }

      local max_num=0
      for ((i=0;i<comp_len;i++))  ;{
        temp_arr=(${comp_dic_name[i]})
        [ $max_num -lt ${#temp_arr[@]} ] && max_num=${#temp_arr[@]}
      }
      f0_name=(${comp_dic_name[0]})
      f0_size=(${comp_dic_size[0]})
      f1_name=(${comp_dic_name[1]})
      f1_size=(${comp_dic_size[1]})


      [ ${#f0_name[@]} -eq $max_num ] && {
        max_name=(${f0_name[@]})
        max_size=(${f0_size[@]})
        min_name=(${f1_name[@]})
        min_size=(${f1_size[@]})
      } || {
        max_name=(${f1_name[@]})
        max_size=(${f1_size[@]})
        min_name=(${f0_name[@]})
        min_size=(${f0_size[@]})
      }
      
      printf "  %-25s %-12s %-5s% -12s %-s\n" "name" "first" "*" " second" "diff"
      local gt_v=0
      local eq_v=0
      local lt_v=0
      for ((i=0;i<max_num;i++)) ;{
        max_c=1
        for ((j=0;j<${#min_name[@]};j++)) ;{
          [ "${max_name[i]}" == "${min_name[j]}" ] && {
            max_c=0
            printf "  %-25s" ${max_name[i]}
            [ ${max_size[i]} -eq ${min_size[j]} ] && ruby_cal $eq_v 1 && eq_v=$RES_VALUE && printf " %-12s %-5s %-12s %-s\n" ${max_size[i]} "=" ${min_size[j]} " 0"
            [ ${max_size[i]} -gt ${min_size[j]} ] && ruby_cal $gt_v 1 && gt_v=$RES_VALUE && printf " %-12s %-5s %-12s %-s\n" ${max_size[i]} ">" ${min_size[j]} "+1"
            [ ${max_size[i]} -lt ${min_size[j]} ] && ruby_cal $lt_v 1 && lt_v=$RES_VALUE && printf " %-12s %-5s %-12s %-s\n" ${max_size[i]} "<" ${min_size[j]} "-1"
          } 
        }
        [ $max_c -eq 1 ] && printf "  %-25s\n" ${max_name[i]}
      }
      
      echo "  equal|greater|less: $eq_v|$gt_v|$lt_v same|change: $eq_v|$((gt_v+lt_v)) "
    }

  }

}


syslib() {
  SYSLIB_USAGE=$(cat <<- EOF
  support options:
    sort     -- convert string to list
    ip       -- show ip address
    iommu    -- show iommu group info
    task     -- show threads and tasks info
    gpu      -- show gpu info
    cgame    -- show device id of cloudgame
    dir      -- show the difference of dir
EOF
)
  case $1 in
    sort)
      shift
      syslib_list $@
      echo ${UNQ_ARR[@]}
    ;;
    ip)
      shift
      syslib_ipp
    ;;
    iommu)
      shift
      syslib_iommu_group
    ;;
    task)
      shift
      syslib_proc_threads
    ;;
    gpu)
      shift
      syslib_i915_card
    ;;
    cgame)
      shift
      syslib_deviceid $@
    ;;
    dir)
      shift
      dir_comp $@
    ;;
    *)
      echo "$SYSLIB_USAGE"
    ;;
  esac
}

#################################sys\>#########################################

#################################<set#########################################

setlib_vim_conf() {
  setlib_vimrc_details > /home/${NORMAL_USER}/.vimrc
  sudo chown ${NORMAL_USER}:${NORMAL_USER} /home/${NORMAL_USER}/.vimrc
  sudo cp /home/${NORMAL_USER}/.vimrc /root/.vimrc
}

setlib_vimrc_details() {
  echo "set ts=2"
  echo "set expandtab"
  echo "set autoindent"
}

setlib_service_conf() {
  echo "  stop and disable firewalld"
  sudo systemctl stop firewalld
  sudo systemctl disable firewalld
  sudo systemctl status firewalld
  echo "  stop and disable libvirtd"
  sudo systemctl stop libvirtd
  sudo systemctl disable libvirtd
  sudo systemctl status libvirtd
}

setlib_loglevel() {
  envsys
DEBUG_SCRIPT=$(cat <<- EOF

echo "echo 8 8 8 8 > /proc/sys/kernel/printk"
echo 8 8 8 8 > /proc/sys/kernel/printk
[ \$? -eq 0 ] && echo "log level: \`cat /proc/sys/kernel/printk | xargs\`"
EOF
)

DEBUG_SERVICE=$(cat <<- EOF
[Unit]
Description=highest level of kernel log
Requires=default.target

[Service]
Type=oneshot
ExecStart=/bin/bash ${DEBUG_LEVEL_SCRIPT}
ExecStop=/bin/echo stop
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF
)

  mkdir -p $DEBUG_LEVEL_PATH
  echo "$DEBUG_SCRIPT" > $DEBUG_LEVEL_SCRIPT
  echo "$DEBUG_SERVICE" > $DEBUG_LEVEL_SERVICE
  sudo chmod +x $DEBUG_LEVEL_SERVICE
  sudo ln -s $DEBUG_LEVEL_SERVICE /lib/systemd/system/highest_debug_level.service

  echo "  enable highest_debug_level.service"
  sudo systemctl enable highest_debug_level.service
  sudo systemctl start highest_debug_level.service
  sudo systemctl status highest_debug_level.service
}

setlib_eth() {
  enveth
  local eth_conf
  local boot_status
  eth_conf=${ETH_CONF_PATH}/ifcfg-${BOOT_ENABLE_ETH_DEV}
  [ -s $eth_conf ] && {
    boot_status=`awk -F '=' '/ONBOOT/ {print $2}' $eth_conf`
    case $boot_status in
      yes)
        echo "  ${BOOT_ENABLE_ETH_DEV} has already been set to enabling"
      ;;
      no)
        echo "  onboot status of ${BOOT_ENABLE_ETH_DEV} is $boot_status, set to yes ..."
        sudo sed -i 's/ONBOOT=.*$/ONBOOT=yes/' $eth_conf
        echo "  `awk '/ONBOOT/ {print}' $eth_conf`"
      ;;
      *)
        echo "  unknown status: $boot_status"
    esac
  
  } || {
    echo "  can't find the conf: $eth_conf"
  }
}

setlib_i915_sync() {
  envi915
  echo "  dri syncing ..."
  bkp_time=`date +%m%d-%H%M%S`
  [ -e ${SYNC_PATH}/sync_dri ] && sudo mv ${SYNC_PATH}/sync_dri ${SYNC_PATH}/sync_dri_${bkp_time}
  sudo mkdir -p $SYNC_PATH/sync_dri
  setlib_sync_dri &
}

setlib_sync_dri() {
  i915_log_list=(i915_error_state i915_gem_objects i915_engine_info)
  node_list=(`sudo ls $CARD_DRI_PATH`)
  while true
  do
    for i in ${node_list[@]} ;{
      for j in ${i915_log_list[@]} ;{
        [ -f $CARD_DRI_PATH/$i/$j ] && {
          sudo cp $CARD_DRI_PATH/$i/$j $SYNC_PATH/sync_dri/node${i}_${j}
        }
      }
    }
    date >> $SYNC_PATH/sync_dri/memory.txt
    echo "<free"  >> $SYNC_PATH/sync_dri/memory.txt
    free -m >> $SYNC_PATH/sync_dri/memory.txt
    echo "free>" >> $SYNC_PATH/sync_dri/memory.txt
    
    ls $SYNC_PATH/sync_dri/*_i915_error_state > /dev/null 2>&1 && {
      for i in `ls $SYNC_PATH/sync_dri/*_i915_error_state` ; {
       [ -s $i ] && echo $i | sed 's/^.*node\(.*\)_i915.*/error: node\1 - gpuhang/' >> $SYNC_PATH/sync_dri/memory.txt
     }
    }

    ls $SYNC_PATH/sync_dri/node*_i915_gem_objects > /dev/null 2>&1 && {
      echo "<object" >> $SYNC_PATH/sync_dri/memory.txt
      head -n8 $SYNC_PATH/sync_dri/node*_i915_gem_objects >> $SYNC_PATH/sync_dri/memory.txt
      echo "object>" >> $SYNC_PATH/sync_dri/memory.txt
    }

    dmesg > $SYNC_PATH/sync_dri/dmesg.txt
    sleep 30
  done
}

setlib_journalctl() {
  [ -z `sudo grep 'Storage=persistent' /etc/systemd/journald.conf` ] && {
    sudo sed -i 's/#Storage=auto/Storage=persistent/' /etc/systemd/journald.conf
    sudo systemctl restart systemd-journald.service
    sudo systemctl status systemd-journald.service
  } || {
    echo "  config works -- persistent store" 
    echo "  `sudo grep Storage /etc/systemd/journald.conf`"
  }
}

setlib_disbale_apt_autoupdate() {
  echo "  disable apt auto-update"

}

setlib_gpufix() {
  #[[ ${PCI_ARR[@]} ]] || syslib_i915_id
  [[ ${PCI_ARR[@]} ]] || syslib_card_id
  local freq=$1
  FREQ_C=1
  for i in ${PCI_ARR[@]} ;{
    gpu_id=$BUS_PATH$i
    [ -e $gpu_id/drm/card* ] && {
      gcard_id="`ls -d $gpu_id/drm/card*`"
      b_cfreq=`cat $gcard_id/gt_cur_freq_mhz`
      RP0_freq=`cat $gcard_id/gt_RP0_freq_mhz`
      RPn_freq=`cat $gcard_id/gt_RPn_freq_mhz`
      [ $freq -ge $b_cfreq ] && [ $freq -le $RP0_freq ] && {
        FREQ_C=0
        for j in gt_max_freq_mhz gt_min_freq_mhz ;{
          echo $freq > $gcard_id/$j
        }
      } 

      [ $freq -le $b_cfreq ] && [ $freq -ge $RPn_freq ] && {
        FREQ_C=0
        for j in gt_min_freq_mhz gt_max_freq_mhz ;{
          echo $freq > $gcard_id/$j
        }
        :
      }

      [ $FREQ_C -ne 0 ] && {
        echo "  freq: $freq is invalid value, it must be set under: $RPn_freq ~ $RP0_freq"
      }
    }
  }
}

convDeci_bin() {
  BITMASK=0
  BITMASK=`ruby -e "puts (2**(ARGV[0].to_i)).to_s(16)" $1`
}

convDeci() {
  DECIMAL=0
  DECIMAL=`ruby -e "puts (2**(ARGV[0].to_i))" $1`
}

pinprocess_core() {
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
        coresum=`ruby -e "puts (ARGV[0].to_i)+(ARGV[1].to_i)" $coresum $DECIMAL`
      }
      sum_mask=`ruby -e "puts (ARGV[0].to_i).to_s(16)" $coresum`
      echo "  core sum: $coresum mask: $sum_mask"
        printf "  %-10s %-35s %-s\n" "thread" "core" "mask"
        for ((i=0;i<${#QEMU_PID_ARR[@]};i++)) ;{
          [ $i -le 1 ] || [ $i -eq $((${#QEMU_PID_ARR[@]}-1)) ] && {
              taskset -p $sum_mask ${QEMU_PID_ARR[i]} 2>&1 > /dev/null
              printf "  %-10s %-35s %-s\n" ${QEMU_PID_ARR[i]} $CORE_LIST $sum_mask
            } || {
              let indx=i-2
              convDeci_bin ${CORE_ARR[indx]}
              taskset -p $BITMASK ${QEMU_PID_ARR[i]} 2>&1 > /dev/null
              printf "  %-10s %-35s %-s\n" ${QEMU_PID_ARR[i]} ${CORE_ARR[indx]} $BITMASK
            }
        }
  
      } || {
        echo "  the cpu list is not corresponding with the threads list, wait for a second and try again, thread|core: $((${#QEMU_PID_ARR[@]}))|${#CORE_ARR[@]} (thread=core+3)"

      }
    }

  } || {
    echo "$PINCORE_USAGE"
  }
}

setlib() {
  SETLIB_USAGE=$(cat <<- EOF
  support options:
    vim      -- set conf of vim
             1 tab == 2 space
             enable autoindent
    service  -- disable/enable service
             disable firewalld
             disable libvirtd
    loglevel -- enable highest log level
    journal  -- enable persistent store the log on disk
    eth      -- enable eth
    logi915  -- sync i915 log
    gpu      -- fix freq for gpu
    pin      -- pin cpu for process


EOF
)
  case $1 in 
    vim)
      shift
      setlib_vim_conf
    ;;
    service)
      shift
      setlib_service_conf
    ;;
    loglevel)
      shift
      setlib_loglevel
    ;;
    journal)
      shift
      setlib_journalctl
    ;;
    eth)
      shift
      setlib_eth
    ;;
    logi915)
      shift
      setlib_i915_sync
    ;;
    gpu)
      shift
      setlib_gpufix $@
    ;;
    pin)
      shift
      pinprocess_core $@
    ;;
    *)
      echo "$SETLIB_USAGE"
    ;;
  esac
}

#################################set\>#########################################

#################################<tool#########################################

docker_iubuntu() {
  apt-get remove docker docker-engine docker.io containerd runc
  apt-get update
  apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  apt-key fingerprint 0EBFCD88
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt-get update
  apt-get install docker-ce docker-ce-cli containerd.io -y
}

docker_icentos() {
  yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
  yum install -y yum-utils
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install docker-ce -y
}

docker_rubuntu() {
  apt-get remove docker docker-engine docker.io containerd runc
}

docker_rcentos() {
  yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
}

docker_install() {
  case $distribution in
    centos)
      echo "  install docker env ..."
      docker_icentos && D_CHECK=0 || D_CHECK=1
    ;;
    ubuntu)
      echo "  install docker env ..."
      docker_iubuntu && D_CHECK=0 || D_CHECK=1
    ;;
    *)
      echo "  current distribution is $distribution"
      echo "  this is scripts only supports centos/ubuntu"
      D_CHECK=1
    ;;
  esac

  [ $D_CHECK -eq 0 ] && {
    usermod -aG docker $NORMAL_USER
    usermod -aG video $NORMAL_USER

    systemctl enable docker
    systemctl start docker
    systemctl status docker
  }
}

docker_remove() {
  case $distribution in
    centos)
      echo "  removing docker env ..."
      docker_rcentos
    ;;
    ubuntu)
      echo "  removing docker env ..."
      docker_rubuntu
    ;;
    *)
       echo "  current distribution is $distribution"
       echo "  this is scripts only supports centos/ubuntu"
    ;;
  esac
}

gnuplot_icentos() {
  yum install gnuplot -y
}

gnuplot_iubuntu() {
  apt-get install gnuplot -y
}

gnuplot_install() {
  case $distribution in
    centos)
      echo "  install gnuplot ..."
      gnuplot_icentos && G_CHECK=0 || G_CHECK=1
    ;;
    ubuntu)
      echo "  install gnuplot ..."
      gnuplot_iubuntu && G_CHECK=0 || G_CHECK=1
    ;;
    *)
      echo "  current distribution is $distribution"
      echo "  this is scripts only supports centos/ubuntu"
      G_CHECK=1
    ;;
  esac
}

gnuplot_rcentos() {
  yum remove gnuplot -y
}

gnuplot_rubuntu() {
  apt-get remove gnuplot -y
}

gnuplot_remove() {
  case $distribution in
    centos)
      echo "  remove gnuplot ..."
      gnuplot_rcentos && G_CHECK=0 || G_CHECK=1
    ;;
    ubuntu)
      echo "  remove gnuplot ..."
      gnuplot_rubuntu && G_CHECK=0 || G_CHECK=1
    ;;
    *)
      echo "  current distribution is $distribution"
      echo "  this is scripts only supports centos/ubuntu"
      G_CHECK=1
    ;;
  esac
}

toollib_install() {
  TOOLIB_INSTALL_USAGE=$(cat <<- EOF
  support tools:
    docker
    gnuplot

EOF
)
  case $1 in
    docker)
      docker_install
    ;;
    gnuplot)
      gnuplot_install
    ;;
    *)
      echo "$TOOLIB_INSTALL_USAGE"
    ;;
  esac
}

toollib_remove() {
  TOOLIB_REMOVE_USAGE=$(cat <<- EOF
  support tools:
    docker
    gnuplot

EOF
)

  case $1 in
    docker)
      docker_remove
    ;;
    gnuplot)
      gnuplot_remove
    ;;
    *)
      echo "$TOOLIB_REMOVE_USAGE"
    ;;
  esac  
}

toollib() {
  TOOLLIB_USAGE=$(cat <<- EOF
  support options:
    install [tool_name]
    remove [tool_name]
       
    tool_name: docker gnuplot

    usage: 
      install docker/gnuplot
      remove docker/gnuplot

EOF
)
  distribution=`platform_check` 
  case $1 in
    install)
      shift
      toollib_install $@
    ;;
    remove)
      shift
      toollib_remove $@
    ;;
    *)
      echo "$TOOLLIB_USAGE"
    ;;
  esac

}


#################################tool\>#########################################

#################################<qemu#########################################

qemu_depend() {
  distribution=`platform_check`
  case $distribution in
    centos)
      echo "  install the sw requirements"
      qemu_centos && P_CHECK=0 || P_CHECK=1
    ;;
    ubuntu)
      echo "  install the sw requirements"
      qemu_ubuntu && P_CHECK=0 || P_CHECK=1
    ;;
    suse)
      echo "  install the sw requirements"
      qemu_suse && P_CHECK=0 || P_CHECK=1
    ;;
    *)
      echo "  current distribution is $distribution"
      echo "  this script only supports centos/ubuntu/suse"
      P_CHECK=1
    ;;
  esac
}

qemu_sw() {
  mkdir -p $QEMU_BUILD
  wget -P $QEMU_SW -nc -c $QEMU_LINK
}

qemu_install() {
  qemu_depend
  [ $P_CHECK -eq 0 ] && {
    qemu_sw
    sleep 10
    QEMU_PKG_NAME=`ls $QEMU_SW -lrt | awk 'END {print $NF}'`
    QEMU_PKG=$QEMU_SW/$QEMU_PKG_NAME
    [ -s $QEMU_PKG ] && {
      echo "  yes, the file $QEMU_PKG is good"
      cd $QEMU_SW
      tar -Jxvf $QEMU_PKG_NAME
      QEMU_DIR=`echo $QEMU_PKG_NAME |  awk 'BEGIN {FS=".tar"} {print $1}'`
      [ -d $QEMU_DIR ] && {
        echo "qemu_dir: $QEMU_DIR"
        cd $QEMU_DIR
        ./configure --enable-numa
        make -j24
        ln -s $QEMU_SW/$QEMU_DIR/x86_64-softmmu/qemu-system-x86_64 /usr/bin/qemu-system-x86_64
        ls -l /usr/bin/qemu-system-x86_64
        qemu-system-x86_64 --version && echo "  qemu installation is done" || echo "  qemu installation fail"
      }
    } || {
      echo "  the size of $QEMU_PKG < 0"
    }
  }
}

qemu_ubuntu() {
  apt-get update
  apt-get install git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev -y
  apt-get install git-email -y
  apt-get install libaio-dev libbluetooth-dev libbrlapi-dev libbz2-dev -y
  apt-get install libcap-dev libcap-ng-dev libcurl4-gnutls-dev libgtk-3-dev -y
  apt-get install libibverbs-dev libjpeg8-dev libncurses5-dev libnuma-dev -y
  apt-get install librbd-dev librdmacm-dev -y
  apt-get install libsasl2-dev libsdl1.2-dev libseccomp-dev libsnappy-dev libssh2-1-dev -y
  apt-get install libvde-dev libvdeplug-dev libvte-2.90-dev libxen-dev liblzo2-dev -y
  apt-get install valgrind xfslibs-dev -y
  apt-get install libnfs-dev libiscsi-dev -y
}

qemu_centos() {
  yum install git glib2-devel libfdt-devel pixman-devel zlib-devel -y
  yum install libaio-devel libcap-devel libiscsi-devel -y
  yum install tightvnc python3 -y
  yum install numactl-devel -y
}

qemu_suse() {
  yum install libaio-devel libcap-devel libiscsi-devel -y
  zypper install perf valgrind -y
}

qemu_img() {
  mkdir -p $IMG_DIR
  [ -s $SAMPLE_IMG ] || {
    cd $IMG_DIR
    echo "  create vm-os.qcow2 image ..."
    qemu-img create -f raw vm-os.raw 100G
    echo "  img: $SAMPLE_IMG"
    cd - > /dev/null 2>&1
  }
}

build_cmds() {
  cmds=(
    qemu-system-x86_64
    -enable-kvm
    -m 32G 
    -smp 16 -M pc
    -cpu host
    -hda $SAMPLE_IMG
    -cdrom $ISO_DIR -boot d
    -daemonize
    -vnc :10 -k en-us
  )

  echo "  ${cmds[@]}"
  ${cmds[@]}
}

qemu_build() {
  echo "  start building program..."
  qemu_img
  echo "  `ls -l $SAMPLE_IMG`"
  [ -s $SAMPLE_IMG ] && {
    echo "  building vm ..."
    build_cmds
  }
}

boot_cmds() {
  cmds=(
    qemu-system-x86_64
    -enable-kvm
    -m 32G
    -smp 16 -M pc
    -cpu host
    -hda $SAMPLE_IMG
    -daemonize
    -vnc :10 -k en-us
  )

  echo "  ${cmds[@]}"
  ${cmds[@]}
}

qemu_boot () {
  echo "  booting up vm ..."
  boot_cmds
}

qemulib() {
  QEMULIB_USAGE=$(cat <<- EOF
  support options:
    sw     -- install qemu package and sw requirements
    build  -- build a vm for reference
    boot   -- boot up the sample
EOF
)
  case $1 in
    sw)
      qemu_install
    ;;
    build)
      qemu_build
      qemu_br
    ;;
    boot)
      qemu_boot
    ;;
    *)
      echo "$QEMULIB_USAGE"
    ;;
  esac
}

#################################qemu\>#########################################

#################################<br-out#########################################
qemu_br() {
  QEMU_BR_SCRIPT=$(cat <<- EOF

set -x

bridge_setup() {
  [[ -z \`ip link show \${BRIDGE_NAME} | awk -v BR=\${BRIDGE_NAME} '/BR/ {print}'\` ]] && {
    echo "  create bridge \$BRIDGE_NAME"
    ip link add \$BRIDGE_NAME type bridge
    echo "  clean IP for \$NIC_NAME"
    ip addr flush dev \$NIC_NAME
    echo "  add dev:\$NIC_NAME to group:\$BRIDGE_NAME"
    ip link set \$NIC_NAME master \$BRIDGE_NAME
    echo "  set \$BRIDGE_NAME up"
    ip link set dev \$BRIDGE_NAME up
    echo "  assign IP for \$BRIDGE_NAME"
    dhclient \$BRIDGE_NAME
  } || {
    echo "  bridge: \$BRIDGE_NAME has created"
    br_state=\`ip link show \${BRIDGE_NAME} | awk -v BR=\${BRIDGE_NAME} '/BR/ {sub("^.*state","");print \$1}'\`
    [ \$br_state != "UP" ] && {
      echo "  set \$BRIDGE_NAME up"
      ip link set dev \$BRIDGE_NAME up
      echo "assign IP for \$BRIDGE_NAME"
      dhclient \$BRIDGE_NAME
    }
  }
}

tap_setup(){
  [[ \`ip link | grep "\$1"\` ]] && {
    echo "  \$1 has created"
    tap_state=\`ethtool \$1 | awk '/Link detected/ {print \$NF}'\`
    [ \$tap_state != "yes" ] && {
      echo "  add dev:\$1 to group:\$BRIDGE_NAME"
      ip link set \$1 master \$BRIDGE_NAME
    } || {
      echo "  delete tap device: \$1"
      ip link delete dev \$1
      echo "  create tap_dev: \$1"
      ip tuntap add dev \$1 mode tap user root
      echo "  add dev:\$1 to group:\$BRIDGE_NAME"
      ip link set \$1 master \$BRIDGE_NAME
    }
  } || {
    echo "  create tap_dev: \$1"
    ip tuntap add dev \$1 mode tap user root
    echo "  add dev:\$1 to group:\$BRIDGE_NAME"
    ip link set \$1 master \$BRIDGE_NAME
  }
  echo "  set dev:\$1 up"
  ip link set dev \$1 up
}

main() {
  [ -z "\$1" ] && echo "  Error: no interface specified" && exit 1
  NIC_NAME=enp61s0f0
  BRIDGE_NAME=br0
  bridge_setup
  tap_setup \$1
}

main \$1
EOF
)
  mkdir -p $PREPARE_DIR
  echo "#!/bin/bash" > $PREPARE_DIR/qemu_br
  echo "$QEMU_BR_SCRIPT" >> $PREPARE_DIR/qemu_br
  chmod +x $PREPARE_DIR/qemu_br
}
#################################br-out\>#########################################

#################################<app#########################################

applib_options() {
  AL_OPTIONS_USAEG=$(cat <<- EOF
  usage:
    -n [name] -r [res] -l [aic_list]
   
    -n kog -r 1280x720 -l 0-9
EOF
)
  echo "> applib_options $@"

  local options_action=0
  options_go=1
  local app_res
  local aic_list
  local app_name

  [ $# -eq 6 ] && {
    while [ $# -gt 0 ]
    do
      case $1 in
          -n)
            app_name=$2
            shift
            shift
          ;;
          -r)
            app_res=$2
            shift
            shift
            ;;
          -l)
            aic_list=$2
            shift
            shift
            ;;
          *)
						echo "  unsupported app options: $@"
            echo "$AL_OPTIONS_USAEG"
            applib_support_info
            let options_action=options_action+1
            break
          ;;
      esac
    done
  } || {
    echo "  need 6 parameters but $# were given"
    let options_action=options_action+1
    echo "$AL_OPTIONS_USAEG"
    applib_support_info
  }
	
  [ $options_action -eq 0 ] && {
    applib_options_compare $app_name $app_res
    [[ $APP_NAME ]] && [[ $APP_RES ]] && {
      syslib_list $aic_list
      if [ $LIST_ACTION -eq 0 ]
      then
        APP_ARR=(${UNQ_ARR[@]})
        printf "  %-10s" 'app name:'
        printf " %-9s\n" $APP_NAME
        printf "  %-10s" 'aic res:'
        printf " %-9s\n" $APP_RES
        printf "  %-10s" 'aic list:'
        echo " ${APP_ARR[@]}"
        options_go=0
      fi
    }
  }	
}

applib_options_compare() {
  local apps_conf=()
  local apps
  local compare_action=0
  local option_name
  local option_res
  option_name=$1
  option_res=$2
  unset APP_NAME
  unset APP_RES
  applib_support_apps
  for i in ${SUPPORT_APPS[@]} ;{ 
    support_conf=(`echo $i | sed 's/_/ /g'`) # name+res
    support_name=${support_conf[0]} #  name
    unset support_conf[0]   #  remove name
    [[ "$option_name" == "$support_name" ]] && {
      APP_NAME=$option_name
      for j in ${support_conf[@]} ;{
        [[ $APP_RES ]] || APP_RES=`echo $j | grep $option_res`
      }
    }
  }
  if [[ $APP_NAME ]]
  then
    [[ ! $APP_RES ]] && echo "  unsupported app res: $option_res"
  else
    echo "  unsupported app name: $option_name"
  fi
}

applib_support_apps() {
  SUPPORT_APPS=(
  riptide_1560x720_1280x720
  kog_1560x720_1280x720
  aov_1560x720_1280x720
  tim_1280x720
  )
}

applib_support_info() {
  local app_info
  local app_name
  echo "  support conf"
  applib_support_apps
  for i in ${SUPPORT_APPS[@]} ;{
    app_info=(`echo $i | sed 's/_/ /g'`)
    app_name=${app_info[0]}
    unset app_info[0]
    echo "  name: `printf '%-9s' $app_name` res: `printf '%-9s' ${app_info[@]}`"
  }
}

riptide_play() {
  echo "  riptide action: play"
  [[ ${#APP_ARR[@]} -eq 0 ]] && APP_ARR=($@)
  riptide_action $APP_RES
  cmds_loop
}

kog_authorization() {
  echo "  kog action 0 -- authorize"
  [[ ${#APP_ARR[@]} -eq 0 ]] && APP_ARR=($@)
  kog_action0 $APP_RES
  cmds_loop
}

kog_account() {
  [[ ${#APP_ARR[@]} -eq 0 ]] && APP_ARR=($@)
  account_parse
  [ $ACCOUNT_YES -eq 0 ] && {
    echo "  kog action 1 -- account "
    kog_action1 $APP_RES
    #account_loop
    cmds_loop
  }
}

kog_play() {
  echo "  kog action 2 -- play"
  [[ ${#APP_ARR[@]} -eq 0 ]] && APP_ARR=($@)
  kog_action2 $APP_RES
  cmds_loop
}

kog_battlewatch() {
  echo "  kog action 4 -- battlewatch"
  [[ ${#APP_ARR[@]} -eq 0 ]] && APP_ARR=($@)
  kog_action4 $APP_RES
  cmds_loop
}

kog_return() {
  echo "  kog action 3 -- return"
  [[ ${#APP_ARR[@]} -eq 0 ]] && APP_ARR=($@)
  kog_action3 $APP_RES
  cmds_loop
}

aov_authorization() {
  echo "  aov action 0 -- authorize"
  [[ ${#APP_ARR[@]} -eq 0 ]] && APP_ARR=($@)
  aov_action0 $APP_RES
  cmds_loop
}

aov_login() {
  echo "  aov action 1 -- login"
  [[ ${#APP_ARR[@]} -eq 0 ]] && APP_ARR=($@)
  aov_action1 $APP_RES
  cmds_loop
}

aov_play() {
  echo "  aov action 2 -- play"
  [[ ${#APP_ARR[@]} -eq 0 ]] && APP_ARR=($@)
  aov_action2 $APP_RES
  cmds_loop
}

tim_authorization() {
  [[ ${#APP_ARR[@]} -eq 0 ]] && APP_ARR=($@)
  tim_action0 $APP_RES
  cmds_loop
}

tim_login() {
  [[ ${#APP_ARR[@]} -eq 0 ]] && APP_ARR=($@)
  account_parse
  [ $ACCOUNT_YES -eq 0 ] && {
    tim_action1 $APP_RES
    cmds_loop
  }
}

cmds_loop() {
  action_line=`echo "$ACTION" | wc -l`
  [ -e dstatus ] && sudo rm -rf dstatus
  touch dstatus
  for app in ${APP_ARR[@]} ;{
    echo "  android$app run ..."
    applib_perform $app &
    sleep 2
  }
  local dst
  while true
  do
    dst=`cat dstatus | grep android | wc -l`
    app_len=${#APP_ARR[@]}
    [ $dst -eq $app_len ] && echo " android cmds done." && break
    echo "  wait cmds done ..."
    sleep 2
  done
}

account_loop() {
  action_line=`echo "$ACTION" | wc -l`
  [ -e dstatus ] && sudo rm -rf dstatus
  touch dstatus
  for app in ${APP_ARR[@]} ;{
    echo "  android$app run ..."
    applib_perform $app
    sleep 2
  }
  local dst
  while true
  do
    dst=`cat dstatus | grep android | wc -l`
    app_len=${#APP_ARR[@]}
    [ $dst -eq $app_len ] && echo " android cmds done." && break
    echo "  wait cmds done ..."
    sleep 2
  done
}

applib_perform() {
  echo "$ACTION" | while read line
  do
    echo $line | grep test 2>&1 > /dev/null && line=${line}`date +%N|sed s/...$//`$1 && echo $line
    echo $line | grep account 2>&1 > /dev/null && {
      line=`echo $line | sed "s/account/${ACCOUNT_LIST[${1}]}/"`
      echo "  account: $line"
    }
    echo $line | grep passwd  2>&1 > /dev/null && {
      line=`echo $line | sed "s/passwd/${PASSWD_LIST[${1}]}/"`
      echo "  passwd:  $line"
    }

  docker exec android$1 /system/bin/sh -c "$line"
  echo "  status: $? --  cmd: docker exec android$1 /system/bin/sh -c \"${line}\""
  done
  echo android$1 >> dstatus
}

kog_account_snips() {
  case $1 in
    1280x720)
      ACTION=$(cat <<- EOF
  input tap xxx xxx
  input text account
  input tap xxx xxx
  input tap xxx xxx
  input text passwd
  input tap xxx xxx
  input tap xxx xxx

EOF
)
    ;;
    1560x720)
      ACTION=$(cat <<- EOF
  input tap xxx xxx
  input text account
  input tap xxx xxx
  input tap xxx xxx
  input text passwd
  input tap xxx xxx
  input tap xxx xxx
EOF
)
    ;;
  esac	
}

kog_login_account() {
  [[ ${#APP_ARR[@]} -eq 0 ]] && APP_ARR=($@)
  kog_account_snips $APP_RES
  cmds_loop
}



riptide_action() {
  case $1 in
    1280x720)
      ACTION=$(cat <<- EOF
  input tap 845 445
EOF
)
    ;;
    1560x720)
      ACTION=$(cat <<- EOF
  input tap 1062 443
EOF
)
    ;;
  esac

}

kog_action0() {
  case $1 in 
    1280x720)
      ACTION=$(cat <<- EOF
  input tap 700 480
  sleep 5
  input swipe 250 0 250 100
  sleep 5
EOF
)
    ;;
    1560x720)
      ACTION=$(cat <<- EOF
  input tap x1x xxx
  input tap x2x xxx
  input tap x3x xxx
  input tap x4x xxx
EOF
)
    ;;
  esac
}

kog_action1() {
  case $1 in 
    1280x720)
      ACTION=$(cat <<- EOF
  input tap 1200 120
  sleep 5
  input tap 835 175
  sleep 5
  input tap 780 600
  sleep 15
  input tap 300 180
  sleep 5
  input tap 1157 176
  sleep 5
  input text account
  sleep 5
  input tap 300 280
  sleep 5
  input tap 481 610
  input tap 1088 522
  input tap 1026 442
  input tap 785 440
  input tap 362 525
  input tap 90 688
  input tap 60 440
  input tap 180 440
  input tap 300 440
  input tap 420 440
  input tap 540 440
  input tap 666 440
  sleep 10
  input tap 600 380
  sleep 10
  input swipe 424 538 753 538
  sleep 5
  input swipe 424 538 751 538
  sleep 5
  input swipe 424 538 798 543
  sleep 5
  input swipe 424 538 810 538
  sleep 5
  input swipe 424 538 817 538
  sleep 5
  input swipe 424 538 765 538
  sleep 5
  input swipe 424 538 763 543
  sleep 5
  input swipe 424 538 760 538
  sleep 5
  input swipe 424 538 773 538
  #sleep 10
  #input tap 835 175
  #sleep 10
  #input tap 790 550

EOF
)
    ;;
    1560x720)
      ACTION=$(cat <<- EOF
  input tap x5x xxx
EOF
)
    ;;
  esac
}

kog_action2() {
  case $1 in 
    1280x720)
      ACTION=$(cat <<- EOF
  input tap 1200 120
  sleep 5
  input tap 835 175
  sleep 20
  input tap 640 560
  sleep 20
  input tap 666 580
  sleep 20
  input tap 1000 630
  sleep 20
  input tap 666 590
  sleep 20
  input tap 1200 120
  sleep 20
  input tap 1200 120
  sleep 20
  input tap 1200 120
  sleep 20
  input tap 1200 120
  sleep 10
  input tap 650 400
  sleep 20
  input tap 1048 146
EOF
)
    ;;
    1560x720)
      ACTION=$(cat <<- EOF
  input tap x9x xxx
  input tap x9x xxx
  input tap x9x xxx
  input tap x9x xxx
EOF
)
    ;;
  esac
}

kog_action3() {
  case $1 in
    1280x720)
      ACTION=$(cat <<- EOF
  input tap 720 545
  sleep 5
  input tap 633 551
  sleep 10
  input tap 633 580
  sleep 5
  input tap 1063 98
  sleep 5
  input tap 1049 144
EOF
)
    ;;
    1560x720)
      ACTION=$(cat <<- EOF
  input tap x9x xxx
EOF
)
    ;;
  esac
}

kog_action4() {
  case $1 in
    1280x720)
      #ACTION=$(cat <<- EOF
  #input tap 980 30
  #sleep 5
  #input tap 260 200
  #sleep 5
  #input tap 750 500
  #sleep 5
      ACTION=$(cat <<- EOF
  input tap 1020 40
  sleep 5
  input tap 790 210
  sleep 1
  input tap 780 520
  sleep 1
  input tap 521 521
EOF
)
    ;;
    1560x720)
      ACTION=$(cat <<- EOF
  input tap x9x xxx
EOF
)
    ;;
  esac


}

aov_action0() {
  case $1 in 
    1280x720)
      ACTION=$(cat <<- EOF
  input swipe 250 0 250 100
  #sleep 5
  #input keyevent 61
  #sleep 5
  #input keyevent 61
  #sleep 5
  #input keyevent 66
  #sleep 5
EOF
)
    ;;
  esac
}

aov_action1() {
  case $1 in
    1280x720)
      ACTION=$(cat <<- EOF
  input tap 666 333
  sleep 5
  input tap 666 620
  sleep 5
  input tap 70 680
  sleep 5
  input tap 720 680
  sleep 10
  input tap 280 520
  sleep 35
  input tap 160 315
  sleep 5
  input text test
  sleep 5
  input tap 1200 670
  sleep 5
  input tap 310 425
  sleep 5
  input tap 310 425
  sleep 15
  input tap 160 360
  sleep 10
  input tap 480 630
  sleep 10
EOF
)
    ;;
  esac
}

aov_action2() {
  case $1 in
    1280x720)
     ACTION=$(cat <<- EOF
  input tap 271 509
  sleep 2	
EOF
)	
    ;;
  esac


}

tim_action0() {
  case $1 in
    1280x720)
      ACTION=$(cat <<- EOF
  input tap 468 803
  sleep 10
  input swipe 400 900 200 900
  sleep 5
  input swipe 400 900 200 900
  sleep 5
  input tap 360 1080
  sleep 10
  input tap 472 777
  sleep 5
  input keyevent 61
  sleep 5
  input keyevent 61
  sleep 5
  input keyevent 66
  sleep 5
  input keyevent 66
  sleep 5
  input tap 360 740
  sleep 15
	
EOF
)	
    ;;
  esac
}

tim_action1() {
  case $1 in
    1280x720)
      ACTION=$(cat <<- EOF
  input tap 360 510
  sleep 3
  input text account
  sleep 3
  input tap 665 1144
  sleep 3
  input text passwd
  sleep 3
  input tap 355 590
  sleep 10
EOF
)
    ;;
  esac
}

applib_app_go() {
  applib_options $@
  if [ $options_go -eq 0 ]
  then
    case $APP_NAME in	
        riptide)
        riptide_play
      ;;
      kog)
        #kog_authorization #authorization & update
        #kog_account
        #kog_play
        #kog_return
        kog_battlewatch
      ;;
      aov)
        #aov_authorization
        #aov_login
        aov_play
      ;;
      tim)
        tim_authorization
        tim_login
      ;;
    esac
  fi
}

aapt_check() {
  echo "  AAPT by default: $AAPT"
  [[ $AAPT ]] && {
    [ -x $AAPT ] && {
      AAPT_CHECK=0
    } || {
      AAPT_CHECK=1
      echo "  $AAPT can't be exectuted"
    }	
  } || {
    echo "  no aapt define, finding it ..."
    AAPT_ARR=(`find / -name aapt 2>/dev/null`)
    [[ ${AAPT_ARR[0]} ]] && {
      echo "  aapt tool: ${AAPT_ARR[0]}"
      AAPT=${AAPT_ARR[0]}
      [ -x $AAPT ] && {
        AAPT_CHECK=0
      } || {
        AAPT_CHECK=1
        echo "  $AAPT can't be executed"
      }
    } || {
      AAPT_CHECK=1
      echo "  can't find appt tool"
    }
  }
}

account_parse() {
  ACCOUNT_CHECK=0
  [[ $ACCOUNT_FILE ]] && {
  [ -s $ACCOUNT_FILE ] && {
      ACCOUNT_CHECK=0
      echo "  account file: $ACCOUNT_FILE"
    } || {
      ACCOUNT_CHECK=1
      echo "  $ACCOUNT_FILE doesn't exist or its size is zero"
    }

  } || {
    ACCOUNT_CHECK=1
    echo "  no specific account_file"
  }
	
  [ $ACCOUNT_CHECK -eq 0 ] && {
    ACCOUNT_LIST=(`cat $ACCOUNT_FILE | awk '{print $1}'`)
    PASSWD_LIST=(`cat $ACCOUNT_FILE | awk '{print $2}'`)
    [ ${#ACCOUNT_LIST[@]} -eq ${#PASSWD_LIST[@]} ] && {
      ACCOUNT_YES=0
    } || {
      ACCOUNT_YES=1
    }
  }
}

apk_service() {
  [[ $APK_SERVIER ]] || {
    PKG_NAME=""
    MAIN_ACT=""
    aapt_check 
    if [ $AAPT_CHECK -eq 0 ]
    then
      PKG_NAME=`$AAPT d badging $COMPLETE_APK | grep "^package: name=" | awk -F "'" '{print $2}'`
      echo "  PKG_NAME: $PKG_NAME"
      MAIN_ACT=`$AAPT d badging $COMPLETE_APK | grep "^launchable-activity:" | awk -F "'" '{print $2}'`
      echo "  MAIN_ACT: $MAIN_ACT"
      APK_SERVIER=$PKG_NAME/$MAIN_ACT
    fi
  }
}

apk_check() {
  AIC_ARR=()
  APK_CHECK_ACTION=0
  [ -s $APK_PATH ] && {
    syslib_list $AIC_LIST
    if [ $LIST_ACTION -eq 0 ]
    then
      AIC_ARR=(${UNQ_ARR[@]})
      apk_parse
    fi		
  } || {
    echo "  file:$APK_PATH does not exist or its size is zero"
    let APK_CHECK_ACTION=1
  }
}

apk_parse() {
  APK_NAME=""
  COMPLETE_FOLDER_PATH=""
  [[ $APK_PATH ]] && COMPLETE_APK=$APK_PATH
  APK_NAME=`echo $COMPLETE_APK | sed -r 's=^.*/(.*).apk=\1.apk='`
  COMPLETE_FOLDER_PATH=`echo $COMPLETE_APK | sed -r "s=/$APK_NAME=="`
}

intall_options() {
  echo "> install_options $@"
  OPTION_ACTION=0
  AIC_LIST=()
  APK_PATH=""
  ARMABI=""

  INSTALL_OPTIONS=$(cat <<- EOF
  usage:
    -p [path] -l [list]
    -apk -p [path] -l [list]
    -apk -abi [version] -p [path] -l [list] 

    -p /home/media/aov/aov.apk -l 0-15
    -apk -p /home/media/riptide.apk -l 0,1,4,10-15
    -apk -abi armeabi-v7a -p /home/media/xxx.apk -l 0-15
	
EOF
)
  [ $# -ge 4 ] && {
    while [ $# -gt 0 ] 
    do
      case $1 in
        -abi)
          [ $# -lt 2 ] && echo "  wrong option, need -abi [version] (-abi armeabi-v7a)" && let OPTION_ACTION=1 && break
          ARMABI="$2"
          shift
          shift
        ;;
        -apk)
          isAPK=0
          shift
        ;;
        -l)
          [ $# -lt 2 ] && echo "  wrong option, need -l [list] (-l 0-14 or -n 1,3,4-8)" && let OPTION_ACTION=1 && break
          AIC_LIST=$2
          shift
          shift
        ;;
        -p)
          [ $# -lt 2 ] && echo "  wrong option, need -p [path] (-p /home/sample.apk)" && let OPTION_ACTION=1 && break
          APK_PATH=$2 
          shift
          shift
        ;;
        *)
          let OPTION_ACTION=1
          echo "  unsupported options: $@"
          echo "$INSTALL_OPTIONS"
          break
        ;;
      esac
    done
    if [ $OPTION_ACTION -eq 0 ]
    then
      apk_check
      if [ $APK_CHECK_ACTION -eq 0 ]
      then
        apk_service
        [[ $APK_SERVIER ]] && {
          [ -e istatus ] && sudo rm -rf istatus
          touch istatus
          for i in ${AIC_ARR[@]} ;{
            install_apk $i &
            sleep 1
            echo
          }
          local ist
          while true
          do
            ist=`cat istatus | grep android | wc -l`
            if [ $ist -eq ${#AIC_ARR[@]} ]
            then
              echo "  android install done, please check `pwd`/istatus"
              echo "  remove apk package ..."
              for i in ${AIC_ARR[@]} ;{
                sudo rm -rf  $AIC_DIR/workdir/data$i/media/0/$APK_NAME
              }
              break
            fi
            echo "  wait install done ..."
            sleep 5
          done
        }
      fi
    fi	
  } || {
    echo "  needs >= 4 parameters, but has $#"
    echo "$INSTALL_OPTIONS"
  }
}


install_apk() {
  echo "  install $APK_NAME for android$1 ..."
  echo "  copy $COMPLETE_APK to $AIC_DIR/workdir/data$1/media/0/"
  sudo cp -r $COMPLETE_APK $AIC_DIR/workdir/data$1/media/0/
  if [[ ! $isAPK ]]
  then
    echo "  cp -r $COMPLETE_FOLDER_PATH/$PKG_NAME $AIC_DIR/workdir/data$1/media/obb"
    sudo cp -r $COMPLETE_FOLDER_PATH/$PKG_NAME $AIC_DIR/workdir/data$1/media/obb/
  fi
  [[ $ARMABI ]] && arm_cmds="--abi $ARMABI" || arm_cmds=""
  apkcmds="pm install $arm_cmds /data/media/0/$APK_NAME"
  echo "  docker exec android$1 /system/bin/sh -c \"$apkcmds\""
  docker exec android$1 /system/bin/sh -c "$apkcmds"
  echo "android$1 install $?" >> istatus
}

start_options() {
  echo "> start_options $@"
  START_USAGE=$(cat <<- EOF
  usage:
   -p [path] -l [list]

   -p /home/media/kog.apk -l 0-15
EOF
) 
  START_ACTION=0
  [ $# -eq 4 ] && {
    while [ $# -gt 0 ]
    do
      case $1 in
        -p)
          [ $# -lt 2 ] && echo "  wrong option, need -p [path] (-p /home/sample.apk)" && let START_ACTION=1 && break
          APK_PATH=$2 
          shift
          shift
        ;;
        -l)
          [ $# -lt 2 ] && echo "  wrong option, need -l [list] (-l 0-14 or -n 1,3,4-8)" && let START_ACTION=1 && break
          AIC_LIST=$2
          shift
          shift
        ;;
        *)
          echo "  unsupported options:"
          echo "$START_USAGE"
          let START_ACTION=1
          break
        ;;
      esac
    done
  } || {
    echo "  need 4 parameters, but $#"
    let START_ACTION=1
    echo "$START_USAGE"
  }

  if [ $START_ACTION -eq 0 ]
  then
    apk_check
    if [ $APK_CHECK_ACTION -eq 0 ]
    then
      apk_service
      [[ $APK_SERVIER ]] && {
        [ -e sstatus ] && sudo rm -rf sstatus
        touch sstatus
        for i in ${AIC_ARR[@]} ;{
          start_apk $i &
          sleep 1
          echo
        }
        local sst
        while true
        do
          sst=`cat sstatus | grep android | wc -l`
          if [ $sst -eq ${#AIC_ARR[@]} ]
          then
            echo "  apk start done, please check `pwd`/sstatus"
            break
          fi
          echo "  wait start done ..."
          sleep 5
        done
      }
    fi
  fi		
}

start_apk() {
  echo " starting $APK_SERVIER for android$1 ..."
  start_cmds="am start -S -W $APK_SERVIER"
  echo "  docker exec android$1 /system/bin/sh -c \"$start_cmds\""
  docker exec android$1 /system/bin/sh -c "$start_cmds"
  echo "android$1 install $?" >> sstatus
}

stop_app() {
  echo "> stop_app $@"
  STOP_USAGE=$(cat <<- EOF
  usage:
    -n [name] -l [list]

    kog -- tmgp
    aov -- ngame

    -n kog -l 0-7
EOF
)
  declare -A app_dict=( [kog]="tmgp" [aov]="ngame")

  [ $# -eq 4 ] && {
    while [ $# -gt 0 ]
    do
      case $1 in
        -n)
          APP_NAME=$2
          shift
          shift
        ;;
        -l)
          AIC_LIST=$2
          shift
          shift
        ;;
        *)
          echo "  unsupported options:"
          echo "$STOP_USAGE"
          break
        ;;
      esac
    done

    [[ $APP_NAME ]] && [[ $AIC_LIST ]] && {
      syslib_list $AIC_LIST
      [ $LIST_ACTION -eq 0 ] && {
        app_name=${app_dict[$APP_NAME]}
        [[ $app_name ]] && {
          AIC_ARR=(${UNQ_ARR[@]})
          for i in ${AIC_ARR[@]} ;{
            for j in {0..2} ;{
              app_pid=(`docker exec -it android$i sh -c 'ps -ef' | grep $app_name | awk '{print $2}'`)
              [ ${#app_pid[@]} -gt 0 ] && {
                docker exec -it android$i sh -c "kill -9 ${app_pid[@]}"
              } || {
                echo "  android$i:$app_name was killed"
                break
              }
            }
          }
        }
      }
    }
  } || {
    echo "  unsupported options"
    echo "$STOP_USAGE"
  }
}


capture_screen() {
  docker exec android${1} /system/bin/sh -c "screencap -p /sdcard/android${1}.png"
}

getscreen() {
  echo "> getscreen $@"
  GETSCREEN_ACTION=0
  [ $# -ge 1 ] && {
    syslib_list $@
    if [ $LIST_ACTION -ne 0 ]
    then
      let GETSCREEN_ACTION=1
      echo "  aic list parsed unsuccessfully"
    else
      AIC_ARR=(${UNQ_ARR[@]})
      for i in ${AIC_ARR[@]} ;{
        echo "  capture screen for android$i ($AIC_DIR/workdir/data${i}/media/0/android${i}.png ...)"
        capture_screen $i &
        #capture_screen $i
        sleep 0.2
      }
    fi
  } || {
    echo "  need aic num or list"
  }
}

mvscreen() {
  echo "> mvscreen $@"
  MVSCREEN_ACTION=0
  if [ $# -ge 1 ]
  then
    syslib_list $@
    if [ $LIST_ACTION -ne 0 ]
    then
      let MVSCREEN_ACTION=1
      echo "  aic list parsed unsuccessfully"
    else
      AIC_ARR=(${UNQ_ARR[@]})
      timestamp=`date +%m%d-%H%M%S`
      SCREEN_DIR="screen-${timestamp}"
      mkdir -p $SCREEN_DIR
      for i in ${AIC_ARR[@]} ;{
        sudo mv $AIC_DIR/workdir/data${i}/media/0/android${i}.png $SCREEN_DIR 2>/dev/null
      }
      sleep 1
      sudo chown $NORMAL_USER:$NORMAL_USER -R $SCREEN_DIR
      ls -rtl $SCREEN_DIR | while read line; do echo "  $line" ;done
      echo "  screen path: $SCREEN_DIR"
    fi
  else
    echo "  need aic num or list"
  fi
}

remote_screen() {
  scp -r $SCREEN_DIR $REMOTE_USER@$REMOTE_IP:$REMOTE_DIR/
  echo "  remote screen: $REMOTE_USER@$REMOTE_IP:$REMOTE_DIR/`echo "$SCREEN_DIR" | awk 'BEGIN {FS="/"} {print $NF}'`"
}

check_fps() {
  echo "> check fps $@"
  [ $# -ge 1 ] && {
    syslib_list $@
    [ $LIST_ACTION -ne 0 ] && {
      echo "  aic list parsed unsuccessfully"
    } || {
      [ -e ./fps ] && sudo rm -rf ./fps
      mkdir -p ./fps
      cd ./fps
      AIC_ARR=(${UNQ_ARR[@]})
      [ -s total.txt ] && rm total.txt
      printf "%-15s %-6s %-6s %-6s\n" "name" "min" "max" "avg" | tee total.txt
      for i in ${AIC_ARR[@]} ;{
       surface_pid=`docker exec android${i} sh -c "ps -ef | grep surface | grep -v grep " | awk '{print $2}'`
       android_ui=`docker exec android${i} sh -c "ps -ef | grep com.android.systemui | grep -v grep" | awk '{print $2}'`
       android_fps $i $surface_pid $android_ui
      }
      [ -s total.txt ] && fps_total total.txt | tee -a total.txt
    }
  }
}

android_fps() {
  docker exec android${1} sh -c  "logcat -d" | grep -i fps | awk -v v1=$2 -v v2=$3 '/fps/ && $3 != v1 && $3 != v2 {print $NF}' | tail -n20 > android${1}.txt
  fps_android $1 android${1}.txt | tee -a total.txt
}

fps_android() {
  aic_id=$1
  aic_file=$2
  /bin/awk -v name=android${aic_id} '
  {
    sum += $1
  }
    NR == 1 {
    min = $1
    max = $1
  }

  NR > 1 {
    max = max > $1 ? max : $1
    min = min < $1 ? min : $1
  }
  END {
    printf("%-15s %-6.2f %-6.2f %-6.2f\n", name"(/"NR")",min,max,sum/(NR))
  }
  ' < ${aic_file}
}

fps_total() {
  /bin/awk '
    NR >= 2 {
      min_sum += $2
      max_sum += $3
      avg_sum += $4
    }
    END {
      printf("%-15s %-6.2f %-6.2f %-6.2f\n", "avg(/"NR-1")", min_sum/(NR-1),max_sum/(NR-1),avg_sum/(NR-1))
    }
  ' < $1
}

check_aic() {
  echo "> check aic $@"
  [ $# -ne 0 ] && {
    syslib_list $@
    [ $LIST_ACTION -eq 0 ] && {
       AIC_ARR=(${UNQ_ARR[@]})
       for i in ${AIC_ARR[@]} ;{
        printf "  %-10s %-s " android${i}
        echo `docker exec -it android$i getprop dev.bootcomplete 2>/dev/null`       
       }
    }
  } || {
    echo "  need aic number"
  }
}


mix_xml() {
  for ((i=0;i<=loop;i++)) ;{
    echo "  loop: $i"
    let inx=i*NODE_NUM
    for ((j=0;j<NODE_NUM;j++)) ;{
      let cnum=inx+j
      [ $cnum -lt $intd ] || [ $indx -gt $j ] && {
        echo "<android$cnum @vnode=\"$j\" @rnode=\"$j\" ro.boot.icr.internal=\"1\" />" | tee -a acg-$INSTANCE_NUM.xml
      } 
    }
  }
}

seq_xml() {
  n_d=0
  for ((i=0;i<=NODE_NUM;i++)) ;{
    echo "  loop: $i"
    let inx=i*loop
    [ $n_d -eq $NODE_NUM ] && n_d=0
    for ((j=0;j<loop;j++)) ;{
      let cnum=inx+j
      [ $cnum -ge $INSTANCE_NUM ] && break
      echo "<android$cnum @vnode=\"$n_d\" @rnode=\"$n_d\" ro.boot.icr.internal=\"1\" />" | tee -a acg-$INSTANCE_NUM.xml
    }
    let n_d++
  }
}

xml() {
  XML_USAGE=$(cat <<- EOF
  -i INSTANCE_NUM (INSTANCE_NUM >= NODE_NUM)
  -n NODE_NUM
  -t XML_TYPE
    0 -- mix
    1 -- seq

  usage:
    xml -i 15 -n 3 -t 0
    xml -i 10 -n 2 -t 1
EOF
)
  [ $# -eq 6 ] && {
    while [ $# -gt 0 ]
    do
      case $1 in 
        -i)
          INSTANCE_NUM=$2
          shift
          shift
        ;;
        -n)
          NODE_NUM=$2
          shift
          shift
        ;;
        -t)
          XML_TYPE=$2
          shift
          shift
        ;;
        *)
          echo "$XML_USAGE"
          break
        ;;
      esac
    done
  
    [ $INSTANCE_NUM -lt $NODE_NUM ] && {
      XML_CHECK=1
      echo "  instance num needs to be greater than node num"
    } || {
      [ $INSTANCE_NUM -gt 0 ] && {
        let loop=INSTANCE_NUM/NODE_NUM
        let indx=INSTANCE_NUM%NODE_NUM
        let intd=loop*NODE_NUM
        case $XML_TYPE in 
          0)
            mix_xml
          ;;
          1)
            seq_xml
          ;;
          *)
            echo "  only support 0 or 1 for xml_type"
        esac
        echo
      } || {
          echo "  instance num must be > 0"
      }
    }
  } || {
    echo "$XML_USAGE"
  }
}

docker_numastat() {
  [ $# -eq 2 ] && {
    docker_name=$1
    shim_arr=(`docker ps 2> /dev/null | grep $docker_name | awk '{print $1}'`)
    shim_name=${shim_arr[0]}
    [[ $shim_name ]] && {
      shim_pid=`ps aux | grep $shim_name | grep -v grep | awk 'NR==1 {print $2}'`
      cpus="`docker inspect --format='{{.HostConfig.CpusetCpus}}' $docker_name`"
      mems="`docker inspect --format='{{.HostConfig.CpusetMems}}' $docker_name`"
      cgroup_pids=(`cat /sys/fs/cgroup/memory/docker/${shim_name}*/cgroup.procs`)
      log_file=$2/${docker_name}_numa.txt
      echo "  `date` shim|pid: ${shim_name}|${shim_pid}" > ${log_file}
      numastat -p $shim_pid >> ${log_file}
      shim_mem=(`cat ${log_file} | tail -n1 | awk '/^Total/ {sub("Total","");print}'`)
      echo "  `date` docker|pids: ${docker_name}|${cgroup_pids[@]}" >> ${log_file}
      numastat -p ${cgroup_pids[@]} >> ${log_file}
      docker_mem=(`cat ${log_file} | tail -n1 | awk '/^Total/ {sub("Total","");print}'`)
    }
  }
}

single_docker_numastat() {
  [ $# -eq 1 ] && {
    numa_title=(`numastat | head -n1` total)
    printf "  %-15s %-20s %-20s" "name" "cpus" "mems" 
    printf " %-20s" ${numa_title[@]} 
    echo 
    docker_numastat $1 docker_numa_s
    printf "  %-15s %-20s %-20s" $docker_name $cpus $mems 
    printf " %-20s" ${docker_mem[@]} 
    echo
    echo
    printf "  %-36s %-20s" "docker-shim[docker]" "cpus"
    printf " %-20s" ${numa_title[@]}
    echo 
    shimcpus=(`ps -eLo pid,lwp,psr | awk '$1 == shimpid && $2 == shimpid {print $3}' shimpid=$shim_pid`)
    printf "  %-36s %-20s" "${shim_name}[${docker_name}]" $shimcpus 
    printf " %-20s" ${shim_mem[@]} 
    echo 
  }
}

group_docker_numastat() {
  docker_arr=(`docker ps 2> /dev/null | awk 'NR > 1 {print $1"_"$NF}'`)
  numa_title=(`numastat | head -n1` total)
  printf "  %-15s %-20s %-20s" "name" "cpus" "mems" 
  printf " %-20s" ${numa_title[@]} 
  echo 
  for i in ${docker_arr[@]} ;{
    docker_name=${i#*_}
    shim_name=${i%_*}
    docker_numastat $docker_name docker_numa_g
    printf "  %-15s %-20s %-20s" $docker_name $cpus $mems 
    printf " %-20s" ${docker_mem[@]} 
    echo 
  }
  sum_arr=(`cat docker_numa_g/sum.txt | awk '/name/,/docker-shim/' | awk '/name/ || /shim/ || /aic/ {next} {f+=$4;s+=$5;c+=$6} END{print f,s,c}'`)
  printf "  %-15s %-20s %-20s" "total" "without" "aic-manager" | tee -a docker_numa_g/sum.txt
  printf " %-20s" ${sum_arr[@]} | tee -a docker_numa_g/sum.txt
  echo | tee -a docker_numa_g/sum.txt
  printf "  %-36s %-20s" "docker-shim[docker]" "cpus" 
  printf " %-20s" ${numa_title[@]} 
  echo 
  for i in ${docker_arr[@]} ;{
    docker_name=${i#*_}
    shim_name=${i%_*}
    docker_numastat $docker_name docker_numa_g
    shimcpus=(`ps -eLo pid,lwp,psr | awk '$1 == shimpid && $2 == shimpid {print $3}' shimpid=$shim_pid`)
    printf "  %-36s %-20s" "${shim_name}[${docker_name}]" $shimcpus 
    printf " %-20s" ${shim_mem[@]}
    echo 
  }
}

group_docker_output() {
  mkdir -p docker_numa_g
  group_docker_numastat | tee docker_numa_g/sum.txt
}
single_docker_output() {
  mkdir -p docker_numa_s
  single_docker_numastat $1 | tee docker_numa_s/sum.txt
}

applib() {
  APPLIB_USAGE=$(cat <<- EOF
  support options:
    install -- install apk, see install --help
    run     -- run app cmds, see run --help
    start   -- start app, see start --help
    stop    -- stop app
    aic     -- check aic boot status
    fps     -- collect fps info
    screen  -- capture screen 
    rscreen -- remote screen
    xml     -- aic xml config generator, see xml --help
    numa    -- show cpu and numa allocation for docker
            -- group             eg. numa group      -- show running instances cpu and mem allocation
            -- single doker      eg. numa android0   -- show android0
EOF
)
  case $1 in
    install)
      shift
      intall_options $@
    ;;
    run)
      shift
      applib_app_go $@
    ;;
    start)
      shift
      start_options $@
    ;;
    stop)
      shift
      stop_app $@
    ;;
    fps)
      shift
      check_fps $@
    ;;
    screen)
      shift
      getscreen $@
      sleep 5
      mvscreen $@
    ;;
    rscreen)
      shift
      getscreen $@
      sleep 2
      mvscreen $@
      sleep 2
      remote_screen
    ;;
    aic)
      shift
      check_aic $@
    ;;
    xml)
      shift
      xml $@
    ;;
    numa)
      shift
      [ $# -eq 1 ] && {
        case $1 in 
          group)
            group_docker_output
          ;;
          *)
            single_docker_output $1
          ;;
        esac
      } 
    ;;
    *)
      echo "$APPLIB_USAGE"
    ;;
  esac
}	
			
#################################app\>#########################################

#################################<collect#########################################

colib_i915_usage() {
  syslib_root_access
  [[ ${PCI_ARR[@]} ]] || syslib_card_id
  local options_arr=($@)
  mkdir -p i915_usage
  cd i915_usage
  local c=0
  local metrics_arr
  i915_usage_arr=()
  export LD_LIBRARY_PATH=$LD_LIBRARY:$LD_LIBRARY_PATH
  echo "  starting metrics monitor for gpu node ..."
  for i in ${PCI_ARR[@]} ;{
      gpu_id=$BUS_PATH$i
      [ -e $gpu_id/drm/render* ] && {
        render_dev=`ls -d $gpu_id/drm/render* | awk -F / '{print $NF}'`
        ${LD_LIBRARY}metrics_monitor -d /dev/dri/$render_dev > $render_dev.txt &
        metrics_arr[c]=$!
        i915_usage_arr[c]=$render_dev
        let c++
        :
      }
  }
  echo "  wait for ${COL_SEC}s to collecte the data ..."
  syslib_second $COL_SEC
  echo "  collecting done, stop the metrics monitor ..."
  for i in ${metrics_arr[@]} ;{
    sudo kill -9 $i > /dev/null
  }
  sleep 2
  printf "%-23s %-15s %-15s %-15s %-15s %-15s\n" "  -----" "Render_Usage"  "Video_Usage" "Video_E_Usage" "Video2_Usage" "GT_Freq" | tee sum.txt
  for i in ${i915_usage_arr[@]} ;{
    logname=${i}.txt
    sed -i '$d' $logname
    colib_i915_parse $logname > $i-c.txt
    echo "  ${i}_`awk '/avg/ {print }' $i-c.txt`" | tee -a sum.txt
  }

  sudo chown $NORMAL_USER:$NORMAL_USER -R ../i915_usage
  echo "  log path: `pwd`"
}

colib_i915_parse() {
  /usr/bin/awk '
    BEGIN { printf ("%-10s %-15s %-15s %-15s %-15s %-15s\n", " ","Render_Usage", "Video_Usage", "Video_E_Usage", "Video2_Usage", "GT_Freq") }
    NF == 15 {gsub(",","");printf ("%-10s %-15s %-15s %-15s %-15s %-15s\n"," ",$3,$6,$9,$12,$15)}
    {
      render_usage+=$3
      video_usage+=$6
      video_e+=$9
      video_2+=$12
      gt_freq+=$15
    }
    END { 
      avg_render=render_usage/NR
      avg_video=video_usage/NR
      avg_video_e=video_e/NR
      avg_video_2=video_2/NR
      avg_gt_freq=gt_freq/NR
      printf ("%-10s %-15s %-15s %-15s %-15s %-15s\n", "avg(/"NR")",avg_render,avg_video,avg_video_e,avg_video_2,avg_gt_freq) 
  }
  ' < $1 
}

col_test() {
  echo "  col_test, COL_SEC=$COL_SEC"
}

col_free_usage() {
  [[ "$FREE_SEC" ]] && [[ "$FREE_COUNT" ]] && [[ "$FREE_RAW_DATA" ]] && {
  mkdir -p free_usage
  cd free_usage
  echo "  starting free collection ..."
  free -m -w -s $FREE_SEC -c $FREE_COUNT > $FREE_RAW_DATA &
  sleep $((FREE_SEC*FREE_COUNT))
  col_free_parse -r $FREE_RAW_DATA -p $FREE_PLOT_DATA -n $FREE_CHART_NAME -s $FREE_PLOT_SCRIPT -t "$FREE_CHART_TITLE"

  sudo chown $NORMAL_USER:$NORMAL_USER -R ../free_usage
  echo "  log path: `pwd`"
  } || {
    echo "  parameters are not been given value."
    echo "  FREE_SEC=$FREE_SEC"
    echo "  FREE_COUNT=$FREE_COUNT"
    echo "  FREE_RAW_DATA=$FREE_RAW_DATA"
  }
}

col_free_parse() {
  [ $# -ge 2 ] && {
    while [ $# -gt 0 ]
    do
      case $1 in
        -r)
          free_raw_data=$2
          FP_CHECK=0
          shift
          shift
        ;;
        -p)
          free_plot_data=$2
          FP_CHECK=0
          shift
          shift
        ;;
        -n)
          free_chart_name=$2
          FP_CHECK=0
          shift
          shift
        ;;
        -t)
          free_chart_title="$2"
          FP_CHECK=0
          shift
          shift
        ;;
        -s)
          free_plot_script=$2
          FP_CHECK=0
          shift
          shift
        ;;
        *)
          echo "  unsupported options: $@"
          FP_CHECK=1
          break
        ;;
      esac
      :
    sleep 1
    done
  }

  [[ "$free_raw_data" ]] || free_raw_data=$FREE_RAW_DATA
  [[ "$free_plot_data" ]] || free_plot_data=$FREE_PLOT_DATA
  [[ "$free_chart_name" ]] || free_chart_name=$FREE_CHART_NAME
  [[ "$free_chart_title" ]] || free_chart_title=$FREE_CHART_TITLE
  [[ "$free_plot_script" ]] || free_plot_script=$FREE_PLOT_SCRIPT

  [[ "$free_raw_data" ]] && [[ "$free_plot_data" ]] && [[ "$free_chart_name" ]] && [[ "$free_chart_title" ]] && [[ "$free_plot_script" ]] && [ $FP_CHECK -eq 0 ] && {
    awk '/Mem/ {$1="";print $0}' $free_raw_data > $free_plot_data
    free_xrange=`awk 'END{print NR}' $free_plot_data`
    plot_cmds=$(cat <<- EOF
set term png
set output "$free_chart_name"
set title "${free_chart_title[@]}"
set xlabel "sec(s)"
set ylabel "megabytes"
set key right outside
set xrange [0:$free_xrange]
file="$free_plot_data"
plot file u 1 t 'total' w lp ls 9, \
file u 2 t 'used' w l ls 1, \
file u 3 t 'free' w l ls 2, \
file u 4 t 'shared' w l ls 3, \
file u 5 t 'buff' w l ls 4, \
file u 6 t 'cache' w l ls 5, \
file u 7 t 'avai' w l ls 7
EOF
)
    echo "$plot_cmds" > $free_plot_script
    chmod +x $free_plot_script
    [ -x /usr/bin/gnuplot ] && ./$free_plot_script || echo "  please install gnuplot firstly!"
  }
}

col_sec() {
  case `syslib_int_num $@` in
    0)
      COL_SEC=$1
    ;;
    1)
      COL_SEC=30
    ;;
    *)
      syslib_int_num $@
      COL_SEC=-1
    ;;
  esac
}

colib() {
  COLIB_USAGE=$(cat <<- EOF
  support options:
    gpu [sec|30]  -- monitor the usage of gpu node(s), run sec=30s by default.
    free          -- monitor the status of free


    usage:
      gpu      -- run 30s 
      gpu 60   -- run 60s
      free

EOF
)

  case $1 in 
    gpu)
      shift
      col_sec $@
      [ $COL_SEC -gt 0 ] && colib_i915_usage
    ;;
    free)
      shift
      envfree
      col_free_usage
    ;;
    *)
      echo "$COLIB_USAGE"
    ;;
  esac
}

#################################collect\>#########################################

#################################<main#########################################
main() {
  MAIN_USAGE=$(cat <<- EOF
  support options:
    show [args]
          sort      --   convert string to list
          ip        --   show ip address
          iommu     --   show iommu group info
          task      --   show threads and tasks info
          gpu       --   show gpu info
          cgame     --   show device_id of cloudgame
          dir       --   show the difference of dir

    set  [args] 
          vim       --   set conf of vim (1 tab == 2 space, enable autoindent)
          service   --   disable firewalld/libvirtd (support centos)
          loglevel  --   enable the highest level for kernel
          journal   --   enable persistent store the log on disk
          eth       --   enable eth
          logi915   --   capture i915 log backstage
          gpu       --   fix freq for gpu
          pin       --   pin cpu for process

    tool [args]
          install   --   install tool (support docker/gnuplot) 
          remove    --   remove tool  (support docker/gnuplot)

    vm   [args]
          sw        --   install qemu package and sw requirements
          build     --   build vm for reference
          boot      --   boot up the vm

    app  [args]
          install   --   install apk (see install --help)
          start     --   start app   (see start --help)
          stop      --   stop app
          run       --   run app     (see run --help)
          screen    --   capture screens of aic on local machine
          rscreen   --   send the screens captured to remote machine
          fps       --   collect fps info (max, min, ave)
          aic       --   check aic boot status( 1 is done)
          xml       --   aic xml config generator (see xml --help)
          numa      --   show cpu and numa allocation for docker
                    --   group             eg. numa group      -- show running instances cpu and mem allocation
                    --   single doker      eg. numa android0   -- show android0
    col  [args]
          gpu       -- monitor the usage of gpu node(s)
          free      -- monitor the status of mem(free)
EOF
)

[ $# -gt 1 ] && {
    envlib
    case $1 in
      show)
        shift
        syslib $@
      ;;
      set)
        shift
        setlib $@
      ;;
      tool)
        shift
        syslib_root_access
        toollib $@
      ;;
      vm)
        shift
        syslib_root_access
        envqemu
        qemulib $@
      ;;
      app)
        shift
        envaic
        applib $@
      ;;
      col)
        shift
        colib $@
      ;;
      *)
        echo "$MAIN_USAGE"
      ;;
    esac
    :
  } || {
    echo "$MAIN_USAGE"
  }    
}

main $@
#################################main\>#########################################

