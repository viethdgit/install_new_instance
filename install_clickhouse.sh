mv elasticsearch-6.8.0 elasticsearch8
cp -r elasticsearch8 elasticsearch9

cat > /opt/elasticsearch8/config/elasticsearch.yml <<END
cluster.name: production
node.name: ${HOSTNAME}_8
node.master: false
node.data: true
###
node.attr.rack: clickhouse
path.data: /datalog/elasticsearch8
path.logs: /var/log/elasticsearch8
bootstrap.memory_lock: true
#
network.host: [_ens7f1.220_, _local_]
http.port: 9208
transport.port: 9308
#
### all master node in discovery.zen.ping.unicast.hosts
discovery.zen.ping.unicast.hosts: ["172.18.10.106:9308","172.18.10.106:9308","172.18.10.108:9308"]
discovery.zen.minimum_master_nodes: 2
#
#gateway.recover_after_nodes: 
#action.destructive_requires_name: true
#
indices.memory.index_buffer_size: 20%
indices.fielddata.cache.size: 10%
indices.breaker.fielddata.limit: 70%
indices.breaker.request.limit: 40%
indices.breaker.total.limit: 70%
#
cluster.routing.allocation.same_shard.host: true

END

cat > /opt/elasticsearch9/config/elasticsearch.yml <<END
cluster.name: production
node.name: ${HOSTNAME}_9
node.master: false
node.data: true
###
node.attr.rack: clickhouse
path.data: /datalog/elasticsearch9
path.logs: /var/log/elasticsearch9
bootstrap.memory_lock: true
#
network.host: [_ens7f1.220_, _local_]
http.port: 9209
transport.port: 9309
#
### all master node in discovery.zen.ping.unicast.hosts
discovery.zen.ping.unicast.hosts: ["172.18.10.106:9308","172.18.10.106:9308","172.18.10.108:9308"]
discovery.zen.minimum_master_nodes: 2
#
#gateway.recover_after_nodes: 
#action.destructive_requires_name: true
#
indices.memory.index_buffer_size: 20%
indices.fielddata.cache.size: 10%
indices.breaker.fielddata.limit: 70%
indices.breaker.request.limit: 40%
indices.breaker.total.limit: 70%
#
cluster.routing.allocation.same_shard.host: true

END

cat > /etc/systemd/system/elasticsearch8.service <<END
[Unit]
Description=Elasticsearch
Documentation=http://www.elastic.co
Wants=network-online.target
After=network-online.target

[Service]
RuntimeDirectory=elasticsearch
PrivateTmp=true
Environment=ES_HOME=/opt/elasticsearch8
Environment=ES_PATH_CONF=/opt/elasticsearch8/config
Environment=PID_DIR=/var/run/elasticsearch
EnvironmentFile=-/etc/sysconfig/elasticsearch8
LimitMEMLOCK=infinity

WorkingDirectory=/opt/elasticsearch8

User=elasticsearch
Group=elasticsearch

ExecStart=/opt/elasticsearch8/bin/elasticsearch -p \${PID_DIR}/elasticsearch8.pid --quiet

StandardOutput=journal
StandardError=inherit

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65535

# Specifies the maximum number of processes
LimitNPROC=4096

# Specifies the maximum size of virtual memory
LimitAS=infinity

# Specifies the maximum file size
LimitFSIZE=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=0

# SIGTERM signal is used to stop the Java process
KillSignal=SIGTERM

# Send the signal only to the JVM rather than its control group
KillMode=process

# Java process is never killed
SendSIGKILL=no

# When a JVM receives a SIGTERM signal it exits with code 143
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target

# Built for packages-6.8.0 (packages)
END

cat > /etc/systemd/system/elasticsearch9.service <<END
[Unit]
Description=Elasticsearch
Documentation=http://www.elastic.co
Wants=network-online.target
After=network-online.target

[Service]
RuntimeDirectory=elasticsearch
PrivateTmp=true
Environment=ES_HOME=/opt/elasticsearch9
Environment=ES_PATH_CONF=/opt/elasticsearch9/config
Environment=PID_DIR=/var/run/elasticsearch
EnvironmentFile=-/etc/sysconfig/elasticsearch9
LimitMEMLOCK=infinity

