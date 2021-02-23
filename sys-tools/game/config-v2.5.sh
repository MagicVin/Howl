#!/bin/bash
#verion=v2.5

input_kog() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
	do
		docker exec -it android$i sh -c "input keyevent 61"
		echo "choose deny"
		sleep 5
		docker exec -it android$i sh -c "input keyevent 61"
		echo "choose allow"
		sleep 5
		docker exec -it android$i sh -c "input keyevent 66"
		echo "choose allow"
		sleep 5
		docker exec -it android$i sh -c "input keyevent 66"
		echo "choose allow"
		sleep 5
		docker exec -it android$i sh -c "input keyevent 66"
		echo "choose allow"
		sleep 5
		docker exec -it android$i sh -c "input keyevent 66"
		echo "choose allow"
		sleep 5
		docker exec -it android$i sh -c "input keyevent 66"
		echo "choose allow"
		sleep 5
		docker exec -it android$i sh -c "input keyevent 66"
		echo "choose allow"
		sleep 5
		docker exec -it android$i sh -c "input keyevent 61"
		echo "choose deny"
		sleep 5
		docker exec -it android$i sh -c "input keyevent 61"
		echo "choose allow"
		sleep 5
		docker exec -it android$i sh -c "input keyevent 66"
		echo "choose allow"
		sleep 5
		docker exec -it android$i sh -c "input swipe 250 0 250 100"
		echo "input swipe"
		sleep 5
		echo "input finished!"
	done

}

input_aov_1080P() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
	do
		echo "android$i"
		docker exec -it android$i /system/bin/sh -c "input tap 1300 573"
		echo "click confirm" 
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input keyevent 61"
		echo "choose deny"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input keyevent 61"
		echo "choose allow"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input keyevent 66"
		echo "click ok"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input swipe 250 0 250 100"
		echo "input swipe"
		sleep 5
		#docker exec -it android$i /system/bin/sh -c "input tap 960 405"
		#echo "choose server"
		#sleep 5
		#docker exec -it android$i /system/bin/sh -c "input tap 960 877.5"
		#echo "click ok"
		#sleep 5
	done
}

input_aov_720P() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
	do
		echo "android$i"
		docker exec -it android$i /system/bin/sh -c "input tap 865 488"
		echo "click confirm"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input keyevent 61"
		echo "choose deny"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input keyevent 61"
                echo "choose allow"
                sleep 5
                docker exec -it android$i /system/bin/sh -c "input keyevent 66"
                echo "click ok"
                sleep 5
		docker exec -it android$i /system/bin/sh -c "input swipe 250 0 250 100"
                echo "input swipe"
                sleep 5
	done
}

input_wmsj_720P() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
	do
		echo "android$i"
		docker exec -it android$i /system/bin/sh -c "input keyevent 61"
		echo "choose deny"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input keyevent 61"
		echo "choose allow"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input keyevent 66"
		echo "click ok"
		sleep 2
		docker exec -it android$i /system/bin/sh -c "input keyevent 66"
		echo "click ok"
		sleep 2
		docker exec -it android$i /system/bin/sh -c "input keyevent 66"
		echo "click ok"
		sleep 2
		docker exec -it android$i /system/bin/sh -c "input keyevent 66"
		echo "click ok"
		sleep 2
		docker exec -it android$i /system/bin/sh -c "input keyevent 66"
		echo "click ok"
		sleep 2
		docker exec -it android$i /system/bin/sh -c "input keyevent 66"
		echo "click ok"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input swipe 250 0 250 100"
		echo "input swipe"
		sleep 5
	done
}

update_wmsj_720P() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
        do
		echo "android$i"
		docker exec -it android$i /system/bin/sh -c "input tap 761 452"
	done
}

choose_aov_area_720P() {
        args_check_kog $*
        for ((i=$1;i<=$2;i++))
        do
                echo "android$i"
                docker exec -it android$i /system/bin/sh -c "input tap 656 320"
                echo "choose server"
                sleep 5
		docker exec -it android$i /system/bin/sh -c "input tap 663 609"
                echo "click ok"
                sleep 5
		docker exec -it android$i /system/bin/sh -c "input tap 78 675"
                echo "click agree"
                sleep 5
		docker exec -it android$i /system/bin/sh -c "input tap 719 675"
                echo "click agree"
                sleep 10

		docker exec -it android$i /system/bin/sh -c "input tap 271 509"
                echo "choose guest user to login"
                sleep 35
                docker exec -it android$i /system/bin/sh -c "input tap 160 315"
                echo "click text button"
                sleep 5
                docker exec -it android$i /system/bin/sh -c "input text test$RANDOM$RANDOM"
                echo "input name"
                sleep 5
                docker exec -it android$i /system/bin/sh -c "input tap 1200 670"
                echo "click ok"
                sleep 5
                docker exec -it android$i /system/bin/sh -c "input tap 310 425"
                echo "click ok"
		sleep 5
                docker exec -it android$i /system/bin/sh -c "input tap 310 425"
                echo "click ok"
                sleep 15
                docker exec -it android$i /system/bin/sh -c "input tap 160 360"
                echo "choose Novice"
                sleep 10
                docker exec -it android$i /system/bin/sh -c "input tap 480 630"
                echo "click ok"
                sleep 10
	done

		
}

choose_aov_area_1080P() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
	do
		echo "android$i"
		docker exec -it android$i /system/bin/sh -c "input tap 960 540"
		echo "choose server"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input tap 960 877.5"
		echo "click ok"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input tap 118 1012"
		echo "click agree"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input tap 1078 1012"
		echo "click agree"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input tap 720 776"
		echo "choose guest user to login"
		sleep 15
		docker exec -it android$i /system/bin/sh -c "input tap 240 472"
		echo "click text button"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input text test$RANDOM$RANDOM"
		echo "input name"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input tap 1860 573"
		echo "click ok"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input tap 480 675"
		echo "click ok"
		sleep 15
		docker exec -it android$i /system/bin/sh -c "input tap 240 540"
		echo "choose Novice"
		sleep 10
		docker exec -it android$i /system/bin/sh -c "input tap 720 945"
		echo "click ok"
		sleep 10
		
		#docker exec -it android$i /system/bin/sh -c "input tap 720 945"
		#echo "tap screen"
		#sleep 5
		#docker exec -it android$i /system/bin/sh -c "input tap 720 945"
		#echo "tap screen"
		#sleep 5
		#docker exec -it android$i /system/bin/sh -c "input tap 720 945"

	done
}

