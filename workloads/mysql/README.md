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