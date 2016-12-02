#!/usr/bin/env bash

which jq &> /dev/null
if [ $? -ne 0 ]
then
    echo "Please install jq library before setup"
    exit 1
fi

cwd=$(pwd)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR/../microservices-demo/deploy/aws-ecs
./setup.sh
cd $cwd
$DIR/scripts/task.sh
