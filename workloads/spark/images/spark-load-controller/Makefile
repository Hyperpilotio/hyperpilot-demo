organization=hyperpilot
image-name=spark-load-controller
tag=latest

build: Dockerfile
	docker build -t $(organization)/$(image-name):$(tag) .

push:
	docker push $(organization)/$(image-name):$(tag)
