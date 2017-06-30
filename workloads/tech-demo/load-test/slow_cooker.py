"""Slow cooker load testing."""
import requests
import random
import datetime
import uuid
import time
import sys
from urlparse import urljoin
from multiprocessing import Pool
import json
import argparse
import os

LOCATIONS = ["SESTO", "AUMEL", "CNHKG", "JNTKO", "NLRTM", "DEHAM"]
QPS = 20
CONCURRENCY = 1
INTERVAL = "1s"
HISTOGRAM_WINDOW_SIZE = "1s"
TOTAL_REQUESTS = 200
STATUS_COMPLETE = "finished"


class StaticTasks(object):
    """Load tasks."""

    def __init__(self, target_host):
        """Initialize Tasks."""
        self.target_host = target_host

    def _pick_random_location(self):
        return LOCATIONS[random.randint(0, 5)]

    def create_route_delete_cargo(self):
        """Book new cargo -> route cargo -> delete cargo."""
        add_days = random.randint(0, 15)
        deadline = datetime.datetime.utcnow() + \
            datetime.timedelta(days=add_days)

        data = json.dumps({
            "origin": self._pick_random_location(),
            "destination": self._pick_random_location(),
            "arrival_deadline": deadline.isoformat() + "Z"
        })
        scenario = [
                {
                    "url_template":
                        urljoin(self.target_host,
                                "/booking/v1/cargos"),
                    "method": "POST",
                    "data": data,
                    "drain_resp": "tracking_id"
                },
                {
                    "url_template":
                        urljoin(self.target_host,
                                "/booking/v1/cargos/:tracking_id"),
                    "method": "GET"
                },
                {
                    "url_template":
                        urljoin(self.target_host,
                                "/booking/v1/cargos/:tracking_id"),
                    "method": "DELETE"
                }
            ]
        return scenario

    def list_cargos(self):
        """List cargo."""
        return [
            {
                "url_template":
                    urljoin(self.target_host,
                            "/booking/v1/cargos"),
                "method": "GET"
            }
        ]

    def list_locations(self):
        """List locations."""
        return [
            {
                "url_template":
                    urljoin(self.target_host,
                            "/booking/v1/locations"),
                "method": "GET"
            }
        ]


def run_benchmark(*args):
    """Run benchmark.
    args[0][0]: slow cooker host
    args[0][1]: scenario
    args[0][2]: load {qps: duration_in_second}
    load is a list which contains dict qps:duration
    """
    one_second = 1000000000
    for qps, duration in args[0][2].iteritems():
        id = uuid.uuid1()
        response = requests.post(
            url=urljoin(args[0][0],
                        "/slowcooker/benchmark"),
            json={
                "runId": id.__str__(),
                "qps": qps,
                "concurrency": CONCURRENCY,
                "totalRequests": qps * duration * one_second,
                "interval": one_second,
                "loadTime": "1s",
                "url": "http://localhost:8080",
                "scenario": args[0][1],
                "headers": {"Content-Type": "application/json"}
            }
        )
        # TODO: interval means nothing in benchmark
        if response.ok:
            done = False
            sys.stdout.write("task {} is running ".format(id))
            while not done:
                status = requests.get(
                    url=urljoin(args[0][0],
                                "/slowcooker/benchmark/{}".format(id)))
                if status.ok:
                    if json.loads(status.content)["State"] == STATUS_COMPLETE:
                        done = True
                    # query status per second
                    sys.stdout.write(".")
                    time.sleep(1)

            sys.stdout.write(" complete\n")
            sys.stdout.flush()
        else:
            print response.text
            response.raise_for_status()


# Run benchmark
def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--config", type=str,
                        required=False, default="hi_lo_config.json",
                        help="hi-lo config")
    parser.add_argument("--slow-cooker-host", type=str,
                        required=False, dest="slowcooker",
                        default="http://localhost:8081",
                        help="slow-cooker server host url")
    parser.add_argument("--host", type=str,
                        required=False, dest="host",
                        default="http://localhost:8080",
                        help="load test target host")
    args = parser.parse_args()
    if os.path.isfile(args.config):
        with open(args.config, 'r') as json_data_file:
            try:
                params = json.load(json_data_file)
            except ValueError as e:
                print "Main:ERROR: Error in reading configuration file %s: %s" % (args.config, e)
                sys.exit(-1)
    else:
        print "Main:ERROR: Cannot read configuration file ", args.config
        sys.exit(-1)
    params["slowcooker"] = args.slowcooker
    params["host"] = args.host
    return params


def main():
    """Main function."""
    params = parse_args()
    tasks = StaticTasks(params["host"])

    pool = Pool()

    # Edit load here
    lo = params["low_count"]
    lo_duration = params["low_duration_seconds"]
    hi = params["high_count"]
    hi_duration = params["high_duration_seconds"]
    slowcooker = params["slowcooker"]
    args = [
       (slowcooker, tasks.create_route_delete_cargo(), {lo: lo_duration, hi: hi_duration}),
       (slowcooker, tasks.list_cargos(), {lo: lo_duration, hi: hi_duration}),
       (slowcooker, tasks.list_locations(), {lo: lo_duration, hi: hi_duration})]
    while True:
        try:
            pool.map_async(run_benchmark, args).get(0xffff)
        except KeyboardInterrupt as e:
            # pool.close()
            # pool.join()
            pool.terminate()
            pool.join()
            print "Interrupted"
            sys.exit(0)


if __name__ == "__main__":
    main()

# runner.run_benchmark(tasks.create_route_delete_cargo(), {300: 45, 700: 75})

# runner.run_benchmark(tasks.list_cargos(), {300: 45, 700: 75})
# runner.run_benchmark(tasks.list_locations(), {300: 45, 700: 75})