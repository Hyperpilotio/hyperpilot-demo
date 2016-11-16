#!/usr/bin/env bash

cwd=$(pwd)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR/../microservices-demo/deploy/aws-ecs
./setup.sh
cd $cwd
$DIR/scripts/task.sh
