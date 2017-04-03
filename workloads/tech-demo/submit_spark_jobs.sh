SPARK_MASTER_POD=`kubectl get pods | grep spark-master | cut -d" " -f1`

kubectl exec $SPARK_MASTER_POD -- /bin/bash -c './run.sh 20'
