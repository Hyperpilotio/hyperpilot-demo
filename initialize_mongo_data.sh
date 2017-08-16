#!/bin/bash

export MONGO_POD=`kubectl get pods | grep mongo | cut -d" " -f1`

export MONGO_URL=`kubectl describe services mongo-serve-publicport | grep elb | cut -d ":" -f2 | xargs`

export DEPLOYER_URL=`kubectl describe services deployer-public | grep elb | cut -d ":" -f2 | xargs`

export PROFILER_URL=`kubectl describe services workload-profiler-public | grep elb | cut -d ":" -f2 | xargs`

kubectl exec -it $MONGO_POD -- mongo localhost:27017/admin --eval "db.createUser({user: 'analyzer', pwd: 'hyperpilot', roles: [ 'root' ]})"

mongo $MONGO_URL:27017/admin -u analyzer -p hyperpilot benchmarks/create-dbuser.js

(cd workloads/sizing-demo && ./update_db.sh $MONGO_URL) || cd ../..

pwd
(cd benchmarks && python collect_benchmarks.py $MONGO_URL) || cd ..

(cd workloads && python collect_applications.py $MONGO_URL) || cd ..

(cd workloads/common/ && ./upload.sh $DEPLOYER_URL) || cd ../../

echo "Workload profiler is available at: $PROFILER_URL"
echo "Please run calibration first before running other runs"
