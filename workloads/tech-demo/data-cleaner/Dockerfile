FROM python:2
RUN pip install docker==2.1.0 influxdb pymongo
COPY *.py /
CMD ["python","-u","/cleaner.py","-v"]
