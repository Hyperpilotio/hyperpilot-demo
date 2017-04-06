=== Steps to run this demo ===

# Deploy the Tech demo environment, this sets up a kubernetes deployment and runs
# a microservice environment (goddd + mongo + pathfinder)
./deploy-k8s.sh

# See Demo UI & Watch utilization and latency stats with Grafana
```
DEMO_UI_HOST=`kubectl -n hyperpilot describe services demo-ui-publicport0 | grep elb | cut -d ":" -f2 | xargs`

echo "Grafana is running at http://$DEMO_UI_HOST:8080/grafana/, login with admin:admin"
echo "Demo UI is running at http://$DEMO_UI_HOST:8080/, make sure to login to Grafana before you can see the embedded Grafana"
```


# Start the load traffic pod to goddd
kubectl create -f load-controller-deployment.json

# To create BE workload, launch script to submit Spark jobs
./submit_spark_jobs.sh
