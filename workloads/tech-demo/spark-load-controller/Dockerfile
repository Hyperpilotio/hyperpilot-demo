FROM gettyimages/spark:2.1.0-hadoop-2.7

RUN apt-get update && apt-get install -y vim

WORKDIR $SPARK_HOME
ADD run.sh ./run.sh

ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8088
ENV INFLUXDB_HOST influxsrv
ENV INFLUXDB_NAMESPACE hyperpilot
ENV INFLUXDB_PORT 8086
ENV INFLUXDB_USER root
ENV INFLUXDB_PASS root
ENV INFLUXDB_NAME snap

CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]
