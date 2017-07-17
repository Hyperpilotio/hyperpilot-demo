FROM python:2

COPY . /ec2_instance_type

WORKDIR /ec2_instance_type

RUN pip install -r requirements.txt

ENTRYPOINT ["python", "ec2_ins_type_clawer.py"]
