#!/bin/bash

SPARK_MASTER=spark-master.default:6066
SPARK_WORKER=spark-worker.default:8081

count=1
jobs_finished=0

echo Submitting spark job no. $count
job_command=$(./pick_spark_job.py)
echo $job_command
eval "$job_command 2>job$1.out"
job_id=$(cat job$1.out | grep submissionId | cut -d":" -f2 | cut -d "\"" -f2)
echo Spark submission $job_id is submitted

((count++))
job_done=0

until [[ $job_done -gt 0 ]]; do
	if [ $job_done -eq 0 ]; then
		curl http://$SPARK_MASTER/v1/submissions/status/$job_id >status$1.out
		job_status=$(cat status$1.out | grep driverState | cut -d":" -f2 | cut -d "\"" -f2)
		worker_id=$(cat status$1.out | grep workerId | cut -d":" -f2 | cut -d "\"" -f2)
		if [[ $job_status == "FINISHED" || $job_status == "FAILED" || $job_status == "KILLED" || $job_status == "ERROR" ]]; then
			echo Spark submission $job_id has $job_status
			job_done=1
			echo hyperpilot/spark/spark_jobs_finished,worker_id=$worker_id,submission_id=$job_id,status=$job_status value=$job_done >keyvalue$1.txt
			if [ $job_status = "FINISHED" ]; then
				((jobs_finished++))
			fi
		else
			echo Spark submission $job_id is still running
			sleep 10
		fi
	fi

	echo Number of finished spark jobs = $jobs_finished
done
