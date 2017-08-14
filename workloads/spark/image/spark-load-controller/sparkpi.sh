#!/bin/bash

SPARK_MASTER=localhost:6066
# SPARK_MASTER=spark-master.default:6066

./bin/spark-submit --master=spark://$SPARK_MASTER --deploy-mode=cluster --executor-cores 1 --total-executor-cores 2 --executor-memory 1g --driver-memory 2g --class org.apache.spark.examples.SparkPi file:///usr/spark-2.1.0/examples/jars/spark-examples_2.11-2.1.0.jar
