#!/bin/bash
echo "downloading wget"
sudo  yum -y install wget

echo "downloading kafka...$KAFKA_VERSION"

#download kafka binaries if not present
if [ ! -f  $KAFKA_TARGET/$KAFKA_NAME.tgz ]; then
   mkdir -p $KAFKA_TARGET
   wget -O "$KAFKA_TARGET/$KAFKA_NAME.tgz" https://archive.apache.org/dist/kafka/"$KAFKA_VERSION/$KAFKA_NAME.tgz"
fi

echo "installing JDK and Kafka..."

sudo  yum -y install java-1.8.0-openjdk-devel


if [ ! -d $KAFKA_NAME ]; then 
   tar -zxvf $KAFKA_TARGET/$KAFKA_NAME.tgz
fi

chown vagrant:vagrant -R $KAFKA_NAME

echo "done installing JDK and Kafka..."

# chmod scripts
chmod u+x /vagrant/scripts/*.sh
