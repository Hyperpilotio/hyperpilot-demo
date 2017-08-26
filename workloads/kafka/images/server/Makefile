organization=hyperpilot
image-name=kafka
tag=latest

build: Dockerfile
	docker build -t $(organization)/$(image-name):$(tag) .

push:
	docker push $(organization)/$(image-name):$(tag)
