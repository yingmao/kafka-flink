

current_path=`pwd`
project_root_path=`cd ${current_path}/../../.. && pwd`

hadoop_name=hadoop
flink_name=flink_hadoop_bin

hadoop_home=$project_root_path/deps/${hadoop_name}
flink_home=$project_root_path/deps/${flink_name}

source ${hadoop_home}/bashrc
source ${flink_home}/bashrc


${flink_home}/bin/flink run -m yarn-cluster  -yjm 1024 -ytm 1024 ${flink_home}/examples/streaming/SocketWindowWordCount.jar --hostname 127.0.0.1 --port $1


