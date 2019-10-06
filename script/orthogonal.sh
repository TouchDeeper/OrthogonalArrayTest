#!/bin/bash

#i=1
#SUM=`sed -n '$=' data/L64_4_21.txt` #计算文件的总行数
#echo "$SUM"

acc_n=0.08          # accelerometer measurement noise standard deviation. #0.2   0.04
gyr_n=0.004         # gyroscope measurement noise standard deviation.     #0.05  0.004
acc_w=0.00004         # accelerometer bias random work noise standard deviation.  #0.02
gyr_w=2.0e-6       # gyroscope bias random work noise standard deviation.     #4.0e-5
scale=1
run_num=27
power=1
#power=$(echo "($run_num-1)/2"|bc)

trap 'onCtrlC' INT
keep=1
function onCtrlC () {
    echo 'Ctrl+C is captured'
    keep=0
    kill -9 $rosbag_pid
    echo "kill rosbag_pid"
    kill -9 $euroc_PID
    echo "kill euroc_PID"
    kill -9 $rviz_PID
    echo "kill rviz_PID"
    sed -i "s/^acc_n: .[0-9]*[^[:space:]]*\|^acc_n: \.[^[:space:]]*/acc_n: 0.08/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
    sed -i "s/^acc_w: .[0-9]*[^[:space:]]*\|^acc_w: \.[^[:space:]]*/acc_w: 0.004/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
    sed -i "s/^gyr_n: .[0-9]*[^[:space:]]*\|^gyr_n: \.[^[:space:]]*/gyr_n: 0.00004/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
    sed -i "s/^gyr_w: .[0-9]*[^[:space:]]*\|^gyr_w: \.[^[:space:]]*/gyr_w: 2.0e-6/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
    sed -i "s:^vio_path.*\.txt\"$:vio_path\: \"/home/wang/vins_ws/src/VINS-Mono/output/euroc_result/vio\.txt\":g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml

    exit
}

sed -i "s/^acc_n: .[0-9]*[^[:space:]]*\|^acc_n: \.[^[:space:]]*/acc_n: $acc_n/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
sed -i "s/^acc_w: .[0-9]*[^[:space:]]*\|^acc_w: \.[^[:space:]]*/acc_w: $gyr_n/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
sed -i "s/^gyr_n: .[0-9]*[^[:space:]]*\|^gyr_n: \.[^[:space:]]*/gyr_n: $acc_w/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
sed -i "s/^gyr_w: .[0-9]*[^[:space:]]*\|^gyr_w: \.[^[:space:]]*/gyr_w: $gyr_w/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
sed -i "s:^vio_path.*\.txt\"$:vio_path\: \"/home/wang/vins_ws/src/VINS-Mono/output/euroc_result/vio\.txt\":g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
source ~/vins_ws/devel/setup.bash
test_num=0

while read line
do
   echo $line
   parameters_array[$test_num]="$line"
   let test_num=test_num+1
done < imu_parameters_array.txt

test_num=0

for i in "${!parameters_array[@]}";
do
    echo "i="$i
    IFS=" "
    arr=(${parameters_array[$i]})
    acc_n=${arr[0]}
    acc_w=${arr[1]}
    gyr_n=${arr[2]}
    gyr_w=${arr[3]}
    echo "acc_n="$acc_n",""acc_w="$acc_w",""gyr_n="$gyr_n",""gyr_w="$gyr_w

    sed -i "s/^acc_n: .[0-9]*[^[:space:]]*\|^acc_n: \.[^[:space:]]*/acc_n: $acc_n/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
    sed -i "s/^acc_w: .[0-9]*[^[:space:]]*\|^acc_w: \.[^[:space:]]*/acc_w: $gyr_n/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
    sed -i "s/^gyr_n: .[0-9]*[^[:space:]]*\|^gyr_n: \.[^[:space:]]*/gyr_n: $acc_w/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
    sed -i "s/^gyr_w: .[0-9]*[^[:space:]]*\|^gyr_w: \.[^[:space:]]*/gyr_w: $gyr_w/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
    sed -i "s:^vio_path.*\.txt\"$:vio_path\: \"/home/wang/vins_ws/src/VINS-Mono/output/euroc_result/orthogonal_test/vio$test_num\.txt\":g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
    roslaunch vins_estimator euroc.launch&
    euroc_PID=$!
    echo "euroc_PID = "$euroc_PID
    roslaunch vins_estimator vins_rviz.launch&
    rviz_PID=$!
    echo "rviz_PID = "$rviz_PID
    sleep 1s
    rosbag play -q /media/wang/File/dataset/EuRoc/MH_05_difficult.bag&
    rosbag_pid=$!
    echo "rosbag PID = "$rosbag_pid
    sleep 1s
    isRosbagExist=`ps -ef|grep rosbag|grep -v "grep"|wc -l`
    while [ "$isRosbagExist" -ne "0" ]
    do
        echo "sleep 1s"
        sleep 1s
        isRosbagExist=`ps -ef|grep rosbag|grep -v "grep"|wc -l`
    done
    kill -9 $euroc_PID
    echo "kill euroc_PID"
    kill -9 $rviz_PID
    echo "kill rviz_PID"
    let test_num=test_num+1
