#!/bin/bash

DEPLOYMENT_NAME=$1

if [ -z "$1" ]; then
    DEPLOYMENT_NAME=`kubectl get nodes --show-labels | grep deployment | tr "," "\n" | grep deployment | head -n 1 | cut -d"=" -f2`

    if [ -z "$DEPLOYMENT_NAME" ]; then
        echo "Unable to find or detect deployment name"
        exit 1
    fi

fi

echo "Resetting demo with deployment $DEPLOYMENT_NAME"

kubectl get daemonsets | tail -n +2 | cut -d" " -f1 | xargs kubectl delete daemonsets
kubectl get daemonsets -n hyperpilot | tail -n +2 | cut -d" " -f1 | xargs kubectl delete -n hyperpilot daemonsets

kubectl get deployments | tail -n +2 | cut -d" " -f1 | xargs kubectl delete deployments
kubectl get deployments -n hyperpilot | tail -n +2 | cut -d" " -f1 | xargs kubectl delete -n hyperpilot deployments

kubectl get services | tail -n +2 | grep -v kubernetes | cut -d" " -f1 | xargs kubectl delete services
kubectl get services -n hyperpilot | tail -n +2 | cut -d" " -f1 | xargs kubectl delete -n hyperpilot services

curl -XPUT localhost:7777/v1/deployments/$DEPLOYMENT_NAME --data-binary @deploy-k8s.json

DEMO_UI_HOST=`kubectl -n hyperpilot describe services demo-ui-publicport0 | grep elb | cut -d ":" -f2 | xargs`

echo "Grafana is running at http://$DEMO_UI_HOST:8080/grafana/, login with admin:admin"
echo "Demo UI is running at http://$DEMO_UI_HOST:8080/, make sure to login to Grafana before you can see the embedded Grafana"
