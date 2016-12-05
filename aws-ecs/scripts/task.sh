#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cwd=$(pwd)

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

if [[ "X$AWS_CLOUDFORMATION_STACK" == "X" ]]; then
  echo "AWS_CLOUDFORMATION_STACK is not exist. Use BloxAws as defalut value."
  AWS_CLOUDFORMATION_STACK="BloxAws"
fi

echo "Starting daemon-scheduler on AWS ECS ..."
$cwd/scripts/scheduler.sh

echo "Starting cadvisors on each host..."
# Replace this with daemon ecs scheduler
ENV_NAME="cadvisor"
TASK_DEFINITION="cadvisor"
CADVISOR_DEPLOYMENT_TOKEN=$($DIR/../../../blox/deploy/demo-cli/blox-create-environment.py --apigateway --stack $AWS_CLOUDFORMATION_STACK --environment $ENV_NAME --cluster "weave-ecs-demo-cluster" --task-definition $TASK_DEFINITION | jq .deploymentToken | cut -d"\"" -f2)
$DIR/../../../blox/deploy/demo-cli/blox-create-deployment.py \
      --apigateway --stack $AWS_CLOUDFORMATION_STACK \
      --environment $ENV_NAME \
      --deployment-token $CADVISOR_DEPLOYMENT_TOKEN
