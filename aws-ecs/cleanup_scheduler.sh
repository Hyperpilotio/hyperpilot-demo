#!/usr/bin/env bash

if [[ "X$AWS_CLOUDFORMATION_STACK" == "X" ]]; then
  echo "AWS_CLOUDFORMATION_STACK is not exist. Use BloxAws as defalut value."
  AWS_CLOUDFORMATION_STACK="BloxAws"
fi

echo -n "Delete cloudformation stack ($AWS_CLOUDFORMATION_STACK) .. "
# Clean Blox
aws cloudformation delete-stack --stack-name $AWS_CLOUDFORMATION_STACK
rm /tmp/blox_parameters.json
echo "done"

# IAM role
echo -n "Deleting blox-aws-role IAM role (blox-aws-role) .. "
aws iam delete-role-policy --role-name blox-aws-role --policy-name blox-aws-policy
aws iam delete-role --role-name blox-aws-role
echo "done"
