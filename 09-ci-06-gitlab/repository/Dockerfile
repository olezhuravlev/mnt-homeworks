FROM centos:7
RUN yum install python3 python3-pip -y
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY python_api/python-api.py python-api.py
CMD ["python3", "python-api.py"]
