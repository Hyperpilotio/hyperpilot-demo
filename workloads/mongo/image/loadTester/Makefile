organization=hyperpilot
image-name=load-tester
tag=mongo

build: Dockerfile
	docker build -t $(organization)/$(image-name):$(tag) .

push:
	docker push $(organization)/$(image-name):$(tag)