Redis uses its own benchmark tool, *redis-benchmark*. We use a simple node.js app to provide a UI to the tool. However, it has two limitations:
- it runs the all tests (no support for the -t option)
- it does not push the results to Influx

=== Steps ===

- Run upload.sh (assuming deployer running locally), which deploys the cluster and prepares the locust load test
- Navigate to Amazon ECS and find the public dns names where redis-bench and benchmark-agent is running.
  To run benchmarks next to the workload (e.g: a while loop spinning cpu), follow the instructions in http://github.com/hyperpilotio/container-benchmarks
  for each benchmark to run.
- Initiate load test by navigating to redis-bench UI (redis-bench's public dns name with port 6001) and start the load test.
- Adjust benchmark if needed to control cpu shares allocation by calling benchmark-agent.


## Sample Request

Start load test.

POST http://TARGET_HOST:6001/api/benchmark

```{json}
{
	"name": "redis-test",
	"workflow": ["tpcc", "run"],
	"commandSet": {
		"tpcc": {
			"name": "tpcc-load",
			"binPath": "/opt/tpcc-mysql/tpcc_load",
			"args": ["mysql-server", "tpcc", "root", "", "", "20"],
			"type": ""
		},
		"run": {
			"name": "load-testing",
			"binPath": "/opt/tpcc-mysql/tpcc_start",
			"args": ["-d", "tpcc", "-h", "mysql-server", "-u", "root", "-w", "20", "-c", "10", "-r", "20", "-l", "100"],
			"type": "load-test"
		}
	}
}

```

***NOTE: That request will trigger the load testing.
Somehow the request reaches the timeout, thus it would not get any response from benchmark-controller. Still, it will store the stats into mongodb if the load testing is finished.***
