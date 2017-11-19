#!/bin/bash -e

# brokers. host:port
if [ -z $BOOTSTRAP_SERVERS ] ; then
    BOOTSTRAP_SERVERS=broker:9092
fi
sed -i "s/BOOTSTRAP_SERVERS/$BOOTSTRAP_SERVERS/" /kafka/connect-worker.properties

# topics to listen to
sed -i "s/KAFKA_TOPICS/$KAFKA_TOPICS/" /kafka/connect-s3-sink.properties

# bucket and prefix to save data to
sed -i "s/S3_BUCKET/$S3_BUCKET/" /kafka/connect-s3-sink.properties
if [ -z $S3_PREFIX ]; then
    S3_PREFIX=default-prefix
fi
sed -i "s/S3_PREFIX/$S3_PREFIX/" /kafka/connect-s3-sink.properties

# S3 bucket access credentials
mkdir -p /home/docker/.aws
echo "[default]
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
" > /home/docker/.aws/credentials
chmod -R 600 /home/docker/.aws
chown -R docker /home/docker/.aws

# run the S3 sink
export CLASSPATH=/kafka/kafka-connect-s3-0.0.3-jar-with-dependencies.jar
exec /kafka/bin/connect-standalone.sh /kafka/connect-worker.properties /kafka/connect-s3-sink.properties
