FROM telegraf:1.3.4
RUN sudo apt-get update && \
    sudo apt-get install -y \
        python python-pip \
        libcurl4-openssl-dev \
        python-dev && \
        rm -rf /var/lib/apt/lists/*
RUN pip install kubernetes pycurl --upgrade
COPY set_deployment_id.py /set_deployment_id.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# ENTRYPOINT ["/bin/bash"]
CMD ["telegraf"]
