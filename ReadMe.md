##
args is cluster hostname, separate with a comma...
`bash install_hadoop_cluster.bash host1,host2,host3`
*The first one is master.*

## yarn web ui is master_ip:7438
## namenode web ui is master_ip:9870

## flink
nc -l 9002 # 运行flink example


## kafka test
``` shell
source ${KAFKA_HOME}/bashrc
kafka-topics.sh --create --bootstrap-server 128.110.217.182:9092,128.110.217.164:9092,128.110.217.191:9092 --replication-factor 3 --partitions 1 --topic test

kafka-topics.sh --list --bootstrap-server 128.110.217.182:9092,128.110.217.164:9092,128.110.217.191:9092

kafka-console-producer.sh --broker-list 128.110.217.182:9092,128.110.217.164:9092,128.110.217.191:9092  --topic test

kafka-console-consumer.sh --bootstrap-server 128.110.217.182:9092,128.110.217.164:9092,128.110.217.191:9092 --topic test --from-beginning
```

## flume
log to kafka
wget https://dlcdn.apache.org/flume/1.11.0/apache-flume-1.11.0-bin.tar.gz
echo hello flume >> /tmp/flumetest.log

cd ${flume_home}
bin/flume-ng agent --conf conf/ -f conf/flume-conf.properties -n agent1 -Dflume.root.logger=DEBUG,console

## Note:
If you want install a cluster, Make sure the machines in the cluster can ssh each other.
use `ssh-keygen -t rsa`
