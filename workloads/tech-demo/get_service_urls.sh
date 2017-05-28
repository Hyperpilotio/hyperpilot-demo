#!/bin/bash

DEPLOYER_URL="internal-deployer-605796188.us-east-1.elb.amazonaws.com"
curl ${DEPLOYER_URL}:7777/v1/deployments/$1/kubeconfig > ~/.kube/kubeconfig

LOCUST_URL=`kubectl describe services locust-master-publicport0 -n hyperpilot | grep elb | cut -d":" -f2 | xargs`:8089
GRAFANA_URL=`kubectl describe services grafana-publicport0 -n hyperpilot | grep elb | cut -d":" -f2 | xargs`:3000
INFLUXDB_UI=`kubectl describe services influxsrv-publicport0 -n hyperpilot | grep elb | cut -d":" -f2 | xargs`:8083
INFLUXDB_SERVER=`kubectl describe services influxsrv-publicport1 -n hyperpilot | grep elb | cut -d":" -f2 | xargs`:8086
SPARK_MASTER_URL=`kubectl describe services spark-master-publicport1 | grep elb | cut -d":" -f2 | xargs`:8088
#SPARK_WORKER_URL=`kubectl describe services spark-worker-publicport0 | grep elb | cut -d":" -f2 | xargs`:8081
#SPARK_WORKER2_URL=`kubectl describe services spark-worker-2-publicport0 | grep elb | cut -d":" -f2 | xargs`:8081
DEMO_UI_HOST=`kubectl -n hyperpilot describe services demo-ui-publicport0 | grep elb | cut -d ":" -f2 | xargs`:8080
echo "Grafana is running at http://$DEMO_UI_HOST/grafana/, login with admin:admin"
echo "Demo UI is running at http://$DEMO_UI_HOST/"
echo "InfluxDB is running at http://$INFLUXDB_SERVER"

open -a "Google Chrome" http://$DEMO_UI_HOST
open -a "Google Chrome" http://$DEMO_UI_HOST/grafana/
#open -a "Google Chrome" http://$LOCUST_URL
#open -a "Google Chrome" http://$INFLUXDB_UI
#open -a "Google Chrome" http://$SPARK_MASTER_URL
#open -a "Google Chrome" http://$SPARK_WORKER_URL
#open -a "Google Chrome" http://$SPARK_WORKER2_URL

#echo Creating a kubernetes-dashboard
#kubectl create -f kubernetes-dashboard.yaml
