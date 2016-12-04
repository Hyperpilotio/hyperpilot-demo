#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ "X$AWS_CLOUDFORMATION_STACK" == "X" ]]; then
  AWS_CLOUDFORMATION_STACK="BloxAws"
fi


# IAM role
echo -n "Creating IAM role (blox-aws-role) .. "
aws iam create-role --role-name blox-aws-role --assume-role-policy-document file://data/blox-aws-role.json > /dev/null
aws iam put-role-policy --role-name blox-aws-role --policy-name blox-aws-policy --policy-document file://data/blox-aws-policy.json
echo "done"

echo "[
  {\"ParameterKey\":\"InstanceType\", \"ParameterValue\":\"t2.micro\"},
  {\"ParameterKey\":\"KeyName\", \"ParameterValue\":\"weave-ecs-demo-key\"},
  {\"ParameterKey\":\"QueueName\", \"ParameterValue\":\"blox_queue\"},
  {\"ParameterKey\":\"ApiStageName\", \"ParameterValue\":\"blox\"}
]
" >> /tmp/blox_parameters.json

cd  $DIR/../../../blox
aws  cloudformation create-stack --stack-name $AWS_CLOUDFORMATION_STACK --template-body file://./deploy/aws/conf/cloudformation_template.json --capabilities CAPABILITY_NAMED_IAM --parameters file:///tmp/blox_parameters.json
cd $DIR

# Wait for instances to join the cluster
echo -n "Waiting for daemon-scheduler start (this may take a few minutes) .. "
while [ "$(aws cloudformation describe-stacks --stack-name $AWS_CLOUDFORMATION_STACK --query 'Stacks[0].Outputs[0].OutputValue' --output text)" == "None" ]; do
    sleep 2
done
echo "done"
