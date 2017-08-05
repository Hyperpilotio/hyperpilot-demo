DEPLOYER_URL=a9b90dfae797111e793c50ae2e11e2ff-943179703.us-east-1.elb.amazonaws.com:7777

upload-analysis-base-file:
	@curl -XPOST ${DEPLOYER_URL}/v1/templates/analysis-base --data-binary @analysis-base.json
