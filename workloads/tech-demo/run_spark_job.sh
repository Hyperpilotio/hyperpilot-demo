SPARK_MASTER_POD=`kubectl get pods | grep spark-master | cut -d" " -f1`

kubectl exec $SPARK_MASTER_POD -- /bin/bash -c './bin/spark-submit --master=spark://$(hostname -i):6066 --deploy-mode=cluster --class MovieLensALS s3://hyperpilot-jarfiles/movielens-als-assembly-2.11-0.1.jar s3://demo-analysis-datasets/movielens/medium/ s3://demo-analysis-datasets/personalRatings.txt'
