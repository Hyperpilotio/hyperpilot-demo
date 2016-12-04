#!/usr/bin/env bash

cwd=$(pwd)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/scripts/cleanup.sh

cd $DIR/../microservices-demo/deploy/aws-ecs
./cleanup.sh

cd $cwd

# Clean Blox
aws cloudformation delete-stack --stack-name BloxAws
rm /tmp/blox_parameters.json

# IAM role
echo -n "Deleting blox-aws-role IAM role (blox-aws-role) .. "
aws iam delete-role-policy --role-name blox-aws-role --policy-name blox-aws-policy
aws iam delete-role --role-name blox-aws-role
echo "done"
