#!/bin/bash
JMX_JAR=jmx_prometheus_javaagent-0.13.0.jar

if [ -f $KAFKA_HOME/libs/$JMX_JAR ]
then 
 echo " ${JMX_JAR} Jar exist"
else 
 cd  $KAFKA_HOME/libs/
 wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.13.0/jmx_prometheus_javaagent-0.13.0.jar
 sed -i '$ i\export KAFKA_OPTS="'"-javaagent:$KAFKA_HOME/libs/jmx_prometheus_javaagent-0.13.0.jar=7075:$KAFKA_HOME/config/sample_jmx_exporter.yml"'"'  $KAFKA_HOME/bin/kafka-server-start.sh 
fi

if [ -f  $KAFKA_HOME/config/sample_jmx_exporter.yml ]
then
  echo "configuration already done"

else

echo "jmx exporter configration"
bash -c 'cat << EOF > $KAFKA_HOME/config/sample_jmx_exporter.yml 
lowercaseOutputName: true

rules:
 # Special cases and very specific rules
 - pattern : kafka.server<type=(.+), name=(.+), clientId=(.+), topic=(.+), partition=(.*)><>Value
   name: kafka_server_\$1_\$2
   type: GAUGE
   labels:
     clientId: "\$3"
     topic: "\$4"
     partition: "\$5"
 - pattern : kafka.server<type=(.+), name=(.+), clientId=(.+), brokerHost=(.+), brokerPort=(.+)><>Value
   name: kafka_server_\$1_\$2
   type: GAUGE
   labels:
     clientId: "\$3"
     broker: "\$4:\$5"
 - pattern : kafka.coordinator.(\w+)<type=(.+), name=(.+)><>Value
   name: kafka_coordinator_\$1_\$2_\$3
   type: GAUGE

 # Generic per-second counters with 0-2 key/value pairs
 - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*, (.+)=(.+), (.+)=(.+)><>Count
   name: kafka_\$1_\$2_\$3_total
   type: COUNTER
   labels:
     "\$4": "\$5"
     "\$6": "\$7"
 - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*, (.+)=(.+)><>Count
   name: kafka_\$1_\$2_\$3_total
   type: COUNTER
   labels:
     "\$4": "\$5"
 - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*><>Count
   name: kafka_\$1_\$2_\$3_total
   type: COUNTER

 - pattern: kafka.server<type=(.+), client-id=(.+)><>([a-z-]+)
   name: kafka_server_quota_\$3
   type: GAUGE
   labels:
     resource: "\$1"
     clientId: "\$2"

 - pattern: kafka.server<type=(.+), user=(.+), client-id=(.+)><>([a-z-]+)
   name: kafka_server_quota_\$4
   type: GAUGE
   labels:
     resource: "\$1"
     user: "\$2"
     clientId: "\$3"

 # Generic gauges with 0-2 key/value pairs
 - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Value
   name: kafka_\$1_\$2_\$3
   type: GAUGE
   labels:
     "\$4": "\$5"
     "\$6": "\$7"
 - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+)><>Value
   name: kafka_\$1_\$2_\$3
   type: GAUGE
   labels:
     "\$4": "\$5"
 - pattern: kafka.(\w+)<type=(.+), name=(.+)><>Value
   name: kafka_\$1_\$2_\$3
   type: GAUGE

 # Emulate Prometheus 'Summary' metrics for the exported 'Histogram's.
 #
 # Note that these are missing the '_sum' metric!
 - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Count
   name: kafka_\$1_\$2_\$3_count
   type: COUNTER
   labels:
     "\$4": "\$5"
     "\$6": "\$7"
 - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.*), (.+)=(.+)><>(\d+)thPercentile
   name: kafka_\$1_\$2_\$3
   type: GAUGE
   labels:
     "\$4": "\$5"
     "\$6": "\$7"
     quantile: "0.\$8"
 - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+)><>Count
   name: kafka_\$1_\$2_\$3_count
   type: COUNTER
   labels:
     "\$4": "\$5"
 - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.*)><>(\d+)thPercentile
   name: kafka_\$1_\$2_\$3
   type: GAUGE
   labels:
     "\$4": "\$5"
     quantile: "0.\$6"
 - pattern: kafka.(\w+)<type=(.+), name=(.+)><>Count
   name: kafka_\$1_\$2_\$3_count
   type: COUNTER
 - pattern: kafka.(\w+)<type=(.+), name=(.+)><>(\d+)thPercentile
   name: kafka_\$1_\$2_\$3
   type: GAUGE
   labels:
     quantile: "0.\$4"
EOF'
fi