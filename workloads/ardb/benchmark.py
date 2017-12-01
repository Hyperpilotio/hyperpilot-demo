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

        for i in range(10):
            respJson = requests.get(
                "%s/%s" % (benchmark_service_url, j["stageId"])).json()
            status = respJson["status"]
            if status == "running":
                time.sleep(30)
            elif status == "success":
                print(respJson["results"])
