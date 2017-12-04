import json
import requests
import uuid
import sys
import time


class Deployer(object):
    def __init__(self, url):
        self.url = url

    def get_service_url(self, deployment, service):
        service_url = "/".join(["http://localhost:7777", "v1", "deployments",
                                deployment, "services", service, "url"])
        return requests.get(service_url).text


def wait_until_benchmark_status_success(stage_url, timeout, stepTime=10):
    mustend = time.time() + timeout
    while time.time() < mustend:
        results = requests.get(stage_url).json()
        if results.get("error", "") != "":
            print("Benchmark failed with error: " + results["error"])
        elif results["status"] == "running":
            time.sleep(stepTime)
        else:
            print("Load test finished with status: %s" % results["status"])
            print(json.dumps(results["results"][0], indent=4))
            return

    print("Unable to get benchmark results")


if __name__ == '__main__':
    config_file = "./loadtest_config.json"
    deployer = Deployer("localhost")
    deploymentId = "ardb-de9e919f"

    with open(config_file, 'r') as f:
        j = json.load(f)

        benchmark_controller_base_url = deployer.get_service_url(
            deploymentId, "benchmark-controller")
        benchmark_service_url = "http://%s" % "/".join(
            [benchmark_controller_base_url, "api", "benchmarks"])
        ardb_serve_url = deployer.get_service_url(
            deploymentId, "ardb-serve")
        ardb_host, ardb_port = ardb_serve_url.split(":")

        j["stageId"] = "ardb-%s" % uuid.uuid4()
        j["loadTest"]["args"].extend(["-h", ardb_host, "-p", int(ardb_port)])
        resp = requests.post(benchmark_service_url, json=j)
        if resp.status_code > 300:
            print("Unable to send benchmark request to controller")
            sys.exit(0)

        stage_url = "%s/%s" % (benchmark_service_url, j["stageId"])
        wait_until_benchmark_status_success(stage_url, 10 * 60)
