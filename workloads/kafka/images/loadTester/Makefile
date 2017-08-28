organization=hyperpilot
image-name=load-tester
tag=kafka

build: Dockerfile
	docker build -t $(organization)/$(image-name):$(tag) .

push:
	docker push $(organization)/$(image-name):$(tag)
