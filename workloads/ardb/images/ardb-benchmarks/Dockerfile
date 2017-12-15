FROM redis:3-alpine

RUN apk add --update curl py-psutil jq python python-dev py-pip build-base && \
    rm -rf /var/cache/apk/*

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY app.py app.py
COPY config.json config.json

EXPOSE 8181

CMD [ "python", "app.py" ]