WorkingDirectory=/opt/elasticsearch9

User=elasticsearch
Group=elasticsearch

ExecStart=/opt/elasticsearch9/bin/elasticsearch -p \${PID_DIR}/elasticsearch9.pid --quiet

StandardOutput=journal
StandardError=inherit

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65535

# Specifies the maximum number of processes
LimitNPROC=4096

# Specifies the maximum size of virtual memory
LimitAS=infinity

# Specifies the maximum file size
LimitFSIZE=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=0

# SIGTERM signal is used to stop the Java process
KillSignal=SIGTERM

# Send the signal only to the JVM rather than its control group
KillMode=process

# Java process is never killed
SendSIGKILL=no

# When a JVM receives a SIGTERM signal it exits with code 143
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target

# Built for packages-6.8.0 (packages)
END

cat > /etc/sysconfig/elasticsearch8 <<END
ES_HOME=/opt/elasticsearch8
CONF_DIR=/opt/elasticsearch8/config
DATA_DIR=/datalog/elasticsearch8
LOG_DIR=/var/log/elasticsearch8
#PID_DIR=/var/run/elasticsearch
ES_HEAP_SIZE=2000m
#ES_HEAP_NEWSIZE=
#ES_DIRECT_SIZE=
#ES_JAVA_OPTS=
#RESTART_ON_UPGRADE=true
ES_GC_LOG_FILE=/var/log/elasticsearch8/gc.log
#ES_USER=elasticsearch
#ES_GROUP=elasticsearch
ES_STARTUP_SLEEP_TIME=5
MAX_OPEN_FILES=65536
MAX_LOCKED_MEMORY=unlimited
END

cat > /etc/sysconfig/elasticsearch9 <<END
ES_HOME=/opt/elasticsearch9
CONF_DIR=/opt/elasticsearch9/config
DATA_DIR=/datalog/elasticsearch9
LOG_DIR=/var/log/elasticsearch9
#PID_DIR=/var/run/elasticsearch
ES_HEAP_SIZE=2000m
#ES_HEAP_NEWSIZE=
#ES_DIRECT_SIZE=
#ES_JAVA_OPTS=
#RESTART_ON_UPGRADE=true
ES_GC_LOG_FILE=/var/log/elasticsearch9/gc.log
#ES_USER=elasticsearch
#ES_GROUP=elasticsearch
ES_STARTUP_SLEEP_TIME=5
MAX_OPEN_FILES=65536
MAX_LOCKED_MEMORY=unlimited
END

cat > /opt/elasticsearch8/config/jvm.options <<END
-Xms2g
-Xmx2g
-XX:+UseConcMarkSweepGC
-XX:CMSInitiatingOccupancyFraction=75
-XX:+UseCMSInitiatingOccupancyOnly
-Des.networkaddress.cache.ttl=60
-Des.networkaddress.cache.negative.ttl=10
-XX:+AlwaysPreTouch
-Xss2m
-Djava.awt.headless=true
-Dfile.encoding=UTF-8
-Djna.nosys=true
-XX:-OmitStackTraceInFastThrow
-Dio.netty.noUnsafe=true
-Dio.netty.noKeySetOptimization=true
-Dio.netty.recycler.maxCapacityPerThread=0
-Dlog4j.shutdownHookEnabled=false
-Dlog4j2.disable.jmx=true

-Djava.io.tmpdir=\${ES_TMPDIR}
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=data
-XX:ErrorFile=logs/hs_err_pid%p.log
8:-XX:+PrintGCDetails
8:-XX:+PrintGCDateStamps
8:-XX:+PrintTenuringDistribution
8:-XX:+PrintGCApplicationStoppedTime
8:-Xloggc:logs/gc.log
8:-XX:+UseGCLogFileRotation
8:-XX:NumberOfGCLogFiles=32
8:-XX:GCLogFileSize=64m
9-:-Xlog:gc*,gc+age=trace,safepoint:file=logs/gc.log:utctime,pid,tags:filecount=32,filesize=64m
9-:-Djava.locale.providers=COMPAT
10-:-XX:UseAVX=2
END