tap_screen() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
	do
		docker exec -it android$i /system/bin/sh -c "input tap 720 945"
		echo "tap screen"
		sleep 5
		docker exec -it android$i /system/bin/sh -c "input tap 720 945"
		echo "tap screen"
		sleep 5
	done
}

play_aov_720() {
	args_check_kog $*	
	for ((i=$1;i<=$2;i++)) ;{
		echo "play game -- android${i}"	
		echo "guest login"
		docker exec -it android$i /system/bin/sh -c "input tap 480 517"
		#sleep 30	
		#echo "tap screen"
		#docker exec -it android$i /system/bin/sh -c "input tap 740 509"
		#sleep 25
		#echo "tap to run "
		#docker exec -it android$i /system/bin/sh -c "input tap 480 517"
		sleep 2
	}

	sleep 120
	for ((i=$1;i<=$2;i++)) ;{
		echo "tap screen -- android${i}"
		docker exec -it android$i /system/bin/sh -c "input tap 740 509"
	}
}

close_720_fb() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++)) ;{
		echo "close -- android${i}"
		docker exec -it android$i /system/bin/sh -c "input tap 419 54"
		sleep 5
	}
}

reconn_720() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++)) ;{
		echo "reconnect -- android${i}"
		docker exec -it android$i /system/bin/sh -c "input tap 740 509"
		sleep 5
	}
}

tap_system_ui() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++)) {
		echo "close the screen cue of android$i"
		docker exec -it android$i /system/bin/sh -c "input tap 640 338"
		sleep 2
	}

}

action_aov_1080 () {
	i=$1
	if [ "$2" == "r" ]
	then	docker exec -it android$i /system/bin/sh -c "input swipe 240 877 400 877"
	elif [ "$2" == "ru" ]
	then	docker exec -it android$i /system/bin/sh -c "input swipe 240 877 360 776"
	elif [ "$2" == "rd" ]
	then	docker exec -it android$i /system/bin/sh -c "input swipe 240 877 370 1012"
	elif	[ "$2" == "l" ]
	then	docker exec -it android$i /system/bin/sh -c "input swipe 240 877 80 877"
	elif [ "$2" == "ld" ]
	then	docker exec -it android$i /system/bin/sh -c "input swipe 240 877 100 1020"
	elif [ "$2" == "lu" ]
	then	docker exec -it android$i /system/bin/sh -c "input swipe 240 877 100 810"
	elif 	[ "$2" == "u" ]
	then	docker exec -it android$i /system/bin/sh -c "input swipe 240 877 240 700"
	elif	[ "$2" == "d" ]
	then	docker exec -it android$i /system/bin/sh -c "input swipe 240 877 240 1000"
	elif	[ "$2" == "c" ]
	then	docker exec -it android$i /system/bin/sh -c "input tap 1740 877"
	elif	[ "$2" == "q" ]
	then	docker exec -it android$i /system/bin/sh -c "input tap 1440 945"
	elif	[ "$2" == "w" ]
	then	docker exec -it android$i /system/bin/sh -c "input tap 1560 742"
	elif	[ "$2" == "e" ]
	then	docker exec -it android$i /system/bin/sh -c "input tap 1740 607"
	elif	[ "$2" == "qq" ]
	then	docker exec -it android$i /system/bin/sh -c "input tap 1300 877"
	elif	[ "$2" == "ww" ]
	then	docker exec -it android$i /system/bin/sh -c "input tap 1440 675"
	elif	[ "$2" == "ee" ]
	then	docker exec -it android$i /system/bin/sh -c "input tap 1680 573"
	elif	[ "$2" == "b" ]
	then	docker exec -it android$i /system/bin/sh -c "input tap 240 472"
	elif	[ "$2" == "cc" ]
	then	docker exec -it android$i /system/bin/sh -c "input tap 1280 1012"
	fi
}

swipe(){
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
        do	
		
		echo "android$i input swipe"
		docker exec -it android$i sh -c "input swipe 250 0 250 100"
		sleep 2
	done
	echo "swipe finished!"

}

cancel_notice_kog_1080(){
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
        do	
		
		echo "android$i cancel notice"
		docker exec -it android$i sh -c "input tap 1740 135"
		sleep 5
	done
	echo "cancel finished!"
}

cancel_notice_kog_720(){
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
        do	
		
		echo "android$i cancel notice"
		docker exec -it android$i sh -c "input tap 1160 90"
		sleep 5
	done
	echo "cancel finished!"
}

clean_notice_wmsj_720P() {
	args_check_kog $*
        for ((i=$1;i<=$2;i++))
        do
		echo "android$i cancel notice"
		docker exec -it android$i sh -c "input tap 641 598"
		sleep 5
	done
	echo "clean finished!"
}

