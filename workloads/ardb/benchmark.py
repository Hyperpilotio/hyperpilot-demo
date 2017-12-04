import json
import requests
import uuid
import sys
import time
from collections import deque
import threading
from influxdb import InfluxDBClient

q = deque()


class Deployer(object):
    def __init__(self, url):
        self.url = url

    def get_service_url(self, deployment_id, service):
        service_url = "/".join(["http://localhost:7777", "v1", "deployments",
                                deployment_id, "services", service, "url"])
        return requests.get(service_url).text

    def get_benchmark_service_url(self, deployment_id):
        benchmark_controller_base_url = self.get_service_url(
            deployment_id, "benchmark-controller")
        return "http://%s" % "/".join(
            [benchmark_controller_base_url, "api", "benchmarks"])

    def get_ardb_serve_url(self, deployment_id):
        return self.get_service_url(deployment_id, "ardb-serve")


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
        self.benchmark_service_url = deployer_client.get_benchmark_service_url(
            deployment_id)
        self.ardb_serve_url = deployer_client.get_ardb_serve_url(deployment_id)

        ardb_host, ardb_port = self.ardb_serve_url.split(":")
        self.load_test_config["loadTest"]["args"].extend(
            ["-h", ardb_host, "-p", int(ardb_port)])

    def run_benchmark(self):
        stage_id = "ardb-%s" % uuid.uuid4()
        self.load_test_config["stageId"] = stage_id
        resp = requests.post(self.benchmark_service_url,
                             json=self.load_test_config)
        if resp.status_code > 300:
            print("Unable to send benchmark request to controller")
        else:
            self.get_benchmark_result(stage_id)

    def get_benchmark_result(self, stage_id):
        stage_url = "%s/%s" % (self.benchmark_service_url, stage_id)
        result = self.wait_until_benchmark_status_success(stage_url, 30 * 60)
        if not result:
            print("Unable to get benchmark results")
        self.run_benchmark()

    def wait_until_benchmark_status_success(self, stage_url, timeout, stepTime=10):
        mustend = time.time() + timeout
        while time.time() < mustend:
            results = requests.get(stage_url).json()
            if results.get("error", "") != "":
                print("Benchmark failed with error: " + results["error"])
            elif results["status"] == "running":
                time.sleep(stepTime)
            else:
                q.append(results["results"][0]["results"])
                return True

        return False


class Influx(object):
    def __init__(self, host, port, dbname):
        self.client = InfluxDBClient(host, port, "root", "root", dbname)

    def write_data(self, data, measurement):
        json_body = [
            {
                "measurement": measurement,
                "tags": {},
                "fields": data
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
    interval = None
    with open(config_file, 'r') as f:
        j = json.load(f)
        lock = threading.Lock()
        interval = j["schedule"]["interval"]
        for i in range(j["schedule"]["workerCount"]):
            BenchmarkWorker(config_file,
                            deployer_url,
                            deployment_id,
                            lock,
                            'thread-' + str(i)).start()

    influx_client = Influx("localhost", 8086, "ardb")
    while True:
        if q:
            p = q.popleft()
            influx_client.write_data(p, "ardb_benchmarks")
        time.sleep(int(interval))
