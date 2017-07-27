FROM    mongo:3.4.6

ADD     mongo-perf /mongo-perf

RUN     apt-get update -y && \
        apt-get install python-dev python-pip -y && \
        pip install -r /mongo-perf/requirements.txt

CMD     ["/bin/bash"]
