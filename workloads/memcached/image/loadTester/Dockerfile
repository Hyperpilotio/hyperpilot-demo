FROM    debian:jessie 

ADD     mutilate /mutilate

WORKDIR /mutilate

RUN     apt-get update && apt-get install -y scons libevent-dev gengetopt libzmq-dev g++ && scons

CMD     ["mutilate"]