=== Steps ===

- Make necessary changes to how you want to run the load test in deploy.json.
- Run upload.sh (assuming deployer running locally), which deploys the cluster and prepares the locust load test
- Navigate to Amazon ECS and find the public dns names where cassandra-benchmarks-ui application and benchmark-agent is running.
  To run benchmarks next to the workload (e.g: a while loop spinning cpu), follow the instructions in http://github.com/hyperpilotio/container-benchmarks
  for each benchmark to run.
- Initiate load test by navigating to cassandra-benchmarks-ui (cassandra-benchmarks-ui's public dns name with port 6001) and start the load test.
- Adjust benchmark if needed to control cpu shares allocation by calling benchmark-agent.
