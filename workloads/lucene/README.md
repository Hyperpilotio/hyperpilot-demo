# Lucene Workload

deploy this Workload may need 10 mins for indexing, and 12GB storage size,
please please put this pod to dedicated node

# How to run this workload?
1. start local deployer
2. execute ```cd images/template && ./memory-optimize-with-benchmark-controller.sh``` to add template to simpleDB
2. running ```./deploy-k8s.sh``` and wait for build completion.
3. get workload-profiler's endpoint (http://work-load-profiler-hostname:7779)
4. running ```./calibrate.sh work-load-profiler-hostname ```

# Lucene-base template
It Copy from analysis-base template, with following changes:
1. instance type changes to r4.xlarge
2. bundle benchmark-controller task

# TODO
1. use some dev images for now, change it when everything stable
