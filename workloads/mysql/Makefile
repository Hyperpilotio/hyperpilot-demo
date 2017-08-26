SHELL := /bin/bash
.PHONY: help

# ARGUMENTS
POST_ARG=-XPOST -H "Content-Type: application/json"
CURL_ARGS="-d \"{\"startingIntensity\":10, \"step\": 10}\""

# Variable
WORKLOAD=redis
USER_ID=hyperpilot

# URL
DEPLOYER_URL=`(kubectl describe services deployer-publicport | grep elb | cut -d ":" -f2 | xargs)`:7777
PROFILER_URL=`(kubectl describe services workload-profiler-publicport | grep elb | cut -d ":" -f2 | xargs)`:7779

help: ## This help message
	@echo "             COMMAND"
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

aws-size: ## make aws-size
	@curl $(POST_ARG) http://$(PROFILER_URL)/sizing/aws/$(WORKLOAD)

benchmark: ## make benchmark
	@curl $(POST_ARG) http://$(PROFILER_URL)/benchmarks/$(WORKLOAD) $(CURL_ARGS)

calibrate: ## make calibrate
	@curl $(POST_ARG) http://$(PROFILER_URL)/calibrate/$(WORKLOAD) $(CURL_ARGS)

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