done

#while read line
#do
#    echo $line
#    IFS=" "
#    arr=(${line})
#    acc_n=${arr[0]}
#    acc_w=${arr[1]}
#    gyr_n=${arr[2]}
#    gyr_w=${arr[3]}
#
#    sed -i "s/^acc_n: .[0-9]*[^[:space:]]*\|^acc_n: \.[^[:space:]]*/acc_n: $acc_n/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
#    sed -i "s/^acc_w: .[0-9]*[^[:space:]]*\|^acc_w: \.[^[:space:]]*/acc_w: $gyr_n/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
#    sed -i "s/^gyr_n: .[0-9]*[^[:space:]]*\|^gyr_n: \.[^[:space:]]*/gyr_n: $acc_w/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
#    sed -i "s/^gyr_w: .[0-9]*[^[:space:]]*\|^gyr_w: \.[^[:space:]]*/gyr_w: $gyr_w/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
#    sed -i "s:^vio_path.*\.txt\"$:vio_path\: \"/home/wang/vins_ws/src/VINS-Mono/output/euroc_result/orthogonal_test/vio$test_num\.txt\":g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
#    roslaunch vins_estimator euroc.launch&
#    euroc_PID=$!
#    echo "euroc_PID = "$euroc_PID
#    roslaunch vins_estimator vins_rviz.launch&
#    rviz_PID=$!
#    echo "rviz_PID = "$rviz_PID
#    sleep 1s
#    rosbag play -q /media/wang/File/dataset/EuRoc/MH_05_difficult.bag&
#    rosbag_pid=$!
#    echo "rosbag PID = "$rosbag_pid
#    sleep 1s
#    isRosbagExist=`ps -ef|grep rosbag|grep -v "grep"|wc -l`
#    while [ "$isRosbagExist" -ne "0" -a "$keep" -ne "0" ]
#    do
#        echo "sleep 1s"
#        sleep 1s
#        isRosbagExist=`ps -ef|grep rosbag|grep -v "grep"|wc -l`
#        if ["$keep" == "0"];then
#            break 2
#        fi
#    done
#    kill -9 $euroc_PID
#    echo "kill euroc_PID"
#    kill -9 $rviz_PID
#    echo "kill rviz_PID"
#    let test_num=test_num+1
#done < imu_parameters_array.txt

sed -i "s/^acc_n: .[0-9]*[^[:space:]]*\|^acc_n: \.[^[:space:]]*/acc_n: 0.08/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
sed -i "s/^acc_w: .[0-9]*[^[:space:]]*\|^acc_w: \.[^[:space:]]*/acc_w: 0.004/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
sed -i "s/^gyr_n: .[0-9]*[^[:space:]]*\|^gyr_n: \.[^[:space:]]*/gyr_n: 0.00004/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
sed -i "s/^gyr_w: .[0-9]*[^[:space:]]*\|^gyr_w: \.[^[:space:]]*/gyr_w: 2.0e-6/g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml
sed -i "s:^vio_path.*\.txt\"$:vio_path\: \"/home/wang/vins_ws/src/VINS-Mono/output/euroc_result/vio\.txt\":g" ~/vins_ws/src/VINS-Mono/config/euroc/euroc_config.yaml

exit 1