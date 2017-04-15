#!/bin/bash

SPARK_MASTER=spark-master.default:6066
SPARK_WORKER=spark-worker.default:8081
SPARK_WORKER_2=spark-worker-2.default:8081
INFLUXDB_HOST=influxsrv
INFLUXDB_NAMESPACE=hyperpilot
INFLUXDB_PORT=8086
INFLUXDB_NAME=spark

INFLUXDB_URL=http://${INFLUXDB_HOST}.${INFLUXDB_NAMESPACE}:${INFLUXDB_PORT}

count=1
jobs_finished=0

# continuously submit jobs to the spark master
while true; do
        echo Submitting spark job no. $count
        ./bin/spark-submit --master=spark://$SPARK_MASTER --deploy-mode=cluster --executor-cores 1 --total-executor-cores 3 --executor-memory 1g --driver-memory 2g --class MovieLensALS s3://hyperpilot-jarfiles/movielens-als-assembly-2.11-0.1.jar s3://demo-analysis-datasets/movielens/large/ s3://demo-analysis-datasets/personalRatings.txt 2>job.out
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
				sleep 10
                        fi
                fi

                echo Number of finished spark jobs = $jobs_finished

                # check number of running drivers (or jobs)

		worker1_drivers=`curl http://$SPARK_WORKER/v1 | grep "Running Drivers" | cut -d"(" -f2 | cut -d")" -f1`
		worker2_drivers=`curl http://$SPARK_WORKER_2/v1 | grep "Running Drivers" | cut -d"(" -f2 | cut -d")" -f1`
		((total_drivers=worker1_drivers+worker2_drivers))
		echo hyperpilot/spark/spark_running_count,entity="driver" value=$total_drivers > keyvalue_count.txt

		# check number of running executors
		worker1_executors=`curl http://$SPARK_WORKER/v1 | grep "Running Executors" | cut -d"(" -f2 | cut -d")" -f1`
		worker2_executors=`curl http://$SPARK_WORKER_2/v1 | grep "Running Executors" | cut -d"(" -f2 | cut -d")" -f1`
		((total_executors=worker1_executors+worker2_executors))
		echo hyperpilot/spark/spark_running_count,entity="executor" value=$total_executors >> keyvalue_count.txt

		curl -s -XPOST $INFLUXDB_URL/write?db=$INFLUXDB_NAME --data-binary @keyvalue_count.txt > /dev/null
	done
done
