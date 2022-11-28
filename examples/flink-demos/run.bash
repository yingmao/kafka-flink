



# nc -l 9002

#${flink_home} 是安装脚本目录的同级目录deps/flink_hadoop_bin
#source ${flink_home}/bashrc

${flink_home}/bin/flink run -m yarn-cluster  -yjm 1024 -ytm 1024 ${flink_home}/examples/streaming/SocketWindowWordCount.jar --hostname ${local_ip} --port 9002


