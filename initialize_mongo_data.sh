#!/bin/bash

export MONGO_URL=`curl localhost:7777/v1/deployments/$1/services | jq '.data."mongo-serve".publicUrl' | cut -d'"' -f2`
export DEPLOYER_URL=`curl localhost:7777/v1/deployments/$1/services | jq '.data."deployer".publicUrl' | cut -d'"' -f2`
export PROFILER_URL=`curl localhost:7777/v1/deployments/$1/services | jq '.data."workload-profiler".publicUrl' | cut -d'"' -f2`
export MONGO_POD=`kubectl get pods | grep mongo-serve | cut -d" " -f1`

kubectl exec -it $MONGO_POD -- mongo $MONGO_URL/admin --eval "db.createUser({user: 'analyzer', pwd: 'hyperpilot', roles: [ 'root' ]})"

mongo $MONGO_URL/admin -u analyzer -p hyperpilot benchmarks/create-dbuser.js

(cd workloads/sizing-demo && ./update_db.sh $MONGO_URL) || cd ../..

pwd
(cd benchmarks && python collect_benchmarks.py $MONGO_URL) || cd ..

(cd workloads && python collect_applications.py $MONGO_URL) || cd ..

(cd workloads/common/ && ./upload.sh $DEPLOYER_URL) || cd ../../

echo "Workload profiler is available at: $PROFILER_URL"
echo "Please run calibration first before running other runs"
