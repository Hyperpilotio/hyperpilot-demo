# Kubernetes

To build the data pipeline to collect metrics from kubernetes cluster.


## Get started

Deploy following components on kubernetes cluster.
* k8s dashboard
* heapster
    * influxdb
    * heapster
    * grafana
* kube-state-metrics

```{shell}
make all
```