cat > /opt/elasticsearch8/config/jvm.options <<END
-Xms2g
-Xmx2g
-XX:+UseConcMarkSweepGC
-XX:CMSInitiatingOccupancyFraction=75
-XX:+UseCMSInitiatingOccupancyOnly
-Des.networkaddress.cache.ttl=60
-Des.networkaddress.cache.negative.ttl=10
-XX:+AlwaysPreTouch
-Xss2m
-Djava.awt.headless=true
-Dfile.encoding=UTF-8
-Djna.nosys=true
-XX:-OmitStackTraceInFastThrow
-Dio.netty.noUnsafe=true
-Dio.netty.noKeySetOptimization=true
-Dio.netty.recycler.maxCapacityPerThread=0
-Dlog4j.shutdownHookEnabled=false
-Dlog4j2.disable.jmx=true

-Djava.io.tmpdir=\${ES_TMPDIR}
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=data
-XX:ErrorFile=logs/hs_err_pid%p.log
8:-XX:+PrintGCDetails
8:-XX:+PrintGCDateStamps
8:-XX:+PrintTenuringDistribution
8:-XX:+PrintGCApplicationStoppedTime
8:-Xloggc:logs/gc.log
8:-XX:+UseGCLogFileRotation
8:-XX:NumberOfGCLogFiles=32
8:-XX:GCLogFileSize=64m
9-:-Xlog:gc*,gc+age=trace,safepoint:file=logs/gc.log:utctime,pid,tags:filecount=32,filesize=64m
9-:-Djava.locale.providers=COMPAT
10-:-XX:UseAVX=2
END

cat > /opt/elasticsearch9/config/jvm.options <<END
-Xms2g
-Xmx2g
-XX:+UseConcMarkSweepGC
-XX:CMSInitiatingOccupancyFraction=75
-XX:+UseCMSInitiatingOccupancyOnly
-Des.networkaddress.cache.ttl=60
-Des.networkaddress.cache.negative.ttl=10
-XX:+AlwaysPreTouch
-Xss2m
-Djava.awt.headless=true
-Dfile.encoding=UTF-8
-Djna.nosys=true
-XX:-OmitStackTraceInFastThrow
-Dio.netty.noUnsafe=true
-Dio.netty.noKeySetOptimization=true
-Dio.netty.recycler.maxCapacityPerThread=0
-Dlog4j.shutdownHookEnabled=false
-Dlog4j2.disable.jmx=true

-Djava.io.tmpdir=\${ES_TMPDIR}
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=data
-XX:ErrorFile=logs/hs_err_pid%p.log
8:-XX:+PrintGCDetails
8:-XX:+PrintGCDateStamps
8:-XX:+PrintTenuringDistribution
8:-XX:+PrintGCApplicationStoppedTime
8:-Xloggc:logs/gc.log
8:-XX:+UseGCLogFileRotation
8:-XX:NumberOfGCLogFiles=32
8:-XX:GCLogFileSize=64m
9-:-Xlog:gc*,gc+age=trace,safepoint:file=logs/gc.log:utctime,pid,tags:filecount=32,filesize=64m
9-:-Djava.locale.providers=COMPAT
10-:-XX:UseAVX=2
END

mkdir /datalog/elasticsearch8 /var/log/elasticsearch8 /var/run/elasticsearch /datalog/elasticsearch9 /var/log/elasticsearch9
chown -R elasticsearch:elasticsearch /opt/elasticsearch8 /var/run/elasticsearch /etc/sysconfig/elasticsearch8 /datalog/elasticsearch8 /var/log/elasticsearch8 /opt/elasticsearch9 /etc/sysconfig/elasticsearch9 /datalog/elasticsearch9 /var/log/elasticsearch9


echo "Done!"
echo "####-> run test: sudo -u elasticsearch /opt/elasticsearch8/bin/elasticsearch /var/run/elasticsearch/elasticsearch8.pid"