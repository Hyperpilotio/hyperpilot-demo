FROM redis:3-alpine

RUN apk add --update curl py-psutil jq python python-dev py-pip build-base && \
    rm -rf /var/cache/apk/*

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY app.py /usr/local/bin/app.py
COPY config.json /usr/local/bin/config.json
COPY run.sh /usr/local/bin/run.sh

EXPOSE 8181

ENTRYPOINT ["/usr/local/bin/run.sh"]