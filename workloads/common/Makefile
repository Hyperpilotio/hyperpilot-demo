# URL
DEPLOYER_URL=`(kubectl describe services deployer-publicport | grep elb | cut -d ":" -f2 | xargs)`:7777

#DEPLOYER_URL=localhost:7777

upload-analysis-base-file:
	@curl -XPOST ${DEPLOYER_URL}/v1/templates/analysis-base --data-binary @analysis-base.json

upload-analysis-base-spark-file:
	@curl -XPOST ${DEPLOYER_URL}/v1/templates/analysis-base-spark --data-binary @analysis-base-spark.json
