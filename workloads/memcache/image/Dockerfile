FROM    ubuntu
RUN	apt-get update && apt-get install -y scons libevent-dev gengetopt libzmq-dev g++
ADD     mutilate /mutilate
WORKDIR /mutilate
RUN     scons
