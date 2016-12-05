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

if [[ "X$AWS_EC2_KEY" == "X" ]]; then
  echo "
AWS_EC2_KEY is not exist.
Please create a key on AWS EC2 and assign the name of key to AWS_EC2_KEY.
export AWS_EC2_KEY={KeyName}
Reference https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
"
  exit 1
fi

# IAM role
echo -n "Creating IAM role (blox-aws-role) .. "
aws iam create-role --role-name blox-aws-role \
  --assume-role-policy-document file://aws-ecs/data/blox-aws-role.json > /dev/null
aws iam put-role-policy --role-name blox-aws-role \
  --policy-name blox-aws-policy --policy-document file://aws-ecs/data/blox-aws-policy.json
echo "done"

echo "[
  {\"ParameterKey\":\"InstanceType\", \"ParameterValue\":\"t2.micro\"},
  {\"ParameterKey\":\"KeyName\", \"ParameterValue\":\"$AWS_EC2_KEY\"},
  {\"ParameterKey\":\"QueueName\", \"ParameterValue\":\"blox_queue\"},
  {\"ParameterKey\":\"ApiStageName\", \"ParameterValue\":\"blox\"}
]
" >> /tmp/blox_parameters.json

cd  $DIR/../../blox
aws  cloudformation create-stack --stack-name $AWS_CLOUDFORMATION_STACK \
      --template-body file://./deploy/aws/conf/cloudformation_template.json \
      --capabilities CAPABILITY_NAMED_IAM --parameters file:///tmp/blox_parameters.json

# Wait for instances to join the cluster
echo -n "Waiting for daemon-scheduler start (this may take a few minutes) .. "
while [ "$(aws cloudformation describe-stacks --stack-name $AWS_CLOUDFORMATION_STACK --query 'Stacks[0].Outputs[0].OutputValue' --output text)" == "None" ]; do
    sleep 3
done
echo "done"

echo "API endpoint:
$(aws cloudformation describe-stacks --stack-name $AWS_CLOUDFORMATION_STACK --query 'Stacks[0].Outputs[0].OutputValue' --output text)"
