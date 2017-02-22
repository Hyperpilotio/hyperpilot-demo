CMD=kubectl
k8s-dashboard=https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml

all:
	#"Deploy kubernetes dashboard"
	
	$(CMD) create -f $(k8s-dashboard)

	#"Deploy heapster ..."
	$(CMD) create -f heapster/deploy/kube-config/influxdb
	
	#"Deploy kube-state-metrics ..."
	$(CMD) apply -f kube-state-metrics/kubernetes
	
	#"To access dashboard: kubectl cluster-info"
