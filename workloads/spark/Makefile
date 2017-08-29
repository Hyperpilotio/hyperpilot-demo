SHELL := /bin/bash
.PHONY: help

# Variable
WORKLOAD=spark
USER_ID=hyperpilot

# ARGUMENTS
POST_ARG=-XPOST -H "Content-Type: application/json"
CURL_ARGS=-d "{\"startingIntensity\":10, \"step\": 10}"

# URL
DEPLOYER_URL=`(kubectl describe services deployer-publicport | grep elb | cut -d ":" -f2 | xargs)`:7777
PROFILER_URL=`(kubectl describe services workload-profiler-publicport | grep elb | cut -d ":" -f2 | xargs)`:7779

help: ## This help message
	@echo "             COMMAND"
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

aws-size: ## make aws-size
	@curl $(POST_ARG) http://$(PROFILER_URL)/sizing/aws/$(WORKLOAD)
	@echo "Please check progress of your deployment at http://$(PROFILER_URL)/ui"

benchmark: ## make benchmark
	@curl $(POST_ARG) http://$(PROFILER_URL)/benchmarks/$(WORKLOAD) $(CURL_ARGS)
	@echo "Please check progress of your deployment at http://$(DEPLOYER_URL)/ui"

calibrate: ## make calibrate
	@curl -XPOST http://$(PROFILER_URL)/calibrate/$(WORKLOAD)
	@echo "Please check progress of your deployment at http://$(DEPLOYER_URL)/ui"

deploy-ecs:  ## make deploy-ecs USER_ID=
deploy-ecs: deploy-ecs.json
	@curl -XPOST $(DEPLOYER_URL)/v1/users/$(USER_ID)/deployments --data-binary @deploy-ecs.json
	@echo "Please check progress of your deployment at http://$(DEPLOYER_URL)/ui"

deploy-k8s:	## make deploy-k8s USER_ID=
deploy-k8s: deploy-k8s.json
	@curl -XPOST $(DEPLOYER_URL)/v1/users/$(USER_ID)/deployments --data-binary @deploy-k8s.json
	@echo "Please check progress of your deployment at http://$(DEPLOYER_URL)/ui"

profile: ## make profile
	@curl -XPOST $(PROFILER_URL)/profilers/deployments/$(DEPLOYMENT_ID) --data-binary @profile.json

run-spark-job: ## make run-spark-job
run-spark-job:
	@SPARK_MASTER_POD=`kubectl get pods | grep spark-master | cut -d" " -f1`
	@kubectl exec $SPARK_MASTER_POD -- /bin/bash -c './bin/spark-submit --master=spark://$(hostname -i):6066 --deploy-mode=cluster --executor-memory 2g --driver-memory 2g --class MovieLensALS s3://hyperpilot-jarfiles/movielens-als-assembly-2.11-0.1.jar s3://demo-analysis-datasets/movielens/medium/ s3://demo-analysis-datasets/personalRatings.txt'

submit-spark-job: ## make submit-spark-job
submit-spark-job:
	@SPARK_MASTER_POD=`kubectl get pods | grep spark-master | cut -d" " -f1`
	@kubectl exec $SPARK_MASTER_POD -- /bin/bash -c './run.sh 20'
