#!/bin/bash

set -euo pipefail

# Task definitions
echo -n "Registering ECS Task Definitions..."
for td in task-definitions/*.json
do
    aws ecs register-task-definition --cli-input-json file://$td > /dev/null
    done
echo "done"

