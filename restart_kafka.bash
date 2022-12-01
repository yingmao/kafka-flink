#!/usr/bin/env bash

kafkaVersion=2.8.2
flumeVersion=1.11.0

cluster=$1
eval $(echo $cluster | awk '{split($0, array, ",");for(i in array)print "host_array["i"]="array[i]}')

## local_ip replace localhost in config file
local_host="`hostname`"
local_ip=`host $local_host 2>/dev/null | awk '{print $NF}'`

java_home=`echo $JAVA_HOME`

## current_path replace data_path in config file
current_path=`pwd`
project_root_path=`cd ${current_path}/.. && pwd`
#cd ${current_path}
#project_root_path=${current_path}/../..

echo $project_root_path

cd $project_root_path/deps

echo =========================================================
echo "Restart kafka ($kafkaVersion)"
echo =========================================================
kafka_name=kafka

kafka_home=$project_root_path/deps/${kafka_name}
source ${kafka_home}/bashrc

jps | grep QuorumPeerMain | cut -d' ' -f 1 | xargs kill -9
jps | grep Kafka | cut -d' ' -f 1 | xargs kill -9

for(( i=2;i<=${#host_array[@]};i++)) ; do
#    echo ssh ${host_array[i]} "mkdir -p $project_root_path/deps"
    ssh ${host_array[i]} "source ${kafka_home}/bashrc && jps | grep QuorumPeerMain | cut -d' ' -f 1 | xargs kill -9"
    ssh ${host_array[i]} "source ${kafka_home}/bashrc && jps | grep Kafka | cut -d' ' -f 1 | xargs kill -9"
done

${kafka_home}/bin/zookeeper-server-start.sh -daemon ${kafka_home}/config/zookeeper.properties
for(( i=2;i<=${#host_array[@]};i++)) ; do
    ssh ${host_array[i]} "source ${kafka_home}/bashrc && ${kafka_home}/bin/zookeeper-server-start.sh -daemon ${kafka_home}/config/zookeeper.properties"
done

for(( i=2;i<=${#host_array[@]};i++)) ; do
#    echo ssh ${host_array[i]} "mkdir -p $project_root_path/deps"
#    ssh ${host_array[i]} "source ${kafka_home}/bashrc && jps | grep QuorumPeerMain | cut -d' ' -f 1 | xargs kill -9"
#    ssh ${host_array[i]} "source ${kafka_home}/bashrc && jps | grep Kafka | cut -d' ' -f 1 | xargs kill -9"
#    ssh ${host_array[i]} "source ${kafka_home}/bashrc && ${kafka_home}/bin/zookeeper-server-start.sh -daemon ${kafka_home}/config/zookeeper.properties"
    ssh ${host_array[i]} "source ${kafka_home}/bashrc && ${kafka_home}/bin/kafka-server-start.sh -daemon ${kafka_home}/config/server.properties"
done


source ${kafka_home}/bashrc
#${kafka_home}/bin/zookeeper-server-stop.sh
#${kafka_home}/bin/kafka-server-stop.sh
#jps | grep QuorumPeerMain | cut -d' ' -f 1 | xargs kill -9
#jps | grep Kafka | cut -d' ' -f 1 | xargs kill -9
#${kafka_home}/bin/zookeeper-server-start.sh -daemon ${kafka_home}/config/zookeeper.properties
${kafka_home}/bin/kafka-server-start.sh -daemon ${kafka_home}/config/server.properties

#${flume_home}/bin/flume-ng agent --conf conf/ -f conf/flume-conf.properties -n agent1 -Dflume.root.logger=DEBUG,console

