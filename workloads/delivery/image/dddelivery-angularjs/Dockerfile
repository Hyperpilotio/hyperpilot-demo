FROM golang:latest

ADD . /app
WORKDIR /app
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
    apt-get install -y nodejs && \
    apt-get install -y build-essential && \
    npm install -g bower && \
    bower install --allow-root

CMD ["go", "run", "server.go"]