args_check_kog() {
	[ $# -ne 2 ] && echo "need two argments: [start_num] [end_num]" && exit
}


getscreen(){
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
        do
		echo "get the android$i screenshot(path /data/aic/workdir/data${i}/media/0/0.png) ..."
		docker exec -it android$i sh -c "screencap -p /sdcard/0.png" 
		#docker exec -it android$i sh -c "screencap -p /sdcard/0.png" &
		#pidd=$!
		#while [ ! -e /data/aic/workdir/data${i}/media/0 ]
		#do 
			echo "capturing the screenshot... "
			sleep 2
		#done
		
		#ps aux | grep "docker exec -it android$i sh -c" | grep -v grep | grep Tl> /dev/null 2>&1 && kill -9 $pidd && continue || echo "android$i get screenshot failed"
	done
	#screen_info $1 $2
	kill -9 `ps aux | grep png | awk '{print $2}' | xargs`
}

screen_info() {
	for ((j=$1;j<=$2;j++))
	do
		#ls -l /data/aic/workdir/data$j/media/0/0.png
		ls -l /data/aic/workdir/data${i}/media/0/0.png
	done
}

mvscreen_kog() {
	args_check_kog $*
	dir='workdir'
	time=$(date +%m%d-%H%M%S)
        log_dir="kog-screenshot-$time-`cat /etc/hostname | sed 's/media-//'`"
        mkdir -p $log_dir
	for ((i=$1;i<=$2;i++))
        do
		_node=$(($i/${INSTANCE}))
		_count=$(($i%${INSTANCE}))
		_irr_num=$((${_node}*15+1+${_count}))
		echo android$i -- irr$_irr_num
		#mv $dir/data$i/media/0/0.png $log_dir/android${i}-irr${_irr_num}.png
		#ls -l $log_dir/android${i}-irr${_irr_num}.png
	done
	#chown media:media -R $log_dir
}

mvscreen_aov() {
	args_check_kog $*
	dir='workdir'
	time=$(date +%m%d-%H%M%S)
        log_dir="aov-screenshot-$time-`cat /etc/hostname | sed 's/media-//'`"
        mkdir -p $log_dir
	for ((i=$1;i<=$2;i++))
        do
		_node=$(($i/${INSTANCE}))
		_count=$(($i%${INSTANCE}))
		_irr_num=$((${_node}*15+1+${_count}))
		#echo android$i -- irr$_irr_num
		mv $dir/data$i/media/0/0.png $log_dir/android${i}-irr${_irr_num}.png
		ls -l $log_dir/android${i}-irr${_irr_num}.png
	done
	chown media:media -R $log_dir
}

mvscreen_subway() {
	args_check_kog $*
	dir='workdir'
	time=$(date +%m%d-%H%M%S)
        log_dir="subway-$time-`cat /etc/hostname | sed 's/media-//'`"
        mkdir -p $log_dir
	for ((i=$1;i<=$2;i++))
        do
		_node=$(($i/${INSTANCE}))
		_count=$(($i%${INSTANCE}))
		_irr_num=$((${_node}*15+1+${_count}))
		#echo android$i -- irr$_irr_num
		mv $dir/data$i/media/0/0.png $log_dir/android${i}-irr${_irr_num}.png
		ls -l $log_dir/android${i}-irr${_irr_num}.png
	done
	chown media:media -R $log_dir
}

mvscreen_houdini() {
	args_check_kog $*
	dir='workdir'
	time=$(date +%m%d-%H%M%S)
        log_dir="houdini-$time-`cat /etc/hostname | sed 's/media-//'`"
        mkdir -p $log_dir
	for ((i=$1;i<=$2;i++))
        do
		_node=$(($i/${INSTANCE}))
		_count=$(($i%${INSTANCE}))
		_irr_num=$((${_node}*15+1+${_count}))
		#echo android$i -- irr$_irr_num
		mv $dir/data$i/media/0/0.png $log_dir/android${i}-irr${_irr_num}.png
		ls -l $log_dir/android${i}-irr${_irr_num}.png
	done
	chown media:media -R $log_dir
}



showirr() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
        do
		_node=$(($i/${INSTANCE}))
		_count=$(($i%${INSTANCE}))
		_irr_num=$((${_node}*15+1+${_count}))
		echo android$i -- irr$_irr_num
	done
}

start_kog() {
	args_check_kog $*
	game_name="com.tencent.tmgp.sgame/com.tencent.tmgp.sgame.SGameActivity"
	for ((i=$1;i<=$2;i++))
	do
	echo "Start games to android$i...."
	docker exec -it android$i /system/bin/sh -c "am start -S -W $game_name"
	sleep 5
	done

}

start_aov() {
	args_check_kog $*
	game_name="com.ngame.allstar.eu/com.ngame.allstar.SGameActivity"
	for ((i=$1;i<=$2;i++))
	do
		echo "Start games to android$i...."
		docker exec -it android$i /system/bin/sh -c "am start -S -W $game_name"
		sleep 2
	done

}

start_subway() {
	args_check_kog $*
	game_tag
	for ((i=$1;i<=$2;i++))
	do
		echo "Start $PKG_NAME/$MAIN_ACT for android$i...."
		docker exec -it android$i /system/bin/sh -c "am start -S -W $PKG_NAME/$MAIN_ACT"
		sleep 5
	done
}

start_houdini_apk() {
	args_check_kog $*
	game_tag
	for ((i=$1;i<=$2;i++))
	do
		echo "Start $PKG_NAME/$MAIN_ACT for android$i...."
		docker exec -it android$i /system/bin/sh -c "am start -S -W $PKG_NAME/$MAIN_ACT"
		sleep 5
	done
}

close_templerun_warning() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++)) ;{
		echo "close templerun:warning for android${i}..."
		docker exec -it android$i /system/bin/sh -c "input tap 364 832"
		sleep 2
	}
}


run_templerun() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++)) ;{
		echo "templerun is running on android${i}"
		docker exec -it android$i /system/bin/sh -c "input tap 352 973"
		sleep 2
	}
}

ignore_aov_update_1080P() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
        do
		echo "cancel games update for android$i...."
		docker exec -it android$i /system/bin/sh -c "input tap 720 945"
		sleep 5
	done
}

ignore_aov_update_720P() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
        do
		echo "cancel games update for android$i...."
		docker exec -it android$i /system/bin/sh -c "input tap 480 630"
		sleep 5
	done
}

game_tag() {
	if test -z "`dpkg -l | grep aapt`"
	then
 		apt install -y aapt
	fi
	echo "PKG detail: `aapt d badging $COMPLETE_APK`"
	PKG_NAME=`aapt d badging $COMPLETE_APK | grep "package: name=" | awk -F "'" '{print $2}'`
	echo "PKG_NAME: $PKG_NAME"
	MAIN_ACT=`aapt d badging $COMPLETE_APK | grep "launchable-activity:" | awk -F "'" '{print $2}'`
	echo "MAIN_ACT: $MAIN_ACT"
	APK=`echo $COMPLETE_APK | awk -F "/" '{print $NF}'`
}

