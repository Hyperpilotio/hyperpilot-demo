FROM mongo
RUN apt-get update && apt-get install -y python python-pip curl netcat && rm -rf /var/lib/apt/lists/*
COPY . /src
WORKDIR /src
RUN chmod +x docker-entrypoint.sh
ENTRYPOINT ["./docker-entrypoint.sh"]
