#!/bin/bash
[[ $1 ]] && log_dir=$1 || log_dir=`date +%H%M%S-%m%d`
[[ $2 ]] && INTER=$2 || INTER=1
[[ $3 ]] && COUNT=$3 || COUNT=300
SARCOUNT=$COUNT

SEP_DIR=/opt/intel/sep
TEST_DIR=test-data
EMON_CONFIG_DIR=/home/cloud/work/emon/icx-emon/ICX-2S
EVENTS_LIST=icx-2s-events.txt
EMON_EDP=edp.rb
EMON_PROC=process.cmd
NUSER=cloud

mkdir -p ${TEST_DIR}/${log_dir}
cp ${EMON_CONFIG_DIR}/* ${TEST_DIR}/${log_dir}
cp $0 ${TEST_DIR}/${log_dir}
cp $EMON_EDP ${TEST_DIR}/${log_dir}
cp $EMON_PROC ${TEST_DIR}/${log_dir}


for i in {1..5} ;{
	echo -ne "delay $i[5]\r"
	sleep 1
}

echo "go to test dir: ${TEST_DIR}/${log_dir}"
cd ${TEST_DIR}/${log_dir}

echo "collect system info..."
cp /boot/config-`uname -r` .
cat /etc/issue > sysinfo.txt
#echo "kernel" >> sysinfo.txt
#uname -a >> sysinfo.txt

echo "free -g" >> sysinfo.txt
free -g >> sysinfo.txt

echo "fdisk -l" >> sysinfo.txt
fdisk -l >> sysinfo.txt

echo "df -h" >> sysinfo.txt
df -h >> sysinfo.txt

echo "" >> sysinfo.txt

echo "CPUINFO"
cat /proc/cpuinfo >> cpuinfo.txt

echo "MEMINFO"
cat /proc/meminfo >> meminfo-before.txt

echo "NUMACTL"
numactl --hardware > numactl-before.txt

echo "huge-page"
ls /sys/kernel/mm/*/enabled >> huge-page.txt
ls /sys/kernel/mm/*/enabled | xargs cat >> huge-page.txt
ls /sys/kernel/mm/*/defrag >> huge-page.txt
ls /sys/kernel/mm/*/defrag | xargs cat >> huge-page.txt

echo "lspci"
lspci > lspci.txt

echo "dmidecode"
dmidecode > dmidecode.txt

echo "ethinfo"
ip link > ethinfo.txt

for nic in `ip link | awk '/: </ && !/veth/ {gsub(":","");print $2}'` ;{
	ethtool $nic >> ethinfo.txt
	echo >> ethinfo.txt
	ethtool -i $nic >> ethinfo.txt
	echo >> ethinfo.txt
}

echo "Start emon..."
source /opt/intel/sep/sep_vars.sh
${SEP_DIR}/sepdk/src/rmmod-sep
${SEP_DIR}/sepdk/src/insmod-sep
sleep 3

echo "irq,cpulist" > irqmap-start.txt
for i in `ls /proc/irq/* -d` ;{
  [ -d $i ] && echo "${i##*/},`cat $i/smp_affinity_list`" >> irqmap-start.txt
}  

qemu_pids=(`ps aux | grep qemu | grep -v grep | awk '{print $2}'`)
echo "start emon" >> numastat-startEMON.txt
for i in ${qemu_pids[@]} ;{
	echo "qemu pid: $i" >> numastat-startEMON.txt
	numastat -p $i >> numastat-startEMON.txt
	echo >> numastat-startEMON.txt
}
numastat -p ${qemu_pids[@]} >> numastat-startEMON.txt
cat /proc/vmstat > vmstat-startEMON.txt

emon -? > emon-events.txt
emon -v > emon-v.dat
emon -M > emon-m.dat
emon -i $EVENTS_LIST > emon.dat &


echo "start collecting..."
echo "iostat -x -k -d $INTER $SARCOUNT"
iostat -x -k -d $INTER $SARCOUNT > diskstat.txt &
echo "sar -n DEV $INTER $SARCOUNT"
sar -n DEV $INTER $SARCOUNT > network.txt &
echo "sat -A $INTER $SARCOUNT"
sar -A $INTER $SARCOUNT > sar-all.txt &
echo "vmstat -n $INTER $SARCOUNT"
vmstat -n $INTER $SARCOUNT > vmstat.txt &
#echo "dstat $INTER $SARCOUNT"
#dstat $INTER $SARCOUNT > dstat.txt &
echo "mpstat $INTER $SARCOUNT"
mpstat $INTER $SARCOUNT > mpstat.log &

for ((c=1; c<=COUNT; c++)) ;{
  cat /proc/interrupts >> interrupts.txt &
	echo -ne " $c[$COUNT]\r"
	sleep 1
}

echo "irq,cpulist" > irqmap-end.txt
for i in `ls /proc/irq/* -d` ;{
  [ -d $i ] && echo "${i##*/},`cat $i/smp_affinity_list`" >> irqmap-end.txt
}  
emon -stop
${SEP_DIR}/sepdk/src/rmmod-sep
qemu_pids=(`ps aux | grep qemu | grep -v grep | awk '{print $2}'`)
echo "stop emon" >> numastat-stopEMON.txt
for i in ${qemu_pids[@]} ;{
	echo "qemu pid: $i" >> numastat-stopEMON.txt
	numastat -p $i >> numastat-stopEMON.txt
	echo >> numastat-stopEMON.txt
}
numastat -p ${qemu_pids[@]} >> numastat-stopEMON.txt
cat /proc/vmstat > vmstat-stopEMON.txt

killall -9 sar
killall -9 mpstat
killall -9 iostat
killall -9 vmstat
#killall -9 dstat

echo "leave test dir: ${TEST_DIR}/${log_dir}"
cd -
chown $NUSER:$NUSER -R ./${TEST_DIR}/${log_dir}
echo "done."
