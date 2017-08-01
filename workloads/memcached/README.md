For memcache, we use the *mutilate* benchmarking tool. While mutilate is very versatile in what it can test, it has limitations:

- No webUI
- It does not push results to influxDB.


=== Steps ===

- Run upload.sh (assuming deployer running locally), which deploys the cluster and prepares the locust load test
- Navigate to Amazon ECS and find the public dns names where mutilate and benchmark-agent is running.

  To run benchmarks next to the workload (e.g: a while loop spinning cpu), follow the instructions in http://github.com/hyperpilotio/container-benchmarks
  for each benchmark to run.
- Initiate load test by ssh'ing to the mutilate instance and running "mutilate -s HOST", where host is the instance for memcache. 
- Adjust benchmark if needed to control cpu shares allocation by calling benchmark-agent.