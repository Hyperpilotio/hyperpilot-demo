#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Remove influx
aws ecs update-service --cluster weave-ecs-demo-cluster --service monitor-service --desired-count 0 >/dev/null
aws ecs delete-service --cluster weave-ecs-demo-cluster --service monitor-service >/dev/null

if [[ "X$AWS_CLOUDFORMATION_STACK" == "X" ]]; then
  echo "AWS_CLOUDFORMATION_STACK = BloxAws"
  AWS_CLOUDFORMATION_STACK="BloxAws"
fi

# Remove cadvisor from daemon scheduler
$DIR/../../blox/deploy/demo-cli/blox-delete-environment.py --apigateway --stack $AWS_CLOUDFORMATION_STACK --environment cadvisor --cluster "weave-ecs-demo-cluster"

#echo -n "Deleting ECS Services..."
#for td in task-definitions/*.json
#do
#    td_name=$(jq .family $td | tr -d '"')
#    aws ecs update-service --cluster weave-ecs-demo-cluster --service ${td_name}-service --desired-count 0 >/dev/null
#    aws ecs delete-service --cluster weave-ecs-demo-cluster --service ${td_name}-service >/dev/null
#done
#echo "done"

# Delete task definitions
echo -n "De-registering ECS Task Definitions..."
for td in $DIR/../task-definitions/*.json
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
