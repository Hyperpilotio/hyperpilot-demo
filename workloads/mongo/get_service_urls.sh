#!/bin/bash

DEPLOYER_URL="internal-deployer-605796188.us-east-1.elb.amazonaws.com"
#DEPLOYER_URL=localhost
curl ${DEPLOYER_URL}:7777/v1/deployments/$1/kubeconfig > ~/.kube/kubeconfig

#echo Creating a kubernetes-dashboard
kubectl create -f $GOPATH/src/github.com/hyperpilotio/hyperpilot-demo/workloads/tech-demo/kubernetes-dashboard.yaml

SERVICE="mongo"
PORT="27017"

SERVICE_URL=`kubectl describe services $SERVICE-serve-publicport0 | grep elb | cut -d":" -f2 | xargs`:$PORT
echo $SERVICE "service running at" $SERVICE_URL

LOADTESTER_URL=`kubectl describe services $SERVICE-bench-publicport0 | grep elb | cut -d":" -f2 | xargs`:$PORT
echo $SERVICE "load tester running at" $LOADTESTER_URL

#BENCHMARK_AGENT_PODS=`kubectl get pods | grep benchmark-agent | cut -d" " -f1`
#BENCHMARK_AGENT_POD=`echo $BENCHMARK_AGENT_PODS | cut -d" " -f1 | xargs`
#BENCHMARK_AGENT_POD_2=`echo $BENCHMARK_AGENT_PODS | cut -d" " -f2 | xargs`

BENCHMARK_AGENT_URL=`kubectl describe services benchmark-agent-publicport0 | grep elb | cut -d":" -f2 | xargs`:7778
echo "Benchmark agent running at " $BENCHMARK_AGENT_URL

BENCHMARK_AGENT_URL_2=`kubectl describe services benchmark-agent-2-publicport0 | grep elb | cut -d":" -f2 | xargs`:7778
echo "Benchmark agent 2 running at " $BENCHMARK_AGENT_URL_2

