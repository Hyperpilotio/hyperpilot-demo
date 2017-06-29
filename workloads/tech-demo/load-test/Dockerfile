FROM python:2

ADD slow_cooker.py .

ADD hi_lo_config.json .

RUN pip install requests

ENTRYPOINT python slow_cooker.py
