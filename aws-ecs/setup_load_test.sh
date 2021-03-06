#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$#" -ne 2 ]; then
    echo "setup_load_test.sh <NUMBER_OF_SLAVES> <LOCUST_FILE>"
    exit 1
fi

NUMBER_OF_SLAVES=$1
LOCUST_FILE=$2

KEY_FILE="$DIR/../microservices-demo/deploy/aws-ecs/weave-ecs-demo-key.pem"

echo "Registering Locust ECS Task Definitions..."
for td in $DIR/load-task-definitions/*.json
do
    echo "Registering $td..."
    aws ecs register-task-definition --cli-input-json file://$td > /dev/null
    done
echo "done"

echo "Uploading locust load file $LOCUST_FILE to EC2 instances..."
for instance in $(aws ec2 describe-instances | \
    jq -c '.Reservations[].Instances[] | select(.KeyName | contains("weave"))' | \
    jq .NetworkInterfaces[0].PrivateIpAddresses[0].Association.PublicDnsName | cut -d"\"" -f2); do
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $KEY_FILE ec2-user@$instance 'rm -rf /home/ec2-user/locust_file;mkdir /home/ec2-user/locust_file' &> /dev/null

    scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $KEY_FILE $LOCUST_FILE ec2-user@$instance:/home/ec2-user/locust_file/locustfile.py
done
echo "done."

echo "Creating locust master and slaves..."
aws ecs create-service\
 --cluster weave-ecs-demo-cluster \
 --service-name locust-master-service \
 --task-definition locust-master \
 --desired-count 1 >/dev/null

aws ecs create-service\
 --cluster weave-ecs-demo-cluster \
 --service-name locust-slave-service \
 --task-definition locust-slave \
 --desired-count $NUMBER_OF_SLAVES > /dev/null
echo "done."

echo "Updating Security Group (weave-ecs-demo) .."
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --query 'SecurityGroups[?GroupName==`weave-ecs-demo`]' | jq .[0].GroupId | cut -d'"' -f2)
# Wait for the group to get associated with the VPC
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 8089 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 8083 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 8086 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 8080 --cidr 0.0.0.0/0
echo "done."
