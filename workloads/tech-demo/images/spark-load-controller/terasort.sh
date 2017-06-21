#!/bin/bash

SPARK_MASTER=spark-master.default:6066

./bin/spark-submit --master=spark://$SPARK_MASTER --deploy-mode=cluster --executor-cores 1 --total-executor-cores 2 --executor-memory 1g --driver-memory 2g --class com.github.ehiggs.spark.terasort.TeraSort s3://hyperpilot-jarfiles/spark-terasort-1.1-SNAPSHOT-jar-with-dependencies.jar s3://demo-analysis-datasets/terasort_in_1g/ /tmp/terasort_out
