DEPLOYER_URL=a7ed96f5e83ab11e7b0eb12f752fb7c5-691310979.us-east-1.elb.amazonaws.com:7777
#DEPLOYER_URL=localhost:7777

upload-analysis-base-file:
	@curl -XPOST ${DEPLOYER_URL}/v1/templates/analysis-base --data-binary @analysis-base.json

upload-analysis-base-spark-file:
	@curl -XPOST ${DEPLOYER_URL}/v1/templates/analysis-base-spark --data-binary @analysis-base-spark.json
