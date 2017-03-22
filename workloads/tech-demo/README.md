=== Steps to run this demo ===

# Deploy the Tech demo environment, this sets up a kubernetes deployment and runs
# a microservice environment (goddd + mongo + pathfinder)
./deploy-k8s.sh

# Start the load traffic pod to goddd
kubectl create -f load-controller-deployment.json

# Watch utilization and latency stats with grafana
GRAFANA_HOST=`kubectl describe services grafana-publicport0 | grep elb | cut -d":" -f2 | xargs`

echo "Grafana is running at http://$GRAFANA_HOST:3000, login with admin:admin"

# To create BE workload, launch Spark command
./run_spark_job.sh
