import json
import requests
import uuid
import sys
import time
from collections import deque
import threading
from influxdb import InfluxDBClient
import subprocess
from parse import compile

q = deque()


class Deployer(object):
    def __init__(self, url):
        self.url = url

    def get_service_url(self, deployment_id, service):
        service_url = "/".join(["http://localhost:7777", "v1", "deployments",
                                deployment_id, "services", service, "url"])
        return requests.get(service_url).text

    def get_ardb_serve_url(self, deployment_id):
        ardb_serve_url = self.get_service_url(deployment_id, "ardb-serve")
        return ardb_serve_url

    def get_influxsrv_url(self, deployment_id):
        influxsrv_url = self.get_service_url(deployment_id, "influxsrv")
        return influxsrv_url


class BenchmarkAgent(object):
    # TODO: implement create/delete benchmark
    def create_benchmark(self):
        print("create_benchmark")

    def delete_benchmark(self):
        print("delete_benchmark")


class BenchmarkController(object):
    def __init__(self, deployer_client, deployment_id, load_test_config):
        self.deployer_client = deployer_client
        self.load_test_config = load_test_config
        self.ardb_serve_url = deployer_client.get_ardb_serve_url(deployment_id)
        ardb_host, ardb_port = self.ardb_serve_url.split(":")
        self.load_test_config["loadTest"]["args"].extend(
            ["-h", ardb_host, "-p", ardb_port])

    def run_benchmark(self):
        args = "%s %s" % (self.load_test_config["loadTest"]["path"],
                          " ".join(self.load_test_config["loadTest"]["args"]))
        p = subprocess.Popen(
            args,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT)
        benchmark_result = {}
        for line in p.stdout.readlines():
            print(line)
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
    def __init__(self, config_file, deployer_url, deployment_id, lock, threadName):
        self.config_file = config_file
        self.deployer_url = deployer_url
        self.deployment_id = deployment_id
        super(BenchmarkWorker,  self).__init__(name=threadName)
        self.lock = lock

    def run(self):
        load_test_config = None
        with open(self.config_file, 'r') as f:
            load_test_config = json.load(f)
        benchmark_controller = BenchmarkController(
            Deployer(self.deployer_url), self.deployment_id, load_test_config)
        benchmark_controller.run_benchmark()


if __name__ == '__main__':
    config_file = "./loadtest_config.json"
    deployer_url = "localhost"
    deployment_id = "ardb-de9e919f"
    with open(config_file, 'r') as f:
        j = json.load(f)
        lock = threading.Lock()
        interval = j["schedule"]["interval"]
        measurement = j["measurement"]
        database = j["database"]
        for i in range(j["schedule"]["workerCount"]):
            BenchmarkWorker(config_file,
                            deployer_url,
                            deployment_id,
                            lock,
                            "benchmarkWorker" + str(i)).start()

        influxsrv_url = Deployer(deployer_url).get_influxsrv_url(deployment_id)
        db_host = influxsrv_url.split(":")[0]
        influx_client = Influx(db_host, 8086, database)
        while True:
            if q:
                p = q.popleft()
                influx_client.write_data(p, measurement)
            time.sleep(int(interval))
