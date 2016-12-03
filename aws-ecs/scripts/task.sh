#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Task definitions
echo "Registering Hyperpilot ECS Task Definitions..."
for td in $DIR/../task-definitions/*.json
do
    echo "Registering $td..."
    aws ecs register-task-definition --cli-input-json file://$td > /dev/null
    done
echo "done"

echo "Starting influx..."
# Run the tasks!
# Run influx then cadvisors
aws ecs create-service \
        --cluster weave-ecs-demo-cluster \
        --service-name monitor-service \
        --task-definition monitor \
        --desired-count 1 >/dev/null

echo "Starting daemon-scheduler on AWS ECS / Local machine..."
./scheduler.sh

echo "Starting cadvisors on each host..."
# Replace this with daemon ecs scheduler
ENV_NAME="cadvisor"
TASK_DEFINITION="cadvisor"
# FIXME deploy daemon-scheduler on AWS ECS
CADVISOR_DEPLOYMENT_TOKEN=$(./blox-create-environment.py --environment $ENV_NAME --cluster "weave-ecs-demo-cluster" --task-definition $TASK_DEFINITION | jq .deploymentToken | cut -d"\"" -f2)
./blox-create-deployment.py --environment $ENV_NAME --deployment-token $CADVISOR_DEPLOYMENT_TOKEN
#CADVISOR_DEPLOYMENT_TOKEN=$(./blox-create-environment.py --region $AWS_REGION  --environment $ENV_NAME --cluster "weave-ecs-demo-cluster" --task-definition $TASK_DEFINITION | jq .deploymentToken | cut -d"\"" -f2)
#./blox-create-deployment.py --region $AWS_REGION --environment $ENV_NAME --deployment-token $CADVISOR_DEPLOYMENT_TOKEN
