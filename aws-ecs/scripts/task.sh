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
# Run influx
aws ecs create-service \
        --cluster weave-ecs-demo-cluster \
        --service-name monitor-service \
        --task-definition monitor \
        --desired-count 1 >/dev/null

# Run snap as daemon
if [[ "X$AWS_CLOUDFORMATION_STACK" == "X" ]]; then
  echo "AWS_CLOUDFORMATION_STACK is not exist. Use BloxAws as defalut value."
  AWS_CLOUDFORMATION_STACK="BloxAws"
fi

# Replace this with daemon ecs scheduler
ENV_NAME="snap"
TASK_DEFINITION="snap"
IS_ENVIRONMENT_EXIST="$($DIR/../../blox/deploy/demo-cli/blox-list-environments.py --apigateway --stack $AWS_CLOUDFORMATION_STACK | jq '.items[] | select(.name == "'"$TASK_DEFINITION"'")')"
IS_DEPLOYMENT_EXIST=""
CLUSTER="weave-ecs-demo-cluster"

if [[ "X$IS_ENVIRONMENT_EXIST" == "X" ]]; then
    # FIXME
    # create environment --> create deployment with "deploymentToken"
    # environment exists --> create deployment with "deploymentToken"
    # Supposedly, environment exists --> previous deployment exists --> create new deployment with "nextToken"
    # Blox is not production ready. Cli tool doesn't provide this function. Ironely, on the swagger api spec, it define this parameter.
    # However, the request didn't work even though I followed the spec to send the request.
    # Workaround. environment exists --> does deployment exist ?
    #     --treu--> delete environment --> create environment --> create deployment
    #     --false--> create deployment

    echo "Registering task $TASK_DEFINITION on daemon scheduler.."
    DEPLOYMENT_TOKEN="$($DIR/../../blox/deploy/demo-cli/blox-create-environment.py --apigateway --stack $AWS_CLOUDFORMATION_STACK --environment $ENV_NAME --cluster $CLUSTER --task-definition $TASK_DEFINITION | jq .deploymentToken | cut -d"\"" -f2)"
    echo "done."
fi

IS_DEPLOYMENT_EXIST="$($DIR/../../blox/deploy/demo-cli/blox-list-deployments.py --apigateway --stack $AWS_CLOUDFORMATION_STACK --environment $ENV_NAME | jq '.items[]')"

if [[ "X$IS_DEPLOYMENT_EXIST" == "X" ]]; then
  echo "None of daemon ($TASK_DEFINITION) is running."
else
    echo "Please launch cleanup.sh before launch setup.sh"
    exit 1
fi

echo "Start to deploy daemons on $CLUSTER .."
DEPLOYMENT_TOKEN="$($DIR/../../blox/deploy/demo-cli/blox-list-environments.py --apigateway --stack $AWS_CLOUDFORMATION_STACK | jq '.items[] | select(.name == "'"$TASK_DEFINITION"'") | .deploymentToken' | cut -d"\"" -f2)"
$DIR/../../blox/deploy/demo-cli/blox-create-deployment.py \
    --apigateway --stack $AWS_CLOUDFORMATION_STACK \
    --environment $ENV_NAME \
    --deployment-token $DEPLOYMENT_TOKEN
echo "done."
