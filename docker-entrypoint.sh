#!/bin/bash
# environment variables:
# SKIP_BOOTSTRAP: if this parameter set to true and DEPLOYMENT_ID exists, this script will run workload directly without create new cluster
# DEPLOYER_HOST: indicate which deployer should be used
# DEPLOYER_USERID: which user will be use in deployer
# AWS_ACCESS_KEY_ID: use for create cluster
# AWS_SECRET_ACCESS_KEY: use for create cluster
# RUN_APP: indicate which workload should be run, you can leave this variables to run all workloads
# CLEANUP_ON_EXIT: kill cluster once all workloads finished, default is set to true

# TODO: improve printing message with progress bar or something
run() {
    error=""
    # runId=$(cd $1 && ./$2 | jq -r '.runId')
    job=( "calibrate" "benchmarks" "sizing/aws" )
    echo "$1($runId) is running $item........."
    for item in "${job[@]}"; do
        runId=$(curl -s -XPOST -H "Content-Type: application/json" http://$PROFILER_URL/$item/$1 -d "{\"startingIntensity\":10, \"step\": 10}" | jq -r '.runId')
        while [[ true ]]; do
            resp=$(curl -s http://$PROFILER_URL/state/$runId)
            state=$(echo $resp | jq -r '.state')
            if [[ $state == "FINISHED" ]]; then
                break
            elif [[ $state == "FAILED" ]]; then
                echo "Job $1($runId) failed, message: $(echo $state)"
                error=$(echo $resp)
                break
            fi
            sleep 180
            echo "$1($runId) is running $item.........$state"
        done
        if [[ ! -z $error ]]; then
            echo "$1.........failed: $(echo $error)"
            break
        fi
    done

    if [[ ! -z $error ]]; then
        echo "$1.........failed: $(echo $error)"
        return 1
    else
        return 0
    fi
}

cleanup() {
    if [[ "$CLEANUP_ON_EXIT" == true ]]; then
        echo "------------------------------------------"
        echo "final: shutting down"
        curl -XDELETE $DEPLOYER_HOST:7777/v1/deployments/$DEPLOYMENT_ID

        while [[ $STATE != "Deleted" ]]; do
            #statements
            echo "check every 1 minutes"
            sleep 60
            STATE_JSON=$(curl -s $DEPLOYER_HOST:7777/v1/deployments/$DEPLOYMENT_ID/state)
            echo $STATE_JSON
            if [[ $(echo $STATE_JSON | jq -r '.error') == "true" ]]; then
                echo $(echo $STATE_JSON | jq -r '.data')
                exit 1
            fi

            if [[ $(echo $STATE_JSON | jq -r '.state') == "Failed" ]]; then
                echo $(echo $STATE_JSON | jq -r '.data')
                exit 1
            fi

            STATE=$(echo $STATE_JSON | jq -r '.state')
        done
        export DEPLOYMENT_ID=""
    fi
}

trap cleanup SIGINT

valid=true

if [[ $DEPLOYER_HOST == "" ]]; then
    DEPLOYER_HOST="deployer"
fi
echo "set deployer host to \"$DEPLOYER_HOST\""

if [[ $DEPLOYER_USERID == "" ]]; then
    echo "EnvVar DEPLOYER_USERID is required."
    valid=false
fi

if [[ $AWS_ACCESS_KEY_ID == "" ]]; then
    echo "EnvVar AWS_ACCESS_KEY_ID is required."
    valid=false
fi

if [[ $AWS_SECRET_ACCESS_KEY == "" ]]; then
    echo "EnvVar AWS_SECRET_ACCESS_KEY is required."
    valid=false
fi
#

if [[ $CLEANUP_ON_EXIT == "" ]]; then
    echo "cluster will delete after done all tests"
    CLEANUP_ON_EXIT=true
else
    echo "cluster won't delete after done all tests"
fi

if [[ "$valid" == false ]]; then
    exit 1
fi

echo "1. create deployer user"
while ! nc -z $DEPLOYER_HOST 7777; do sleep 30; done
curl -XPOST $DEPLOYER_HOST:7777/ui/users \
     --data-urlencode "userId=$DEPLOYER_USERID" \
     --data-urlencode "awsId=$AWS_ACCESS_KEY_ID" \
     --data-urlencode "awsSecret=$AWS_SECRET_ACCESS_KEY"

echo "------------------------------------------"
echo "2. create base cluster"
if [[ $DEPLOYMENT_ID == "" || "$SKIP_BOOTSTRAP" == false ]]; then
    #statements
    export DEPLOYMENT_ID=$(curl -s -XPOST $DEPLOYER_HOST:7777/v1/users/$DEPLOYER_USERID/deployments --data-binary @workloads/common/deploy-k8s.json | jq -r '.deploymentId')
fi

echo "deployment id: $DEPLOYMENT_ID"

echo "------------------------------------------"
echo "3. base cluster creating..."
STATE=""
STATE_JSON=""
while [[ $STATE != "Available" ]]; do
    #statements
    sleep 60
    STATE_JSON=$(curl -s $DEPLOYER_HOST:7777/v1/deployments/$DEPLOYMENT_ID/state)
    if [[ $(echo $STATE_JSON | jq -r '.error') == "true" ]]; then
        echo $(echo $STATE_JSON | jq -r '.data')
        exit 1
    fi

    if [[ $(echo $STATE_JSON | jq -r '.state') == "Failed" ]]; then
        echo $(echo $STATE_JSON | jq -r '.data')
        exit 1
    fi

    STATE=$(echo $STATE_JSON | jq -r '.state')
done


echo "----Kubernetes Cluster $DEPLOYMENT_ID is now running----"

echo "------------------------------------------"
echo "4. create DB users"
MONGO_URL=$(curl -s $DEPLOYER_HOST:7777/v1/deployments/$DEPLOYMENT_ID/services/mongo-serve/url)
while ! nc -z $(echo ${MONGO_URL/:/ }); do sleep 30; done

if [[ "$SKIP_BOOTSTRAP" != true ]]; then
    mongo $MONGO_URL/admin -u analyzer -p hyperpilot benchmarks/create-dbuser.js

    echo "------------------------------------------"
    echo "5. upload aws instance types info"
    (cd workloads/sizing-demo && ./update_db.sh $MONGO_URL) || cd ../..

    echo "------------------------------------------"
    echo "6. upload benchmarks settings"
    (cd benchmarks && pip install -r requirements.txt && python collect_benchmarks.py $MONGO_URL) || cd ..

    echo "------------------------------------------"
    echo "7. upload application.json from workloads"
    (cd workloads && python collect_applications.py $MONGO_URL) || cd ..

    echo "------------------------------------------"
    echo "8. upload analysis-base template"
    (cd workloads/common/ && ./upload.sh $DEPLOYER_HOST) || cd ../../
fi

echo "------------------------------------------"
echo "run workloads"
PROFILER_URL=$(curl -s $DEPLOYER_HOST:7777/v1/deployments/$DEPLOYMENT_ID/services/workload-profiler/url)

echo "Profiler URL: $PROFILER_URL"
echo "getting response from workload-profiler"
while ! nc -z $(echo ${PROFILER_URL/:/ }); do sleep 30; done

i=1
if [[ "$RUN_APP" == "" ]]; then
    #statements
    APPS=$(mongo $MONGO_URL/configdb -u analyzer -p hyperpilot --quiet --eval 'db.applications.distinct("name")')

    for row in $(echo $APPS | jq -r '.[]'); do
        run $row &
        array[$i]=$!
        ((i++))
    done
else
    #statements
    run $RUN_APP &
    array[$i]=$!
fi
wait

testResult=0
for item in "${array[@]}"; do
    echo "result: $item"
    ((testResult+=item))
done

cleanup

echo "------------------------------------------"
echo "all workloads completed"
echo "exit code is $testResult"
exit $testResult
