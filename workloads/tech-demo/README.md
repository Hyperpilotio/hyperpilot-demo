=== Steps to run this demo ===

# Deploy the Tech demo environment, this sets up a kubernetes deployment and runs
# a microservice environment (goddd + mongo + pathfinder)
./deploy-k8s.sh <user> <mode:optional>

available mode:
- ``empty(default)``: deploy deploy-k8s.json to deployer, this mode runs classic tech-demo
- ``kafka-influx``: deploy-k8s-kafka-influx.json to deployer, this mode will publish snap metrics to kafka, then consume kafka message by kafka-influx pod
- ``goddd-only``: deploy-k8s-goddd-only.json to deployer, this mode contains goddd workload only

# See Demo UI & Watch utilization and latency stats with Grafana
```
DEMO_UI_HOST=`kubectl -n hyperpilot describe services demo-ui-publicport0 | grep elb | cut -d ":" -f2 | xargs`

echo "Demo UI is running at http://$DEMO_UI_HOST:8080/"
echo "Grafana is running at http://$DEMO_UI_HOST:8080/grafana/"
```


# Start the load traffic pod to goddd
kubectl create -f load-controller-deployment.json

# To create BE workload, launch script to submit Spark jobs
./submit_spark_jobs.sh
