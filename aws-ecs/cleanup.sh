#!/usr/bin/env bash

cwd=$(pwd)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/scripts/cleanup.sh

cd $DIR/../microservices-demo/deploy/aws-ecs
./cleanup.sh
