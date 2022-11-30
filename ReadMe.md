
## Install Flink and Kafka on a 3-node Hadoop cluster


- Make sure your manager node can `ssh` to the other 2 worker nodes

### Switch to root and Download the source code

- `su root`
- `cd /`
- `git clone https://github.com/yingmao/kafka-flink.git`

### Install the programming environment

- `cd /kafka-flink/`
- `bash pre_install.bash`

### Install Kafka

- `bash install_kafka_cluster.bash manager-internal-ip,worker-1-internal-ip,worker-2-internal-ip`

### Install Flink on Hadoop

- `bash install_flink_on_hadoop_cluster.bash manager-internal-ip,worker-1-internal-ip,worker-2-internal-ip`
