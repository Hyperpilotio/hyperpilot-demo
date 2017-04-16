#!/bin/bash

for i in `seq 1 $1`;
do
    ./run.sh i &
done

for job in `jobs -p`
do
    echo $job
    wait $job
done