install_aov() {
	args_check_kog $*	
	game_tag
	for ((i=$1;i<=$2;i++))
	do
		echo "install games to android$i ..."
		echo "cp $COMPLETE_APK  $AIC/workdir/data$i/media/0/"
		sudo cp $COMPLETE_APK $AIC/workdir/data$i/media/0/
		echo "cp -r $COMPLETE_FOLDER $AIC/workdir/data$i/media/obb"
		sudo cp -r $COMPLETE_FOLDER $AIC/workdir/data$i/media/obb/
		sleep 5
		echo "sudo docker exec -it android$i /system/bin/sh -c pm install sdcard/$APK_NAME"
		sudo docker exec -it android$i /system/bin/sh -c "pm install sdcard/$APK_NAME"
		sleep 5
		echo "rm -rf  $AIC/workdir/data$i/media/0/$APK_NAME"
		sudo rm -rf $AIC/workdir/data$i/media/0/$APK_NAME
	done
}

install_subway() {
	args_check_kog $*
	game_tag
	for ((i=$1;i<=$2;i++))
	do
		echo "install games to android$i ..."
		echo "cp $COMPLETE_APK  ./workdir/data$i/media/0/"
		cp $COMPLETE_APK  ./workdir/data$i/media/0/
		sleep 5
		docker exec -ti android$i /system/bin/sh -c "pm install /sdcard/$APK"
		sleep 5
		#echo "./workdir/data$i/media/0/`echo $COMPLETE_APK | awk -F '/' '{print $NF}'`"
		#rm -rf ./workdir/data$i/media/0/`echo $COMPLETE_APK | awk -F '/' '{print $NF}'`
		echo "rm -rf  $AIC/workdir/data$i/media/0/$APK_NAME"
		rm -rf  $AIC/workdir/data$i/media/0/$APK_NAME
	done
}

install_houdini_arm_apk() {
	args_check_kog $*
	game_tag
	for ((i=$1;i<=$2;i++))
	do
		echo "install games to android$i ..."
		echo "cp $COMPLETE_APK  ./workdir/data$i/media/0/"
		cp $COMPLETE_APK  ./workdir/data$i/media/0/
		sleep 5
		docker exec -ti android$i /system/bin/sh -c "pm install --abi armeabi-v7a /sdcard/$APK"
		sleep 5
		echo "rm -rf  $AIC/workdir/data$i/media/0/$APK_NAME"
		rm -rf  $AIC/workdir/data$i/media/0/$APK_NAME
	done
}

install_houdini_x86_apk() {
	args_check_kog $*
	game_tag
	for ((i=$1;i<=$2;i++))
	do
		echo "install games to android$i ..."
		echo "cp $COMPLETE_APK  ./workdir/data$i/media/0/"
		cp $COMPLETE_APK  ./workdir/data$i/media/0/
		sleep 5
		docker exec -ti android$i /system/bin/sh -c "pm install /sdcard/$APK"
		sleep 5
		echo "rm -rf  $AIC/workdir/data$i/media/0/$APK_NAME"
		rm -rf  $AIC/workdir/data$i/media/0/$APK_NAME
	done
}

set_instance() {
        INSTANCE=$1
        echo "current instance number is: $INSTANCE"
}

print_info() {
        echo "current instance number is: $INSTANCE"
        echo "current AIC is presented at: $AIC"
        echo "current PKG is presented at: $COMPLETE_APK"

}

collect_fps(){
	
	if [ -d ./vcgss_perf_log ];then
	  echo "Delete old data!"
	  sudo rm -rf ./vcgss_perf_log

	fi

	mkdir ./vcgss_perf_log
	touch ./vcgss_perf_log/Average_fps.log



	sudo docker ps | awk '{print $NF}' | grep -E 'android' > ./vcgss_perf_log/running_instance.txt

	cat ./vcgss_perf_log/running_instance.txt | while read line
	do
	    echo $line

    		touch ./vcgss_perf_log/$line\_fps.log

	    	sudo docker exec  $line /system/bin/sh -c "logcat -d"  | grep "fps =" |  tail -n 30 | awk -F " " '{print $NF}' > ./vcgss_perf_log/$line\_fps.log

		cat ./vcgss_perf_log/$line\_fps.log | awk '{sum+=$1} END {print "", sum/NR}' >> ./vcgss_perf_log/Average_fps.log

	done

	cat ./vcgss_perf_log/Average_fps.log | awk '{sum+=$1} END {print "Average", sum/NR}'
	per_node_fps

}

per_node_fps() {
	FPS_LOG="vcgss_perf_log/Average_fps.log"
	NODE_NUM=3
	TOTAL_INSTANCES=`cat $FPS_LOG | wc -l`
	let NODE_INSTANCES=$TOTAL_INSTANCES/$NODE_NUM
	ARR_INSTANCES=(`cat $FPS_LOG`)
	echo "ARR_INSTANCES: ${ARR_INSTANCES[@]}"
	K=0
	for i in `seq 0 $(($NODE_NUM-1))`
	do
		let K=i*${NODE_INSTANCES}
		N_SUM=0
		echo -ne NODE${i}
		for j in `seq 0 $(($NODE_INSTANCES-1))`
		do
			let inode=K+j
			#echo instance -- $j -- inode=$inode
			echo -ne " ${ARR_INSTANCES[$inode]}"
			N_SUM=`echo "$N_SUM+${ARR_INSTANCES[$inode]}" | bc`
		done
		N_AVG=`echo "${N_SUM}/${NODE_INSTANCES}" | bc`
		echo -ne " AVG=$N_AVG"
		echo 
	done

}

irr_map() {

        node_ips=(`vcactl network ip | grep 172`)

        total(){
                for i in ${node_ips[@]}
                do
                        xip=$i
                        #echo "ssh $xip $@"
                        ssh $xip ps aux | grep rend
                done
        }

        total | sed 's/demo\//demo /g;s/\.flv/ flv/g' | sort -k18 -n | cat -n
        unset -f total
}



trend_raw() {
	docker stats --no-trunc > instance.txt &
	ppid=$!
	echo $ppid
	#for i in {0..299}
	#do
	#	echo "$i mins later"
	#	sleep 1
	#done
	in_ctime 300
	
	echo "kill -9 $ppid"
	kill -9 $ppid
}

