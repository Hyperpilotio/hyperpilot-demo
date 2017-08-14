#!/usr/bin/env python

import random

SPARK_PI="./bin/spark-submit --master=spark://spark-master.default:6066 --deploy-mode=cluster --driver-cores %d --executor-cores %d --total-executor-cores %d --executor-memory %s --driver-memory %s --class org.apache.spark.examples.SparkPi file:///usr/spark-2.1.0/examples/jars/spark-examples_2.11-2.1.0.jar 100000"

TERASORT="./bin/spark-submit --master=spark://spark-master.default:6066 --deploy-mode=cluster --driver-cores %d --executor-cores %d --total-executor-cores %d --executor-memory %s --driver-memory %s --class com.github.ehiggs.spark.terasort.TeraSort s3://hyperpilot-jarfiles/spark-terasort-1.1-SNAPSHOT-jar-with-dependencies.jar s3://demo-analysis-datasets/terasort_in_1g/ /tmp/terasort_out"

class SparkParams(object):
    def __init__(self, template, driverCores, executorCores, executorCount, executorMemory, driverMemory):
        self.driverCores = driverCores
        self.executorCores = executorCores
        self.executorCount = executorCount
        self.executorMemory = executorMemory
        self.driverMemory = driverMemory
        self.template = template

    def command(self):
        return self.template % (self.driverCores, \
                         self.executorCores, \
                         self.executorCores * self.executorCount, \
                         self.executorMemory, \
                         self.driverMemory)

SparkPiSmall = SparkParams(SPARK_PI, 1, 1, 1, "1g", "1g")
SparkPiMedium = SparkParams(SPARK_PI, 1, 1, 2, "1g", "1g")
SparkPiLarge = SparkParams(SPARK_PI, 1, 1, 3, "1g", "1g")

TerasortSmall = SparkParams(TERASORT, 1, 1, 1, "1g", "2g")
TerasortMedium = SparkParams(TERASORT, 1, 1, 2, "1g", "2g")
TerasortLarge = SparkParams(TERASORT, 1, 1, 3, "1g", "2g")

# NOTE Use a small spark job for POC purpose
# ALL_AVAILABLE_JOBS = [ TerasortSmall, TerasortMedium, TerasortLarge ]
ALL_AVAILABLE_JOBS = [ SparkPiSmall ]

def get_command():
    return random.choice(ALL_AVAILABLE_JOBS).command()

if __name__ == "__main__":
    print(random.choice(ALL_AVAILABLE_JOBS).command())
