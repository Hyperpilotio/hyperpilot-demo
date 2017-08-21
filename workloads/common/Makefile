DEPLOYER_URL=ac3c0e2b286a711e7a976121637a557b-365227458.us-east-1.elb.amazonaws.com:7777
#DEPLOYER_URL=localhost:7777

upload-analysis-base-file:
	@curl -XPOST ${DEPLOYER_URL}/v1/templates/analysis-base --data-binary @analysis-base.json

upload-analysis-base-spark-file:
	@curl -XPOST ${DEPLOYER_URL}/v1/templates/analysis-base-spark --data-binary @analysis-base-spark.json