trend_clean() {
	trend_raw
	r_title="`grep NAME instance.txt | sed 's/^.* \(a.*$\)/\1/g;s/^.*NAME/NAME/g' | uniq`"
	#for num in android{0..32} aic-manager
	for num in `docker ps -a | grep Up | awk '{print $NF}'`
	do
		_tag="`echo $num | sed 's/^android\([0-9]\)/a\1/;s/aic-manager/aic/'`"
		n_title=(`echo $r_title | sed "s/CPU\ %/CPU\(\%\)${_tag}/g;s/MEM\ USAGE\ \/\ LIMIT/MEM_USAGE\(MiB\)${_tag}\ LIMIT\(GiB\)${_tag}/g;s/MEM\ \%/MEM\(\%\)${_tag}/g;s/NET\ I\/O/NET\(GB\)${_tag}\ I\/O\(GB\)${_tag}/g;s/BLOCK\ I\/O/BLOCK\(MB\)${_tag}\ I\/O\(MB\)${_tag}/g;s/PIDS/PIDS_${_tag}/g"`)
		echo ${n_title[@]} > $num.txt
		grep " $num " instance.txt | sed "s/^.*${num}/${num}/g;s/\%//g;s/MiB//g;s/\///g;s/GiB//g;s/GB//g;s/MB//g" >> $num.txt
	done
}

trend_fps() {
	[[ $1 ]] && trend_dir_tag=$1 || trend_dir_tag="default"
	trend_start_time=$(date +%m%d-%H%M%S)
	trend_dir=`cat /etc/hostname | cut -d- -f2`-instance-trend-${trend_start_time}-${trend_dir_tag}
	mkdir -p $trend_dir
	cd $trend_dir
	trend_clean
	chown media:media -R ../$trend_dir
	echo "result path: `pwd`"
	ll -d ../$trend_dir
	cd ../
}

in_ctime() {
	sec=$1
	echo "wait for $sec ..."
	for i in `seq $sec`
	{
		echo -en "[${i}]\r"
		sleep 1

	}
	echo
}

sysmon_main() {
        ltime="date +%m%d-%H%M%S"
        RAWIN=$(ps -o pid,user,%mem,command ax | grep -v PID | awk '/[0-9]*/{print $1 ":" $2 ":" $4}')
        for i in $RAWIN
        do
                PID=$(echo $i | cut -d: -f1)
                OWNER=$(echo $i | cut -d: -f2)
                COMMAND=$(echo $i | cut -d: -f3)
                MEMORY=$(pmap $PID | tail -n 1| awk '/[0-9]K/{print $2}')

                printf "%-15s%-10s%-15s%-15s%s\n" "`$ltime`" "$PID" "$OWNER" "$MEMORY" "$COMMAND"

        done
}

check_mem() {
        TAG=$1
        #printf "%-15s%-10s%-15s%-15s%s\n" "Time" "PID" "OWNER" "MEMORY" "COMMAND"
        printf "%-20s%-20s%-20s\n" "TIME" "NAME" "MEMORY"
        sysmon_main | sort -bnr -k4 > sysmon.txt
        top5_thread=$(head -n5 sysmon.txt | awk '{print $1"+"$2"+"$3"+"$4"+"$5}')
        for i in $top5_thread
        do
                T_Time=$(echo $i | cut -d+ -f1)
                T_PID=$(echo $i | cut -d+ -f2)
                T_OWNER=$(echo $i | cut -d+ -f3)
                T_MEMORY=$(echo $i | cut -d+ -f4)
                T_COMMAND=$(echo $i | cut -d+ -f5)
                COMMAND_NAME=$(echo "${T_COMMAND}" | awk -F '/' '{print $NF}')
                T_TAG="$(echo $COMMAND_NAME | cut -c1-5)"_${TAG}
                printf "%-10s%-15s%-10s\n" "$T_Time $T_TAG $T_MEMORY" >> ${T_PID}-${COMMAND_NAME}-top5.txt

        done

        for T_thread in nm-applet NetworkManager
        do
                N_TAG="$(echo $T_thread | cut -c1-5)"_${TAG}
                thread0=(`grep $T_thread sysmon.txt | awk '{print $1,$2,$4}'`)
                #echo ${thread0[@]}
                #echo -----------------------------------------------------------------------
                printf "%-20s%-20s%-20s\n" "${thread0[0]}" "$N_TAG" "${thread0[2]}" | tee -a ${thread0[1]}-${T_thread}-need.txt
        done

}

free_check() {
        f_date=`date +"%m%d_%H%M%S"`
        free -h | sed "1s/^.........../$f_date/" >> vm_free.txt
}


trend_mem(){
	check_mem_dir=`cat /etc/hostname | cut -d- -f2`_mem_dir_`date +%m%d-%H%M%S`
	mkdir -p $check_mem_dir
	cd $check_mem_dir
	loop=0
	sas_log=sas-aic.txt
	echo "Loop Begin" | tee $sas_log
	while true
	#for i in 1  
	do
		echo "***************** [$loop] -- `date` ******************** " | tee -a $sas_log
		check_mem ${loop}
		free_check
		#sleep 300
		in_ctime 300
		let loop++
	done

}

node_alive_check() {
        xip=$1
        ssh $xip 'echo' > /dev/null 2>&1 
        #pidd=$!
	wwork=$?
        #xpidd=`ps aux | grep "ssh root$xip" | grep -v grep | awk '{print $2}'`
        #sleep 1
        #ps aux | grep "ssh root@$xxip" | grep -v grep > /dev/null 2>&1 || xpidd=0000

        #echo "pidd == $pidd, xpidd == $xpidd"
        #echo "++++++++++++++++++++++++++++++++++++++++"
        #ps aux | grep "ssh media@$xip" | grep -v grep
        #echo "++++++++++++++++++++++++++++++++++++++++"
        #[ $xpidd -ne 0000 ] && echo "error: ssh from media to $xip -- failed!" && kill -9 $xpidd && continue
	if [ $wwork -ne 0 ]
	then 
		#echo "error: ssh from media to $xip -- failed!"
		let bypass=1
		#continue
	else
		let bypass=0
	fi
}



