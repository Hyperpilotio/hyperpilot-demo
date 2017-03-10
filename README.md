# hyperpilot-demo
Hyperpilot e2e demo

* K8S on AWS-ECS

Pre-reqs:

- Install the [deployer](https://github.com/Hyperpilotio/deployer) 


Setup daemon scheduler

`git clone https://github.com/Hyperpilotio/hyperpilot-demo.git`
`cd hyperpilot-demo/workloads/tech-demo/`
`./deploy-k8s.sh'

If needed, edit deploy.json. 

To get the config file
`curl localhost:7777/v1/deployments/<stack-name>/kubeconfig`

To deploy a K8S dashboard 
`kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml`

To teardown: 
`curl -XDELETE localhost:7777/v1/deployments/<stack-name>`


