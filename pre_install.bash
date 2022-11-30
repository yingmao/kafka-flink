#!/usr/bin/env bash

cluster=$1
eval $(echo $cluster | awk '{split($0, array, ",");for(i in array)print "host_array["i"]="array[i]}')

for(( i=2;i<=${#host_array[@]};i++)) ; do
#    echo ssh ${host_array[i]} "apt update"
    ssh ${host_array[i]} "apt update"
    ssh ${host_array[i]} "apt install openjdk-8-jdk-headless"
done

apt update
apt install openjdk-8-jdk-headless
apt install python3-pip
pip3 install Kafka-python
