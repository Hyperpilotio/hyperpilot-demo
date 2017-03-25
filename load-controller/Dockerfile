FROM jfloff/alpine-python:2.7
RUN pip install requests

ADD load-controller.py load-controller.py

ENTRYPOINT ["python", "-u", "load-controller.py"]