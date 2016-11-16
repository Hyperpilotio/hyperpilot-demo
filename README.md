# hyperpilot-demo
Hyperpilot e2e demo

* Only AWS-ECS is working for now

Pre-reqs:

- Need to install aws-cli python package  and jq library

Setup Infra and workload:

aws-ecs/setup.sh

Setup load test (Locust):

# This runs 3 locust agents and uploads the load-test locust python file
aws-ecs/setup_load_test.sh 3 ../load-test/locust.py

Teardown:

aws-ecs/cleanup_load_test.sh
aws-ecs/cleanup.sh
