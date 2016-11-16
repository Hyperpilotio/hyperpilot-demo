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

# Run the tasks!
# Run influx then cadvisors
aws ecs create-service \
        --cluster weave-ecs-demo-cluster \
        --service-name monitor-service \
        --task-definition monitor \
        --desired-count 1 >/dev/null