collect_perf() {
	node_id=(0 1 2)
	default_instance=$INSTANCE
	declare -ga android_num
	declare -ga android_port
	declare -ga android_flv
	declare -ga android_service
	declare -ga android_ip
	declare -ga android_node
	declare -i inode=0
	declare -gi bypass=0
	declare -a irr_port
	declare -a irr_flv
	for nid in ${node_id[@]}
	{
		xip=172.31.$((nid+1)).1
		echo collect $xip
		node_alive_check $xip
		if [ $bypass -ne 0 ]
		then 
			#irr_port($(printf '0\n%.0s' {1..5}))
			irr_port=($(seq $default_instance | awk '{print 0}'))
			irr_flv=($(seq $default_instance | awk '{print 0}'))
		else
			irr_port=($(ssh $xip "ps aux | grep rend | grep -v grep | sed  's/^.*port \(.*\) \-b .*/\1/' | sort -n "))
			irr_flv=($(ssh $xip "ps aux | grep rend | grep -v grep | sed 's/^.*demo\/\(.*\)\.flv.*/\1/'| sort -n "))
		fi
		#total_irr=($(ssh $xip "ps aux | grep rend | grep -v grep | sed  's/^.*demo\/\(.*\)\.flv.*port \(.*\) \-b.*/\1 \2/'"))
		#echo ${total_irr[@]}
		for ((i=0;i<${#irr_port[@]};i++))
		{
			#echo "android${inode}  port:${irr_port[i]} flv:${irr_flv[i]} service:$irr_service"
			[ $bypass -eq 0 ] && let irr_service=irr_port[i]-23431 || irr_service=0
			android_num[inode]=$inode
			android_port[inode]=${irr_port[i]}
			android_flv[inode]=${irr_flv[i]}
			android_service[inode]=$irr_service
			android_ip[inode]=$xip
			android_node[inode]=$nid
			let inode++
	
		}
	}
}

android_map() {
	collect_perf
	echo android map:
	for ((i=0;i<${#android_num[@]};i++))
	{
		echo -e "android${android_num[i]} \t ip:${android_ip[i]} \t port:${android_port[i]} \t flv:${android_flv[i]}  \t service:${android_service[i]}"
	}

}

android_perf() {
	args_check_kog $*
	start_num=$1
	end_num=$2
	if [ -d ./vca_perf_log ];then

		echo "Delete old data!"
		sudo rm -rf ./vca_perf_log

	fi	

	mkdir vca_perf_log && touch ./vca_perf_log/Average_fps.log
	collect_perf
	echo "start_num: $start_num end_num: $end_num android_num: ${#android_num[@]}"
	[[ $start_num -gt ${#android_num[@]} ]] && echo err: out of android range && exit -1
	[[ $end_num -gt ${#android_num[@]} ]] && echo err: out of android range && exit -1

	for ((i=start_num;i<=end_num;i++))
	{
		_xip=${android_ip[i]}
		_service=${android_service[i]}
		_node=${android_node[i]}
		node_alive_check $_xip
		#echo "android${i} -- $_xip"
		if [ $bypass -ne 0 ]
		then
			echo 0 > ./vca_perf_log/android${i}.log
			echo node$_node android${i} average: 0 | tee -a ./vca_perf_log/Average_fps.log
		else
			ssh $_xip "journalctl -t irr.${_service} -n90 | grep FPS" > ./vca_perf_log/android${i}.log
			#cat ./vca_perf_log/android${i}.log | awk -v name=android${i} -v node=$_node '{sum+=$NF} END{print "node"node,name" average: "sum/NR}' | tee -a ./vca_perf_log/Average_fps.log
			cat ./vca_perf_log/android${i}.log | awk -v name=android${i} -v node=$_node '{sum+=$7} END{print "node"node,name" average: "sum/NR}' | tee -a ./vca_perf_log/Average_fps.log
		fi

	}
	cat ./vca_perf_log/Average_fps.log | awk '{sum+=$NF} END{print "sum_ave: "sum "/" NR"="sum/NR}' | tee -a ./vca_perf_log/Average_fps.log
	node_perf
}

node_perf() {
	for i in ${node_id[@]}
	{
		node_id=node$i
		node_ave=$(grep $node_id ./vca_perf_log/Average_fps.log | awk '{sum+=$NF} END {print sum/NR}')
		node_list=$(grep $node_id ./vca_perf_log/Average_fps.log | awk '{ORS=" "} {print $NF}')
		echo "NODE${i}: $node_list AVE: $node_ave"
	}

}

check_android() {
	begin=$1
	end=$2
	for ((i=$begin;i<=$end;i++))
	{
		codes=(`docker exec -ti android${i}  getprop dev.bootcomplete 2>/dev/null`)
		echo "android$i -- ${codes[0]}"
		codes="0"
	}
}


check_docker() {
	begin=$1
	end=$2
	for ((i=$begin;i<=$end;i++))
	{
		echo " android$i shell -- `docker exec -it android$i /system/bin/sh -c 'echo work'`"
	}
}

generate_irr_file() {

USAGE=$(cat <<- EOM
\n
   unsupported arguments, exit \n
   ./generate-server-file.sh  -n [node num] -i [instance num] -g [grap]\n
   -n|--nodes \t  number of vca node, default=6 \n
   -i|--instance \t number of instance, default=60 \n
   -g|--grap \t graphic rate, default=1080P \n

EOM
)


	while [ "$#" -gt 0 ]
	do
		case $1 in
		-n|--nodes) 
			nodes=$2
			shift
			shift
		;;
		-i|--instances)
			instances=$2
			shift
			shift
		;;
		-g|--grap)
			grap=$2
			shift
			shift
		;;
		*)
			echo -e $USAGE
			exit -1
		;;
		esac
	done

	[[ $nodes ]] || nodes=6
	[[ $instances ]] || instances=60
	[[ $grap ]] || grap=1080P
	
	echo "generate_irr_file -n $nodes -i $instances -g $grap"

	if [ -e "./rr_server_file_${grap}_${instances}" ]
	then
		echo "rr_server_file_${grap}_${instances} existed, no need to generate the server file"
	else
		let per_instances=instances/nodes 
		#echo $per_instances

		for ((i=1;i<=nodes;i++))
		{
			nodeip=172.31.${i}.1
			#echo $nodeip
			for ((j=0;j<$per_instances;j++))
			{
				let ports=23432+j
				echo $nodeip:$ports >> rr_server_file_${grap}_${instances}
			}
		}


	fi
}

incre-ipcfg() {
	local i_count=151
	for i in {150..253}
	do
		let i_count++
	
		echo $i - ip=$i_count
	
		cat ipconfig149 | sed "s/151/${i_count}/" > ipconfig${i}
	done
}

call_stack() {
	sysctl -w kernel.hardlockup_all_cpu_backtrace=1
	sysctl -w kernel.softlockup_all_cpu_backtrace=1
	sysctl -w kernel.softlockup_panic=1
}

check_media() {
	ls workdir/data{0..44}/media | grep -v obb | grep ^0 -B1 | grep data | sed 's/.*data\(.*\)\/med.*/\1/' | sort -n

}


clearcache() {
	echo 1 > /proc/sys/vm/drop_caches
}

client-to-server() {

	server_path="/home/aic/transfer-station"

usage=$(cat <<- EOM
\n
        usage:\n
                $0 [file_from_path] \n
                $0 xx.txt \n
EOM
)


	[ $# -ne 1 ] && echo -e ${usage[@]} && exit

	s_ip=192.168.0.100
	ssh aic@${s_ip} mkdir -p $server_path
	echo "scp -r $1 aic@${s_ip}:$server_path"
	scp -r $1 aic@${s_ip}:$server_path


}

msg_tonode() {
	message=$@
	hostname="`cat /etc/hostname`"
	for i in 1 2 3
	do
		m_ip=172.31.${i}.1
		node_name=`ssh $m_ip 'hostnamectl' | awk ' $1 == "Transient" {print $NF} '`
		echo "ssh $m_ip echo $message > /dev/kmsg"
		ssh $m_ip "echo ${hostname}: $message > /dev/kmsg"
	done
}

down_node() {
	echo "os-shutdown 0 0"
	vcactl os-shutdown 0 0 --force
	echo "os-shutdown 0 1"
	vcactl os-shutdown 0 1 --force
	echo "os-shutdown 0 2"
	vcactl os-shutdown 0 2 --force
}
pre_software() {

	apt-get update
	#install docker-ce
	apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - #add docker's official GPG key
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" #set up stable repository
	apt-get update
	#apt-get install docker-ce -y
	apt-get install gcc make libssl-dev -y
	#install vca dependence
	apt-get install bridge-utils libboost-date-time1.58.0 libboost-regex1.58.0 ipcalc kpartx libboost-filesystem1.58.0 libboost-system1.58.0 libboost-thread1.58.0 gdisk -y
	#apt-get install docker-ce=18.06.3~ce~3-0~ubuntu -y
	apt-get install docker-ce=5:18.09.0~3-0~ubuntu-xenial -y
	apt-get install pcre2-utils libpcre3-dev -y 
	apt-get install unzip -y
	apt-get install sysstat -y

}

pre_sshkey() { 
	[ $UID != 0 ] && echo "Please run as root." && exit
	[ -f /root/.ssh/id_rsa.pub ] && echo key existed || ssh-keygen
	vcactl network ip | grep -v : | while read line
	do
		echo "$line"
		ssh-copy-id $line
	done

}

fetch_android_log() {
	vmname=$(hostname)
	date_c=$(date +"%m-%d")
	[[ $1 ]] && startt=$1 || startt=0
	[[ $2 ]] && endd=$2 || endd=44
	let numm=endd-startt+1
	mkdir -p $vmname-android_log-$date_c
	cd $vmname-android_log-$date_c
	echo "current path:$(pwd), need to fetch $numm android(s) log"

	#for i in {0..44}
	for ((i=startt;i<=endd;i++))
	{
		instance_name="android${i}"
		echo $instance_name
		echo "vm date: `date`" > $instance_name.log
		docker exec -it  $instance_name /system/bin/sh -c "logcat -d" >> $instance_name.log

	}
	cd ..
	chown media:media -R $vmname-android_log-$date_c
}

fetch_node_log() {
	vmname=$(hostname)
	date_c=$(date +"%m-%d")
	[[ $1 ]] && startt=$1 || startt=0
	[[ $2 ]] && endd=$2 || endd=2
	let numm=endd-startt+1
	mkdir -p $vmname-node_log-$date_c
	cd $vmname-node_log-$date_c
	echo "current path:$(pwd), need to fetch $numm node(s) log"
	for ((i=startt;i<=endd;i++)) ;{
		node_name=node${i}
		echo ${node_name}
		node_ip=172.31.$((i+1)).1
		echo "vm date: `date`" > ${node_name}_dmesg.txt
		sudo ssh ${node_ip} dmesg >> ${node_name}_dmesg.txt
		echo "vm date: `date`" > ${node_name}_journal.txt
		sudo ssh ${node_ip} journalctl -b0 >> ${node_name}_journal.txt
	}
	cd ..
	chown media:media -R $vmname-node_log-$date_c
}

fetch_host_log() {
	vmname=$(hostname)
	date_c=$(date +"%m-%d")
	mkdir -p ${vmname}-${date_c}
	cd ${vmname}-${date_c}
	echo "current path:$(pwd), fetch host log"
	sudo dmesg > ${vmname}_dmesg.txt
	sudo journalctl -b0 > ${vmname}_journal.txt
	fetch_android_log
	sleep 5
	fetch_node_log 
	cd ..
	chown media:media -R ${vmname}-${date_c}
}

check_platform() {
	args_check_kog $*
	for ((i=$1;i<=$2;i++))
	do
		ls workdir/data$i/app/*/lib 2>/dev/null
	done
}

platform() {
	args_check_kog $*
	arrs=(`check_platform $1 $2`)
	echo ${arrs[@]} | sed 's/ /\n/g' | sort -n | uniq
}

node_cmd() {
	_cmd=$@
	for i in 1 2 3 ;{
		node_ip=172.31.${i}.1
		echo $node_ip
		ssh root@${node_ip} "${_cmd}"

	}
} 

android_cmd() {
	_cmd=($@)
	aic_num=${_cmd[0]}
	args_count=${#_cmd[@]}
	docker_cmd=()
	docker_cmd_index=0
	for ((i=1;i<args_count;i++)) ;{
		docker_cmd[docker_cmd_index]=${_cmd[i]}
		let docker_cmd_index++
	}
	#echo "aic: $aic_num"
	#echo "cmds: ${docker_cmd[@]}"
	cmd_strings="${docker_cmd[@]}"
	echo "docker cmd: docker exec -it android${aic_num} /system/bin/sh -c \"${docker_cmd[@]}\""
	docker exec -it android${aic_num} /system/bin/sh -c "$cmd_strings"
}

main() {
	AIC="/data/aic"
	[[ $INSTANCE ]] || INSTANCE=7
	### aov path config
	COMPLETE_PATH=/data/aov-1.34.1.10
	APK_NAME=base.apk
	APP_FOLDER=com.ngame.allstar.eu
	COMPLETE_APK="$COMPLETE_PATH/$APK_NAME"
	COMPLETE_FOLDER="$COMPLETE_PATH/$APP_FOLDER"

	## subway path config
	#COMPLETE_PATH=/data/subway
	#APK_NAME=dtpkbd_1499043809924.apk
	#COMPLETE_APK="$COMPLETE_PATH/$APK_NAME"
	#COMPLETE_APK="/data/dtpkbd_1499043809924.apk"

	### wanmei apk
	#COMPLETE_PATH=/data/wanmei-1.350
	#APK_NAME=10040714_com.tencent.wmsj_a706833_1.350.0_3c0lt8.apk
	#COMPLETE_APK="$COMPLETE_PATH/$APK_NAME"

	### templerun apk
	#COMPLETE_PATH=/data/templerun
	#APK_NAME=com.imangi.templerun2_1.52.1-211_arm_apkmirror.com.apk
	#COMPLETE_APK="$COMPLETE_PATH/$APK_NAME"
	echo "current instance number is: $INSTANCE"

	echo
	echo "Usage: . config.sh or export config.sh"
	echo 
	echo "Support functions:"
	echo -e " 1. \t input_kog \t\t\t [start_num] [end_num]"
	echo -e " 2. \t input_aov_1080P \t\t [start_num] [end_num]"
	echo -e " 3. \t input_aov_720P \t\t [start_num] [end_num]"
	echo -e " 4. \t getscreen \t\t\t [start_num] [end_num]"
	echo -e " 5. \t mvscreen_kog \t\t\t [start_num] [end_num]" 
	echo -e " 6. \t mvscreen_aov \t\t\t [start_num] [end_num]" 
	echo -e " 7. \t start_kog \t\t\t [start_num] [end_num]" 
	echo -e " 8. \t start_aov \t\t\t [start_num] [end_num]" 
	echo -e " 9. \t start_subway \t\t\t [start_num] [end_num]" 
	echo -e " 10. \t install_aov \t\t\t [start_num] [end_num]" 
	echo -e " 11. \t install_subway \t\t [start_num] [end_num]" 
	echo -e " 12. \t choose_aov_area_1080P \t\t [start_num] [end_num]" 
	echo -e " 13. \t choose_aov_area_720P \t\t [start_num] [end_num]" 
	echo -e " 14. \t tap_screen \t\t\t [start_num] [end_num]" 
	echo -e " 15. \t swipe \t\t\t\t [start_num] [end_num]"
	echo -e " 16. \t cancel_notice_kog_1080 \t [start_num] [end_num]"
	echo -e " 17. \t cancel_notice_kog_720  \t [start_num] [end_num]"
	echo -e " 18. \t ignore_aov_update_1080P \t [start_num] [end_num]"
	echo -e " 19. \t ignore_aov_update_720P \t [start_num] [end_num]"
	echo -e " 31. \t android_perf \t\t\t [start_num] [end_num]"
	echo -e " 20. \t showirr \t\t\t [start_num] [end_num]" 
	echo -e " 21. \t action_aov_1080 \t\t [num] \t     [action]"
	echo -e " 22. \t set_instance \t\t\t [instance_num]"
	echo -e " 23. \t trend_fps \t\t\t [dir_tag]"
	echo -e " 24. \t check_mem \t\t\t [dir_tag]"
	echo -e " 25. \t print_info \t\t\t "
	echo -e " 26. \t collect_fps" 
	echo -e " 27. \t per_node_fps" 
	echo -e " 28. \t irr_map"
	echo -e " 29. \t trend_mem"
	echo -e " 30. \t android_map"
	echo -e " 31. \t check_android \t [start_num] [end_num]"
	echo -e " 31. \t check_docker \t [start_num] [end_num]"
	echo -e " 32. \t generate_irr_file -n [all_node_num] -i [instance_num] -g [resolution]"
	echo -e " 33. \t incre-ipcfg"
	echo -e " 34. \t call_stack"
	echo -e " 35. \t check_media"
	echo -e " 36. \t clearcache"
	echo -e " 37. \t client-to-server"
	echo -e " 38. \t msg_tonode"
	echo -e " 39. \t down_node"
	echo -e " 40. \t pre_software"
	echo -e " 41. \t pre_sshkey"
	echo -e " 42. \t fetch_android_log \t [start_num] [end_num]"
	echo -e " 43. \t fetch_node_log \t [start_num] [end_num]"
	echo -e " 44. \t fetch_host_log "
	echo -e " 45. \t tap_system_ui \t\t [start_num] [end_num]"
	echo -e " 46. \t play_aov_720 \t\t [start_num] [end_num]"
	echo -e " 47. \t close_720_fb \t\t [start_num] [end_num]"
	echo -e " 48. \t reconn_720 \t\t [start_num] [end_num]"
	echo -e " 49. \t install_houdini_arm_apk \t [start_num] [end_num]"
	echo -e " 50. \t install_houdini_x86_apk \t [start_num] [end_num]"
	echo -e " 51. \t start_houdini_apk \t\t [start_num] [end_num]"
	echo -e " 52. \t mvscreen_houdini \t\t [start_num] [end_num]"
	echo -e " 53. \t platform \t\t\t [start_num] [end_num]"
	echo -e " 54. \t input_wmsj_720P \t\t [start_num] [end_num]"
	echo -e " 55. \t update_wmsj_720P \t\t [start_num] [end_num]"
	echo -e " 56. \t clean_notice_wmsj_720P \t [start_num] [end_num]"
	echo -e " 57. \t node_cmd \t\t\t [start_num] [end_num]"
	echo -e " 58. \t android_cmd \t\t\t [aic_number] [docker_sh cmd string]"
	echo -e " 59. \t close_templerun_warning \t [start_num] [end_num]"
	echo -e " 60. \t run_templerun \t\t\t [start_num] [end_num]"
	echo

}

main
