#!/bin/bash

SPARK_MASTER_PORT=7077
SPARK_MASTER_WEBUI_PORT=8088
INFLUXDB_HOST=influxsrv
INFLUXDB_NAMESPACE=hyperpilot
INFLUXDB_PORT=8086
INFLUXDB_NAME=spark

# check if spark master service is running
SPARK_MASTER="$(hostname -i):6066"
spark_master_no=`ps -ef | grep spark | grep master | wc -l`
if [ $spark_master_no -eq 0 ]; then
        echo Spark master service is NOT RUNNING
        exit
else
        echo Spark master service is RUNNING at ${SPARK_MASTER}.
fi

INFLUXDB_URL=http://${INFLUXDB_HOST}.${INFLUXDB_NAMESPACE}:${INFLUXDB_PORT}

if [ $# -gt 0 ]; then
        JOB_LIMIT=$1
else
        JOB_LIMIT=10
fi
count=1
jobs_finished=0

# continuously submit jobs to the spark master
until [ $count -gt $JOB_LIMIT ]; do
        echo Submitting spark job no. $count
        ./bin/spark-submit --master=spark://$SPARK_MASTER --deploy-mode=cluster --executor-memory 1g --driver-memory 2g --class MovieLensALS s3://hyperpilot-jarfiles/movielens-als-assembly-2.11-0.1.jar s3://demo-analysis-datasets/movielens/medium/ s3://demo-analysis-datasets/personalRatings.txt 2>job.out
        job_id=`cat job.out | grep submissionId | cut -d":" -f2 | cut -d "\"" -f2`
        echo Spark submission $job_id is submitted

        ((count++))
        job_done=0

        # check progress of submitted spark jobs and post updates to influxDB
        until [[ $job_done -gt 0 ]]; do
                if [ $job_done -eq 0 ]; then
                        curl http://$SPARK_MASTER/v1/submissions/status/$job_id > status.out
                        job_status=`cat status.out | grep driverState | cut -d":" -f2 | cut -d "\"" -f2`
                        worker_id=`cat status.out | grep workerId | cut -d":" -f2 | cut -d "\"" -f2`
                        if [[ $job_status = "FINISHED" || $job_status = "FAILED" || $job_status = "KILLED" || $job_status = "ERROR" ]]; then
                                echo Spark submission $job_id has $job_status
                                job_done=1
                                echo hyperpilot/spark/spark_jobs_finished,worker_id=$worker_id,submission_id=$job_id,status=$job_status value=$job_done > keyvalue.txt
                                curl -s -XPOST $INFLUXDB_URL/write?db=$INFLUXDB_NAME --data-binary @keyvalue.txt > /dev/null
                                if [ $job_status = "FINISHED" ]; then
                                        ((jobs_finished++))
                                fi
                        else
                                echo Spark submission $job_id is still running
                        fi
                fi

                echo Number of finished spark jobs = $jobs_finished

                sleep 10
        done
done
