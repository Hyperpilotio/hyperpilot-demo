#!/usr/bin/env bash

JQ_CHECK=`which jq`
if [ "$JQ_CHECK" == "" ]; then
    echo "Please install jq before running deployment (sudo apt-get install jq, or brew install jq)"
    exit 1
fi

TEMPDIR=`mktemp -d`
RESPONSE=$TEMPDIR/response.json
DEPLOYER_URL="localhost"
#DEPLOYER_URL="internal-deployer-605796188.us-east-1.elb.amazonaws.com"


curl -XPOST $DEPLOYER_URL:7777/v1/files/tech_demo_load_test -F upload=@load-test/locustfile.py
curl -XPOST $DEPLOYER_URL:7777/v1/files/tech_demo_core_site_xml -F upload=@core-site.xml
curl -s -XPOST $DEPLOYER_URL:7777/v1/deployments \
    --data-binary @deploy-k8s.json > $RESPONSE

ERROR=`cat $RESPONSE | jq .error`
if [ "$ERROR" != "false" ]; then
    echo "Deployment failed! error:"
    cat $RESPONSE | jq .data
    rm -rf $TEMPDIR
    exit 1
fi

DEPLOYMENT_NAME=`cat $RESPONSE | jq .data.name | cut -d"\"" -f2`
DEPLOYMENT_DIR="/tmp/deployer-$DEPLOYMENT_NAME"
BASTION_HOST=`cat $RESPONSE | jq .data.bastionIp | cut -d"\"" -f2`
MASTER_HOST=`cat $RESPONSE | jq .data.masterIp | cut -d"\"" -f2`
echo "Kubernetes Master is running at $MASTER_HOST"
mkdir $DEPLOYMENT_DIR
curl -s $DEPLOYER_URL:7777/v1/deployments/$DEPLOYMENT_NAME/ssh_key > $DEPLOYMENT_DIR/key.pem
chmod 400 $DEPLOYMENT_DIR/key.pem
echo "SSH key downloaded at $DEPLOYMENT_DIR/key.pem"
scp -q -p -i $DEPLOYMENT_DIR/key.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $DEPLOYMENT_DIR/key.pem ubuntu@$BASTION_HOST:~/key.pem
echo "Key is also uploaded /home/ubuntu/key.pem to Bastion Host $BASTION_HOST"
echo
curl -s $DEPLOYER_URL:7777/v1/deployments/$DEPLOYMENT_NAME/kubeconfig > $DEPLOYMENT_DIR/kubeconfig
echo "Run the following command to configure kubectl:"
echo "export KUBECONFIG=$DEPLOYMENT_DIR/kubeconfig"
echo
echo "To reset the demo or redeploy all kubernetes services, please run:"
echo "./reset-demo.sh $DEPLOYMENT_NAME"
echo
echo "To delete the cluster:"
echo "./delete_cluster.sh $DEPLOYMENT_NAME"

rm -rf $TEMPDIR
