# hyperpilot-demo
Hyperpilot e2e demo

* K8S on AWS-ECS

Pre-reqs:

- Install the [deployer](https://github.com/Hyperpilotio/deployer) 


Setup daemon scheduler
```
git clone https://github.com/Hyperpilotio/hyperpilot-demo.git
cd hyperpilot-demo/workloads/tech-demo/
./deploy-k8s.sh
```

If needed, edit deploy.json. 

To get the config file
`curl localhost:7777/v1/deployments/<stack-name>/kubeconfig`

To get the key
`curl localhost:7777/v1/deployments/<deployment-name>/ssh_key`

To deploy a K8S dashboard 
`kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml`

`kubectl proxy`

To enable the controller

`QOS_DATA_STORE=$(kubectl get -n hyperpilot pods | grep qos-data-store | cut -d" " -f1)`

`kubectl port-forward $QOS_DATA_STORE 7781:7781 -n hyperpilot`

`curl -XPOST localhost:7781/v1/switch/on`

To delete all K8S deployments and services
```
kubectl get deployment | cut -d" " -f1 | tail -n 8 | xargs kubectl delete deployment
kubectl get services | cut -d" " -f1 | tail -n 8 | xargs kubectl delete services
```

To teardown: 
`curl -XDELETE localhost:7777/v1/deployments/<stack-name>`

## Load Test
To start the load test, run
`locust --master -f load-controller/locustfile_test.py --host "http://localhost:8001"`
`locust --slave -f load-controller/locustfile_test.py --host "http://localhost:8001"`
`python load-controller.py --load-file workloads/tech-demo/hi_lo_config.json`

Go to `localhost:8001` to change the configuration to the desired values.
All values must be set to restart successfully.

Important port numbers:
* Locust-master 8089
* Influx 8086
* spark-master 7077
* Load-configuration UI 8001


