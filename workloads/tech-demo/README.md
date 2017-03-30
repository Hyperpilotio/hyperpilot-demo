=== Steps to run this demo ===

# Deploy the Tech demo environment, this sets up a kubernetes deployment and runs
# a microservice environment (goddd + mongo + pathfinder)
./deploy-k8s.sh

# Watch utilization and latency stats with grafana
GRAFANA_HOST=`kubectl -n hyperpilot describe services grafana-publicport0 | grep elb | cut -d":" -f2 | xargs`

echo "Grafana is running at http://$GRAFANA_HOST:3000, login with admin:admin"

# Start the load traffic pod to goddd
kubectl create -f load-controller-deployment.json

# To create BE workload, launch script to submit Spark jobs
./submit_spark_jobs.sh
