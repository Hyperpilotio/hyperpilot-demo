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

echo "Starting cadvisors on each host..."
# Replace this with daemon ecs scheduler
aws ecs list-container-instances --cluster weave-ecs-demo-cluster | jq .containerInstanceArns[] | cut -d"/" -f2 | cut -d"\"" -f1 | xargs -I{} \
    sh -c 'echo "Starting cadvisor on instance {}"; aws ecs start-task --cluster weave-ecs-demo-cluster --task-definition cadvisor --container-instances {} > /dev/null'
