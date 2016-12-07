#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

which jq &> /dev/null
if [ $? -ne 0 ]
then
    echo "Please install jq library before setup"
    exit 1
fi

if [[ "X$AWS_CLOUDFORMATION_STACK" == "X" ]]; then
  echo "AWS_CLOUDFORMATION_STACK is not exist. Use BloxAws as defalut value."
  AWS_CLOUDFORMATION_STACK="BloxAws"
fi

echo -n "Creating Key Pair (file daemon-scheduler-key.pem) .. "
aws ec2 create-key-pair --key-name daemon-scheduler-key --query 'KeyMaterial' --output text > $DIR/daemon-scheduler-key.pem
chmod 600 $DIR/daemon-scheduler-key.pem
echo "done"

AWS_EC2_KEY=daemon-scheduler-key

# IAM role
echo -n "Creating IAM role (blox-aws-role) .. "
aws iam create-role --role-name blox-aws-role \
  --assume-role-policy-document file://$DIR/data/blox-aws-role.json > /dev/null
aws iam put-role-policy --role-name blox-aws-role \
  --policy-name blox-aws-policy --policy-document file://$DIR/data/blox-aws-policy.json
echo "done"

echo "[
  {\"ParameterKey\":\"InstanceType\", \"ParameterValue\":\"t2.micro\"},
  {\"ParameterKey\":\"KeyName\", \"ParameterValue\":\"$AWS_EC2_KEY\"},
  {\"ParameterKey\":\"QueueName\", \"ParameterValue\":\"blox_queue\"},
  {\"ParameterKey\":\"ApiStageName\", \"ParameterValue\":\"blox\"}
]
" > /tmp/blox_parameters.json

aws  cloudformation create-stack --stack-name $AWS_CLOUDFORMATION_STACK \
      --template-body file://$DIR/../blox/deploy/aws/conf/cloudformation_template.json \
      --capabilities CAPABILITY_NAMED_IAM --parameters file:///tmp/blox_parameters.json

# Wait for instances to join the cluster
echo -n "Waiting for daemon-scheduler start (this may take a few minutes) .. "
while [ "$(aws cloudformation describe-stacks --stack-name $AWS_CLOUDFORMATION_STACK --query 'Stacks[0].Outputs[0].OutputValue' --output text)" == "None" ]; do
    sleep 3
done
echo "done"

echo "API endpoint:
$(aws cloudformation describe-stacks --stack-name $AWS_CLOUDFORMATION_STACK --query 'Stacks[0].Outputs[0].OutputValue' --output text)"
