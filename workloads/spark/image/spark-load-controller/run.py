#!/usr/bin/env python

import time
import json
import sys
import subprocess
from pprint import pprint
from urllib import request
from pick_spark_job import get_command


SPARK_MASTER = 'spark-master.default:6066'
SPARK_WORKER = 'spark-worker.default:8081'


def job_status(job_id=""):
    res = request.urlopen(
        "http://{}/v1/submissions/status/{}".format(SPARK_MASTER, job_id)
    )
    data = json.loads(str(res.read(), 'utf-8'))
    if 'driverState' not in data:
        sys.stderr.write(json.dumps({
            'status': 'UNEXPECTED_ERROR',
            'error': data,
            'time': -1,
            'job_id': job_id
            }))
        sys.exit(1)

    return data['driverState']


def submit_job():
    """Submit job"""
    start = time.time()
    s = subprocess.Popen(
        get_command().split(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )

    string = s.stderr.read().decode('utf-8').split('\n')
    # pprint(string, sys.stderr)
    sys.stderr
    for line in string:
        if 'submissionId' in line:
            response = line.split(':')
            job = response[1].split('"')[1]
            break
    else:
        sys.stderr.write(json.dumps({
            'status': 'UNEXPECTED_ERROR',
            'time': -1,
            'error': "Job submission not found:{}".format(string),
            'job_id': ""
            }))
        sys.exit(1)

    return job, start


job_id, start = submit_job()

while True:
    time.sleep(1)
    # Query status
    state = job_status(job_id)
    if state in [ "SUBMITTED", "RUNNING"]:
        continue
    if state in ["FINISHED", "FAILED", "KILLED", "ERROR"]:
        res = {
            'status': state,
            'time': time.time() - start,
            'job_id': job_id
        }
        print(json.dumps(res, indent=4))
        sys.exit(0)
    else:
        sys.stderr.write(json.dumps({
            'status': state,
            'time': -1,
            'job_id': job_id
            }))
        sys.exit(1)
