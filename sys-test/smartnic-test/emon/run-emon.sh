#!/bin/bash
# Feb 24, 2021
# v1.2
# xinx.e.zhang@intel.com

[[ $1 ]] && log_tag=$1 || log_tag=`date +%H%M%S-%m%d`
[[ $2 ]] && INTER=$2 || INTER=1
[[ $3 ]] && COUNT=$3 || COUNT=30
SARCOUNT=$COUNT

# user defines here
EDP_DIR='/root/emon/edp-v4.2'
#Arch_DIR='Architecture_Specific/Server/CooperLake/Cedar Island/CPX6-4S'
Arch_DIR='/root/emon/CPX6-4S'
EVENTS_LIST=cpx-4s-events.txt
NUSER=cloud
TEST_DIR=test-data

# the default files
SEP_DIR=/opt/intel/sep
EMON_EDP=edp.rb
Process_Win=process.cmd
Process_Sh=process.sh

log_dir=${TEST_DIR}/${log_tag}
mkdir -p ${log_dir}
# copy CPX6-4S/* to log_dir
#[ -d "${EDP_DIR}/${Arch_DIR}" ] && cp "${EDP_DIR}/${Arch_DIR}"/* ${log_dir}
[ -d "${Arch_DIR}" ] && cp "${Arch_DIR}"/* ${log_dir}
# copy edp.rb to log_dir
[ -f ${EDP_DIR}/${EMON_EDP} ] && cp ${EDP_DIR}/${EMON_EDP} ${log_dir}
# copy process.cmd to log_dir
[ -f ${EDP_DIR}/${Process_Win} ] && cp ${EDP_DIR}/${Process_Win} ${log_dir}
# copy process.sh to log_dir
[ -f ${EDP_DIR}/${Process_Sh} ] && cp ${EDP_DIR}/${Process_Sh} ${log_dir}
# copy *.xml and rename the new copy as 'metrics.xml'
[ -f ${log_dir}/*.xml ] && cp ${log_dir}/*.xml ${log_dir}/metrics.xml
# copy this script to log_dir
cp $0 ${log_dir}

for i in {1..5} ;{
	echo -ne "delay $i[5]\r"
	sleep 1
}

echo "go to test dir: ${log_dir}"
cd ${log_dir}

echo "Start emon..."
source /opt/intel/sep/sep_vars.sh
${SEP_DIR}/sepdk/src/rmmod-sep
${SEP_DIR}/sepdk/src/insmod-sep
sleep 3

emon -? > emon-events.txt
emon -v > emon-v.dat
emon -M > emon-m.dat
emon -i $EVENTS_LIST > emon.dat &

echo "start collecting..."
echo "sat -A $INTER $SARCOUNT"
sar -A $INTER $SARCOUNT > sar-all.txt &
echo "vmstat -n $INTER $SARCOUNT"
vmstat -n $INTER $SARCOUNT > vmstat.txt &

for ((c=1; c<=COUNT; c++)) ;{
	echo -ne " $c[$COUNT]\r"
	sleep 1
}

emon -stop
${SEP_DIR}/sepdk/src/rmmod-sep

killall -9 sar
killall -9 vmstat

echo "leave test dir: ${log_dir}"
cd -
echo "done."
