#!/usr/bin/env bash

hadoopVersion=3.2.3
flinkVersion=1.16.0

cluster=$1
eval $(echo $cluster | awk '{split($0, array, ",");for(i in array)print "host_array["i"]="array[i]}')

## local_ip replace localhost in config file
local_host="`hostname`"
local_ip=`host $local_host 2>/dev/null | awk '{print $NF}' | tail -1`

java_home=`echo $JAVA_HOME`

## current_path replace data_path in config file
current_path=`pwd`
project_root_path=`cd ${current_path}/.. && pwd`
#cd ${current_path}
#project_root_path=${current_path}/../..

echo $project_root_path

# if not exist, mkdir 
cd $project_root_path/deps


echo =========================================================
echo "Restart Hadoop ($hadoopVersion) and Flink ($flinkVersion)"
echo =========================================================
hadoop_name=hadoop
flink_name=flink_hadoop_bin
#if [ -d "$hadoop_name" ] && [ -d "$flink_name" ]; then
#    echo "hadoop and flink exist!"
#    exit 2
#fi

hadoop_home=$project_root_path/deps/${hadoop_name}
source ${hadoop_home}/bashrc

flink_home=$project_root_path/deps/${flink_name}

hadoop-daemon.sh stop namenode
hadoop-daemon.sh stop datanode
yarn-daemon.sh stop resourcemanager
yarn-daemon.sh stop nodemanager
mr-jobhistory-daemon.sh stop historyserver

#hdfs namenode -format
hadoop-daemon.sh start namenode
hadoop-daemon.sh start datanode
yarn-daemon.sh start resourcemanager
yarn-daemon.sh start nodemanager
mr-jobhistory-daemon.sh start historyserver

# nc -l 9002
#flink run -m yarn-cluster  -yjm 1024 -ytm 1024 ${flink_home}/examples/streaming/SocketWindowWordCount.jar --hostname ${local_ip} --port 9002
#flink run-application -t yarn-application -p 3 -Dparallelism.default=3 -Djobmanager.memory.process.size=1024m -Dtaskmanager.memory.process.size=1024m -Dtaskmanager.numberOfTaskSlots=2 -Dyarn.application.name="application_test" ./examples/streaming/SocketWindowWordCount.jar --hostname $local_ip --port 9002


echo ========================
echo Start cluster
echo ========================

echo "Make sure the machines in the cluster can ssh each other"
echo "Yes(y) or No(n)"
read flag
case $flag in
	Y|y) echo "you input  $flag !"
	    echo scp hadoop and spark to other machines
	;;
	N|n) echo "you input  $flag !"
	    exit 0
	;;
esac

for(( i=2;i<=${#host_array[@]};i++)) ; do
    # echo ssh ${host_array[i]} "mkdir -p ${current_path}"
    ssh ${host_array[i]} "source ${hadoop_home}/bashrc && ${hadoop_home}/sbin/hadoop-daemon.sh stop datanode"
    ssh ${host_array[i]} "source ${hadoop_home}/bashrc && ${hadoop_home}/sbin/hadoop-daemon.sh start datanode"
    ssh ${host_array[i]} "source ${hadoop_home}/bashrc && ${hadoop_home}/sbin/yarn-daemon.sh stop nodemanager"
    ssh ${host_array[i]} "source ${hadoop_home}/bashrc && ${hadoop_home}/sbin/yarn-daemon.sh start nodemanager"
done

#for item in ${host_array[@]}
#do
#    scp -r ${hadoop_home} $item:${current_path}/
#    scp -r ${spark_home} $item:${current_path}/
#done

#hadoop-daemon.sh stop datanode
#hadoop-daemons.sh start datanode
#yarn-daemons.sh stop nodemanager
#yarn-daemons.sh start nodemanager

echo ========================== DONE =============================
