#!/usr/bin/env python

import time
import json
import sys
import subprocess
from urllib import request
from pick_spark_job import get_command
from optparse import OptionParser

parser = OptionParser()
parser.add_option("--host", "--master-host", dest="master_host",
        help="Address points to spark master node", metavar="HOST")

parser.add_option("--port", "--master-port", dest="master_port",
        help="Address points to spark master node", metavar="PORT")
(options, args) = parser.parse_args()

if not options.master_host or not options.master_port:
        print(json.dumps({
            'status': 'UNEXPECTED_ERROR',
            'error': "master_host: {} master_port: {}".format(options.master_host, options.master_port),
            }, indent=4))
        sys.exit(0)


SPARK_MASTER = '{}:{}'.format(options.master_host, options.master_port)


def job_status(job_id=""):
    res = request.urlopen(
        "http://{}/v1/submissions/status/{}".format(SPARK_MASTER, job_id)
    )
    data = json.loads(str(res.read(), 'utf-8'))
    if 'driverState' not in data:
        print(json.dumps({
            'status': 'UNEXPECTED_ERROR',
            'error': data,
            'job_id': job_id
            }, indent=4))
        sys.exit(0)

    return data['driverState']


def submit_job(master_address=''):
    """Submit job"""
    cmd_arr = get_command().split()
    cmd_arr.insert(1, '--master')
    cmd_arr.insert(2, master_address)
    begin = time.time()

    s = subprocess.Popen(
        cmd_arr,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    stdout, stderr = s.communicate()
    s.wait()

    string = stderr.decode('utf-8').split('\n')
    for line in string:
        if 'submissionId' in line:
            response = line.split(':')
            job = response[1].split('"')[1]
            break
    else:
        print(json.dumps({
            'status': 'UNEXPECTED_ERROR',
            'time': time.time() - begin,
            'error': "Job submission not found:{}".format(string)
            }, indent=4))
        sys.exit(0)
    return job, begin


job_id, start = submit_job('spark://{}'.format(SPARK_MASTER))

while True:
    time.sleep(1)
    # Query status
    state = job_status(job_id)
    if state in ['SUBMITTED', 'RUNNING']:
        print(json.dumps({
            'status': state,
            'time': time.time() - start,
            'job_id': job_id
            }, indent=4))
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
        print(json.dumps({
            'status': state,
            'time': time.time() - start,
            'job_id': job_id
            }, indent=4))
        sys.exit(1)
