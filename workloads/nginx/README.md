=== Steps ===

- Make necessary changes to how you want to run the load test in deploy.json and load-test/locustfile.py
- Run upload.sh (assuming deployer running locally), which deploys the cluster and prepares the locust load test
- Navigate to Amazon ECS and find the public dns names where locust-master and benchmark-agent is running.
  To run benchmarks next to the workload (e.g: a while loop spinning cpu), follow the instructions in http://github.com/hyperpilotio/container-benchmarks
  for each benchmark to run.
- Initiate load test by navigating to locust-master UI (locust-master's public dns name with port 8089) and start the load test.
- Adjust benchmark if needed to control cpu shares allocation by calling benchmark-agent.

=== How to benchmark nginx independently ===
- Launch a cluster: ./deploy-k8s.json <userid>
- Download kubeconfig.txt from the deployer page and copy it in ~/.kube/config
- Launch K8S dashboard: kubectl create -f <pathto>/hyperpilot-demo/workloads/tech-demo/kubernetes-dashboard.yaml
- kubectl proxy & 
- Use the K8S dashboard to figure out the public URL of the slow_cooker server (for this example it is http://aa1f798e76cd411e782e60ad0f288d7f-784071870.us-east-1.elb.amazonaws.com:8081)
- Launch a slow_cooker test on k8S:  curl  -X POST  -H "Content-Type: application/json" -d '{ "appLoad": {   "qps": 1, "url": "http://nginx.default/index.html", "method": "GET",   "totalRequests": 10000000,  "concurrency": 100  }, "runsPerIntensity": 1, "loadTime": "60s" }' http://aa1f798e76cd411e782e60ad0f288d7f-784071870.us-east-1.elb.amazonaws.com:8081/slowcooker/benchmark/abc
- Get stats: curl http://aa1f798e76cd411e782e60ad0f288d7f-784071870.us-east-1.elb.amazonaws.com:8081/slowcooker/benchmark/abc
- abc is a user selected id for the test 
