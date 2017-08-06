SHELL := /bin/bash
.PHONY: help

# Variable
WORKLOAD=memcached
USER_ID=hyperpilot
DEPLOYMENT_ID=hyperpilot

# ARGUMENTS
POST_ARG=-XPOST -H "Content-Type: application/json"
CURL_ARGS=-d "{\"startingIntensity\":10, \"step\": 10}"

# URL
DEPLOYER_URL=localhost:7777
PROFILER_URL=localhost:7779

help: ## This help message
	@echo "             COMMAND"
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

aws-size: ## make aws-size
	@curl $(POST_ARG) http://$(PROFILER_URL)/sizing/aws/$(WORKLOAD)

benchmark: ## make benchmark DEPLOYMENT_ID=
	@curl $(POST_ARG) http://$(PROFILER_URL)/benchmarks/$(WORKLOAD) $(CURL_ARGS)

calibrate: ## make calibrate DEPLOYMENT_ID=
	@curl -XPOST http://$(PROFILER_URL)/calibrate/$(WORKLOAD)

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
