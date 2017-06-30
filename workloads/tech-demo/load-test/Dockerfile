FROM python:2

RUN pip install requests

ADD slow_cooker.py .

ADD hi_lo_config.json .

ENTRYPOINT ["python", "slow_cooker.py"]
