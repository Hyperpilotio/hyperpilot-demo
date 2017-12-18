import json
import time
import sys
import threading
import subprocess
import errno

from collections import deque
from influxdb import InfluxDBClient
from parse import compile
from kubernetes import client, config

q = deque()
benchmark_args = None


class BenchmarkController(object):
    def __init__(self, load_test_config):
        self.load_test_config = load_test_config

    def run_benchmark(self):
        p = subprocess.Popen(
            benchmark_args,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT)
        benchmark_result = {}
        for line in p.stdout.readlines():
            print(str(line))
            fields = compile('"{}","{}"').parse(line)
            if fields:
                benchmark_result[fields[0]] = float(fields[1])

        q.append(benchmark_result)
        self.run_benchmark()


class Influx(object):
    def __init__(self, host, port, dbname):
        self.client = InfluxDBClient(
            host, port, "root", "root", dbname)

    def write_data(self, data, measurement):
        fields = {}
        for k in data:
            if type(data[k]) == int:
                fields[k] = float(data[k])
            else:
                fields[k] = data[k]
        json_body = [
            {
                "measurement": measurement,
                "tags": {},
                "fields": fields
            }
        ]
        self.client.write_points(json_body)


class BenchmarkWorker(threading.Thread):
    def __init__(self, config_file, lock, threadName):
        self.config_file = config_file
        super(BenchmarkWorker,  self).__init__(name=threadName)
        self.lock = lock

    def run(self):
        load_test_config = None
        with open(self.config_file, 'r') as f:
            load_test_config = json.load(f)
        benchmark_controller = BenchmarkController(load_test_config)
        benchmark_controller.run_benchmark()


def get_ardb_serve_cluster_ip():
    """Call kubernetes api service to get service cluster ip"""
    try:
        config.load_incluster_config()
        result = client.CoreV1Api().list_namespaced_pod(
            "default", label_selector="app=ardb-serve")
        pod_name = result.items[0].metadata.name
        pod = client.CoreV1Api().read_namespaced_pod(pod_name, "default")
        return pod.status.pod_ip
    except config.ConfigException:
        print("Failed to load configuration. This container cannot run outside k8s.")
        return ""


def wait_until_ardb_serve_cluster_ip_available(timeout, stepTime=10):
    mustend = time.time() + timeout
    while time.time() < mustend:
        ardb_serve_cluster_ip = get_ardb_serve_cluster_ip()
        if ardb_serve_cluster_ip != "":
            return ardb_serve_cluster_ip
        else:
            time.sleep(stepTime)

    return ardb_serve_cluster_ip


if __name__ == '__main__':
    args = " ".join(sys.argv[1:])
    print("Run ardb-benchmarks with args: %s" % args)
    config_file = "/usr/local/bin/config.json"
    ardb_serve_cluster_ip = wait_until_ardb_serve_cluster_ip_available(60 * 2)
    if ardb_serve_cluster_ip == "":
        print("Unable to waiting for ardb-serve url to be available.")
        sys.exit(1)

    print("Get ardb-serve ip: %s" % ardb_serve_cluster_ip)
    benchmark_args = "%s -h %s -p 16379" % (
        args,
        ardb_serve_cluster_ip)
    with open(config_file, 'r') as f:
        j = json.load(f)
        lock = threading.Lock()
        interval = j["schedule"]["interval"]
        measurement = j["measurement"]
        database = j["database"]
        for i in range(j["schedule"]["workerCount"]):
            BenchmarkWorker(config_file,
                            lock,
                            "benchmarkWorker" + str(i)).start()

        influx_client = Influx("influxsrv", 8086, database)
        while True:
            if q:
                p = q.popleft()
                influx_client.write_data(p, measurement)
            time.sleep(int(interval))
