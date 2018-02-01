#!/usr/bin/env bash


KUBECONFIG=/tmp/tech-demo-aba14d62_kubeconfig/kubeconfig

uuid()
{
    local N B T

    for (( N=0; N < 16; ++N ))
    do
        B=$(( $RANDOM%255 ))

        if (( N == 6 ))
        then
            printf '4%x' $(( B%15 ))
        elif (( N == 8 ))
        then
            local C='89ab'
            printf '%c%x' ${C:$(( $RANDOM%${#C} )):1} $(( B%15 ))
        else
            printf '%02x' $B
        fi

        for T in 3 5 7 9
        do
            if (( T == N ))
            then
                printf '-'
                break
            fi
        done
    done

    echo
}



#echo $KUBECONFIG

#kubectl get pod

cluster_id=$(uuid | awk 'BEGIN{FS="-"} {print $1}')
token=$(uuid | tr -d -)



kubectl create ns $cluster_id
curl https://s3.us-east-2.amazonaws.com/jimmy-hyperpilot/influx.yaml | sed "s/<CLUSTERID>/$cluster_id/g" > /tmp/influx.yaml
curl https://s3.us-east-2.amazonaws.com/jimmy-hyperpilot/analyzer.yaml | sed "s/<CLUSTERID>/$cluster_id/g" > /tmp/analyzer.yaml
curl https://s3.us-east-2.amazonaws.com/jimmy-hyperpilot/mongo.yaml | sed "s/<CLUSTERID>/$cluster_id/g" > /tmp/mongo.yaml
kubectl create -f /tmp/influx.yaml
kubectl create -f /tmp/analyzer.yaml
kubectl create -f /tmp/mongo.yaml

adapter_ip=$(kubectl get svc adapter-lb |tail -n 1| awk '{print $4}')

echo "http://$adapter_ip/write?token=$token&clusterId=$cluster_id"
