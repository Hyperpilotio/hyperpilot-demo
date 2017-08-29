organization=hyperpilot
image-name=spark
tag=2.1.0-hadoop-2.7

build: Dockerfile
	docker build -t $(organization)/$(image-name):$(tag) .

push:
	docker push $(organization)/$(image-name):$(tag)
