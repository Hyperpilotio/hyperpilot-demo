# URL
DEPLOYER_URL=`(kubectl describe services deployer-publicport | grep elb | cut -d ":" -f2 | xargs)`:7777

#DEPLOYER_URL=localhost:7777

upload-analysis-base-file:
	@curl -XPOST ${DEPLOYER_URL}/v1/templates/analysis-base --data-binary @templates/analysis-base.json

upload-analysis-base-spark-file:
	@curl -XPOST ${DEPLOYER_URL}/v1/templates/analysis-base-spark --data-binary @templates/analysis-base-spark.json

generate-analysis-base-file:
	@echo "Generate analysis-base-file.json with  benchmark-agent, snap-agent, dd-agent"
	@./add-components.py --template templates/analysis-base.json --components snap dd benchmark

deploy-prometheus:
ifneq ($(wildcard components/prometheus-operator/.*),)
	@./components/prometheus-operator/contrib/kube-prometheus//hack/cluster-monitoring/deploy
else
	@echo "Please update git submodule ..."
endif
