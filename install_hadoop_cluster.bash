#!/usr/bin/env bash

mirrorServer=https://dist.apache.org/repos/dist/release
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
echo "Install Hadoop ($hadoopVersion) and Flink ($flinkVersion)"
echo =========================================================
hadoop_name=hadoop
flink_name=flink_hadoop_bin
#if [ -d "$hadoop_name" ] && [ -d "$flink_name" ]; then
#    echo "hadoop and flink exist!"
#    exit 2
#fi

hadoop_home=$project_root_path/deps/${hadoop_name}
if [ ! -d "$hadoop_name" ]; then
    if [ ! -f "hadoop-$hadoopVersion.tar.gz" ]; then
        wget $mirrorServer/hadoop/common/hadoop-$hadoopVersion/hadoop-$hadoopVersion.tar.gz
    fi
    tar -zxvf hadoop-$hadoopVersion.tar.gz
    mv hadoop-$hadoopVersion ${hadoop_name}
    cp -r ${current_path}/hadoop/* ${hadoop_home}/
    echo "Changing hadoop config files..."
    cd ${hadoop_name}/etc/hadoop
    find . -type f -print0 | xargs -0 sed -i "s/localhost/$local_ip/g"
    find . -type f -print0 | xargs -0 sed -i "s#data_path#$hadoop_home#g"
    for item in ${host_array[@]}; do
        echo $item > slaves
    done
    cd ../../..
    echo "export HADOOP_HOME=${hadoop_home}" > ${hadoop_home}/bashrc
    echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))" >> ${hadoop_home}/bashrc
    cat ${current_path}/bashrc/hadoop_bashrc >> ${hadoop_home}/bashrc
fi
source ${hadoop_home}/bashrc

flink_home=$project_root_path/deps/${flink_name}
if [ ! -d "$flink_name" ]; then
    if [ ! -f "flink-$flinkVersion-bin-scala_2.12.tgz" ]; then
        wget $mirrorServer/flink/flink-$flinkVersion/flink-$flinkVersion-bin-scala_2.12.tgz
    fi
    tar -zxvf flink-$flinkVersion-bin-scala_2.12.tgz
    mv flink-$flinkVersion ${flink_name}
    cp -r ${current_path}/flink/* ${flink_home}/
    #echo "Changing flink config file..."
    #cd ${flink_name}/conf
    #find . -type f -print0 | xargs -0 sed -i "s/localhost/$local_ip/g"
    #cd ../..
    echo "export FLINK_HOME=${flink_home}" > ${flink_home}/bashrc
    cat ${current_path}/bashrc/flink_bashrc >> ${flink_home}/bashrc
fi
source ${flink_home}/bashrc

echo ===========================
echo Run Flink Example WordCount
echo ===========================
#hdfs namenode -format
hadoop-daemon.sh stop namenode
hadoop-daemon.sh stop datanode
yarn-daemon.sh stop resourcemanager
yarn-daemon.sh stop nodemanager
mr-jobhistory-daemon.sh stop historyserver

hdfs namenode -format
hadoop-daemon.sh start namenode
hadoop-daemon.sh start datanode
yarn-daemon.sh start resourcemanager
yarn-daemon.sh start nodemanager
mr-jobhistory-daemon.sh start historyserver

# nc -l 9002
#flink run -m yarn-cluster  -yjm 1024 -ytm 1024 ${flink_home}/examples/streaming/SocketWindowWordCount.jar --hostname ${local_ip} --port 9002
#flink run-application -t yarn-application -p 3 -Dparallelism.default=3 -Djobmanager.memory.process.size=1024m -Dtaskmanager.memory.process.size=1024m -Dtaskmanager.numberOfTaskSlots=2 -Dyarn.application.name="application_test" ./examples/streaming/SocketWindowWordCount.jar --hostname $local_ip --port 9002

if [ $? -ne 0 ]; then
    echo "Install flink on yarn error!"
    exit 2
fi


echo ========================
echo Install cluster
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
    ssh ${host_array[i]} "mkdir -p $project_root_path/deps"
    echo "rsync -r ${hadoop_home} ${host_array[i]}:$project_root_path/deps/"
    echo "yes" | rsync -r ${hadoop_home} ${host_array[i]}:$project_root_path/deps/
    rsync -r ${flink_home} ${host_array[i]}:$project_root_path/deps/
    ssh ${host_array[i]} "rm -rf ${hadoop_home}/hadoop_file/hadoop/*"
    ssh ${host_array[i]} "source ${hadoop_home}/bashrc && ${hadoop_home}/sbin/hadoop-daemon.sh start datanode"
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
