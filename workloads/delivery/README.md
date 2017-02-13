=== Steps ===

- Make necessary changes to how you want to run the load test in deploy.json and load-test/locustfile.py
- Run upload.sh (assuming deployer running locally), which deploys the cluster and prepares the locust load test
- Navigate to Amazon ECS and find the public dns names where locust-master and benchmark-agent is running.
  To run benchmarks next to the workload (e.g: a while loop spinning cpu), follow the instructions in http://github.com/hyperpilotio/container-benchmarks
  for each benchmark to run.
- Initiate load test by navigating to locust-master UI (locust-master's public dns name with port 8089) and start the load test.
- Adjust benchmark if needed to control cpu shares allocation by calling benchmark-agent.