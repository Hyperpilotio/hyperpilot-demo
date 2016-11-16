#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Removing locust slaves..."
aws ecs update-service --cluster weave-ecs-demo-cluster --service locust-slave-service --desired-count 0 >/dev/null
aws ecs delete-service --cluster weave-ecs-demo-cluster --service locust-slave-service >/dev/null

echo "Removing locust master..."
aws ecs update-service --cluster weave-ecs-demo-cluster --service locust-master-service --desired-count 0 >/dev/null
aws ecs delete-service --cluster weave-ecs-demo-cluster --service locust-master-service >/dev/null


echo -n "De-registering ECS Task Definitions..."
for td in $DIR/load-task-definitions/*.json
do
    td_name=$(jq .family $td | tr -d '"')
    echo $td_name
    revision=$(aws ecs describe-task-definition --task-definition $td_name --query 'taskDefinition.revision' --output text)
    echo $revision
    while [ $revision -ge 1 ]
    do
        aws ecs deregister-task-definition --task-definition "${td_name}:${revision}" > /dev/null
        revision=$(expr $revision - 1)
        if [ $revision -eq 0 ]; then break; fi
    done
done
echo "done"
