import json
import time
from collections import deque
import threading
from influxdb import InfluxDBClient
import subprocess
from parse import compile

q = deque()


class BenchmarkController(object):
    def __init__(self, load_test_config):
        self.load_test_config = load_test_config

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


if __name__ == '__main__':
    config_file = "./config.json"
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
