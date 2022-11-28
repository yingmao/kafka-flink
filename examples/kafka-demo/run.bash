

# ${kafka_home} is /deps/kafka

#source ${kafka_home}/bashrc
#${kafka_home}/bin/zookeeper-server-start.sh -daemon ${kafka_home}/config/zookeeper.properties
#${kafka_home}/bin/kafka-server-start.sh -daemon ${kafka_home}/config/server.properties


python3 producer.py  ip:port #broker ip:port
python3 consumter.py ip:port


